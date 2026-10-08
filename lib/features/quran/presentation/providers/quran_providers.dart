import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:muslim_ultra/features/quran/domain/models/surah.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/quran/domain/models/reciter.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/data/quran_api_service.dart';
import 'package:muslim_ultra/features/quran/data/quran_storage_service.dart';
import 'package:muslim_ultra/features/quran/data/audio_url_builder.dart';

/// Search query provider
final quranSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered Surahs provider
final filteredSurahsProvider = Provider<List<SurahModel>>((ref) {
  final query = ref.watch(quranSearchQueryProvider).toLowerCase().trim();
  if (query.isEmpty) {
    return TanzilQuranData.allSurahs;
  }

  return TanzilQuranData.allSurahs.where((surah) {
    final matchesNumber = surah.number.toString() == query;
    final matchesEnglish = surah.englishName.toLowerCase().contains(query);
    final matchesTranslation = surah.englishNameTranslation.toLowerCase().contains(query);
    final matchesArabic = surah.name.contains(query);
    return matchesNumber || matchesEnglish || matchesTranslation || matchesArabic;
  }).toList();
});

/// Currently selected Surah
final activeSurahProvider = StateProvider<SurahModel>((ref) {
  return TanzilQuranData.allSurahs[0]; // Default Al-Fatihah
});

/// Ayahs for a specific Surah number
final surahAyahsProvider = FutureProvider.family<List<AyahModel>, int>((ref, surahNumber) async {
  return QuranApiService.fetchSurahAyahs(surahNumber);
});

/// Ayahs for the active Surah
final activeSurahAyahsProvider = FutureProvider<List<AyahModel>>((ref) async {
  final activeSurah = ref.watch(activeSurahProvider);
  return ref.watch(surahAyahsProvider(activeSurah.number).future);
});

/// Bookmarks state
class QuranBookmarksNotifier extends StateNotifier<List<String>> {
  QuranBookmarksNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await QuranStorageService.loadBookmarks();
  }

  Future<void> toggle(int surahNumber, int ayahNumber) async {
    state = await QuranStorageService.toggleBookmark(surahNumber, ayahNumber);
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    return state.contains('$surahNumber:$ayahNumber');
  }
}

final quranBookmarksProvider =
    StateNotifierProvider<QuranBookmarksNotifier, List<String>>((ref) {
  return QuranBookmarksNotifier();
});

/// Last Read State
class LastReadNotifier extends StateNotifier<Map<String, int>> {
  LastReadNotifier() : super({'surah': 1, 'ayah': 1}) {
    _load();
  }

  Future<void> _load() async {
    state = await QuranStorageService.getLastRead();
  }

  Future<void> setLastRead(int surah, int ayah) async {
    state = {'surah': surah, 'ayah': ayah};
    await QuranStorageService.saveLastRead(surah, ayah);
  }
}

final lastReadProvider =
    StateNotifierProvider<LastReadNotifier, Map<String, int>>((ref) {
  return LastReadNotifier();
});

/// Font Sizes State
class FontSizesNotifier extends StateNotifier<Map<String, double>> {
  FontSizesNotifier() : super({'arabic': 24.0, 'translation': 14.0}) {
    _load();
  }

  Future<void> _load() async {
    state = await QuranStorageService.loadFontSizes();
  }

  void setArabicFontSize(double size) {
    state = {...state, 'arabic': size};
    QuranStorageService.saveFontSizes(state['arabic']!, state['translation']!);
  }

  void setTranslationFontSize(double size) {
    state = {...state, 'translation': size};
    QuranStorageService.saveFontSizes(state['arabic']!, state['translation']!);
  }
}

final fontSizesProvider =
    StateNotifierProvider<FontSizesNotifier, Map<String, double>>((ref) {
  return FontSizesNotifier();
});

/// Reciter State
class ReciterNotifier extends StateNotifier<ReciterModel> {
  ReciterNotifier() : super(ReciterModel.defaultReciter) {
    _load();
  }

  Future<void> _load() async {
    final id = await QuranStorageService.loadReciterId();
    state = ReciterModel.availableReciters.firstWhere(
      (r) => r.id == id,
      orElse: () => ReciterModel.defaultReciter,
    );
  }

  void setReciter(ReciterModel reciter) {
    state = reciter;
    QuranStorageService.saveReciterId(reciter.id);
  }
}

final selectedReciterProvider =
    StateNotifierProvider<ReciterNotifier, ReciterModel>((ref) {
  return ReciterNotifier();
});

/// Quran Audio Player State
enum QuranAudioStatus { stopped, playing, paused, loading }

class QuranAudioState {
  final QuranAudioStatus status;
  final int? playingAyahNumber;
  final int? playingSurahNumber;
  final Duration position;
  final Duration duration;

  const QuranAudioState({
    this.status = QuranAudioStatus.stopped,
    this.playingAyahNumber,
    this.playingSurahNumber,
    this.position = Duration.zero,
    this.duration = Duration.zero,
  });

  bool get isPlaying => status == QuranAudioStatus.playing;
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final Ref ref;
  final AudioPlayer _player = AudioPlayer();

  QuranAudioNotifier(this.ref) : super(const QuranAudioState()) {
    _player.onPlayerStateChanged.listen((pState) {
      if (pState == PlayerState.completed) {
        // Auto-advance to next Ayah (Spec §3 M2)
        playNext();
      }
    });

    _player.onPositionChanged.listen((pos) {
      state = QuranAudioState(
        status: state.status,
        playingAyahNumber: state.playingAyahNumber,
        playingSurahNumber: state.playingSurahNumber,
        position: pos,
        duration: state.duration,
      );
    });

    _player.onDurationChanged.listen((dur) {
      state = QuranAudioState(
        status: state.status,
        playingAyahNumber: state.playingAyahNumber,
        playingSurahNumber: state.playingSurahNumber,
        position: state.position,
        duration: dur,
      );
    });
  }

  Future<void> playAyah({required int surahNumber, required int ayahNumber}) async {
    final reciter = ref.read(selectedReciterProvider);
    final url = AudioUrlBuilder.buildAyahAudioUrl(
      reciterSubpath: reciter.subpath,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    state = QuranAudioState(
      status: QuranAudioStatus.loading,
      playingAyahNumber: ayahNumber,
      playingSurahNumber: surahNumber,
    );

    try {
      await _player.stop();
      await _player.play(UrlSource(url));
      state = QuranAudioState(
        status: QuranAudioStatus.playing,
        playingAyahNumber: ayahNumber,
        playingSurahNumber: surahNumber,
      );
    } catch (_) {
      state = const QuranAudioState(status: QuranAudioStatus.stopped);
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
      state = QuranAudioState(
        status: QuranAudioStatus.paused,
        playingAyahNumber: state.playingAyahNumber,
        playingSurahNumber: state.playingSurahNumber,
        position: state.position,
        duration: state.duration,
      );
    } else if (state.status == QuranAudioStatus.paused) {
      await _player.resume();
      state = QuranAudioState(
        status: QuranAudioStatus.playing,
        playingAyahNumber: state.playingAyahNumber,
        playingSurahNumber: state.playingSurahNumber,
        position: state.position,
        duration: state.duration,
      );
    }
  }

  Future<void> playNext() async {
    if (state.playingAyahNumber != null && state.playingSurahNumber != null) {
      final currentSurah = TanzilQuranData.allSurahs.firstWhere(
        (s) => s.number == state.playingSurahNumber,
      );

      if (state.playingAyahNumber! < currentSurah.numberOfAyahs) {
        await playAyah(
          surahNumber: state.playingSurahNumber!,
          ayahNumber: state.playingAyahNumber! + 1,
        );
      } else {
        stop();
      }
    }
  }

  Future<void> playPrevious() async {
    if (state.playingAyahNumber != null && state.playingSurahNumber != null) {
      if (state.playingAyahNumber! > 1) {
        await playAyah(
          surahNumber: state.playingSurahNumber!,
          ayahNumber: state.playingAyahNumber! - 1,
        );
      }
    }
  }

  Future<void> stop() async {
    await _player.stop();
    state = const QuranAudioState(status: QuranAudioStatus.stopped);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}

final quranAudioProvider =
    StateNotifierProvider.autoDispose<QuranAudioNotifier, QuranAudioState>((ref) {
  return QuranAudioNotifier(ref);
});

/// Context string passed when tapping "Ask Muslim AI" on an Ayah
final pendingAiQuestionContextProvider = StateProvider<String?>((ref) => null);
