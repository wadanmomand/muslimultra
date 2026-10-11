import 'dart:async';
import 'package:flutter/foundation.dart';
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

/// Reading Mode (Translation vs Arabic-only Mushaf)
enum QuranReadingMode {
  translation,
  mushaf,
}

class QuranReadingModeNotifier extends StateNotifier<QuranReadingMode> {
  QuranReadingModeNotifier() : super(QuranReadingMode.translation) {
    _load();
  }

  Future<void> _load() async {
    final mode = await QuranStorageService.loadReadingMode();
    state = mode == 'mushaf' ? QuranReadingMode.mushaf : QuranReadingMode.translation;
  }

  void setMode(QuranReadingMode mode) {
    state = mode;
    QuranStorageService.saveReadingMode(
      mode == QuranReadingMode.mushaf ? 'mushaf' : 'translation',
    );
  }

  void toggleMode() {
    setMode(
      state == QuranReadingMode.translation
          ? QuranReadingMode.mushaf
          : QuranReadingMode.translation,
    );
  }
}

final quranReadingModeProvider =
    StateNotifierProvider<QuranReadingModeNotifier, QuranReadingMode>((ref) {
  return QuranReadingModeNotifier();
});

/// Supported Quran Translations
enum QuranTranslation {
  english('en.sahih', 'English (Saheeh Int.)', 'EN'),
  urdu('ur.jalandhry', 'اردو (Jalandhry)', 'UR');

  final String code;
  final String label;
  final String shortCode;
  const QuranTranslation(this.code, this.label, this.shortCode);
}

class QuranTranslationNotifier extends StateNotifier<QuranTranslation> {
  QuranTranslationNotifier() : super(QuranTranslation.english) {
    _load();
  }

  Future<void> _load() async {
    final code = await QuranStorageService.loadTranslationCode();
    if (code.startsWith('ur') || code == 'ur.jalandhry') {
      state = QuranTranslation.urdu;
    } else {
      state = QuranTranslation.english;
    }
  }

  void setTranslation(QuranTranslation translation) {
    state = translation;
    QuranStorageService.saveTranslationCode(translation.code);
  }

  void toggleTranslation() {
    setTranslation(
      state == QuranTranslation.english
          ? QuranTranslation.urdu
          : QuranTranslation.english,
    );
  }
}

final quranTranslationProvider =
    StateNotifierProvider<QuranTranslationNotifier, QuranTranslation>((ref) {
  return QuranTranslationNotifier();
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

/// Quran Audio Repeat Modes
enum QuranRepeatMode {
  off,
  ayah,
  surah,
}

/// Quran Audio Player State
enum QuranAudioStatus { stopped, playing, paused, loading, error }

class QuranAudioState {
  final QuranAudioStatus status;
  final int? playingAyahNumber;
  final int? playingSurahNumber;
  final Duration position;
  final Duration duration;
  final QuranRepeatMode repeatMode;
  final double playbackSpeed;
  final int? sleepTimerMinutes;
  final Duration? sleepTimerRemaining;
  final String? errorMessage;

  const QuranAudioState({
    this.status = QuranAudioStatus.stopped,
    this.playingAyahNumber,
    this.playingSurahNumber,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.repeatMode = QuranRepeatMode.off,
    this.playbackSpeed = 1.0,
    this.sleepTimerMinutes,
    this.sleepTimerRemaining,
    this.errorMessage,
  });

  bool get isPlaying => status == QuranAudioStatus.playing;
  bool get isPaused => status == QuranAudioStatus.paused;
  bool get isLoading => status == QuranAudioStatus.loading;
  bool get isError => status == QuranAudioStatus.error;

  QuranAudioState copyWith({
    QuranAudioStatus? status,
    int? playingAyahNumber,
    int? playingSurahNumber,
    Duration? position,
    Duration? duration,
    QuranRepeatMode? repeatMode,
    double? playbackSpeed,
    int? sleepTimerMinutes,
    Duration? sleepTimerRemaining,
    String? errorMessage,
    bool clearSleepTimer = false,
    bool clearError = false,
  }) {
    return QuranAudioState(
      status: status ?? this.status,
      playingAyahNumber: playingAyahNumber ?? this.playingAyahNumber,
      playingSurahNumber: playingSurahNumber ?? this.playingSurahNumber,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      repeatMode: repeatMode ?? this.repeatMode,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      sleepTimerMinutes: clearSleepTimer ? null : (sleepTimerMinutes ?? this.sleepTimerMinutes),
      sleepTimerRemaining: clearSleepTimer ? null : (sleepTimerRemaining ?? this.sleepTimerRemaining),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class QuranAudioNotifier extends StateNotifier<QuranAudioState> {
  final Ref ref;
  final AudioPlayer _player = AudioPlayer();
  Timer? _sleepTimer;

  static const List<double> availableSpeeds = [1.0, 1.25, 1.5, 2.0, 0.75];

  QuranAudioNotifier(this.ref) : super(const QuranAudioState()) {
    _init();

    try {
      _player.onPlayerStateChanged.listen((pState) {
        if (pState == PlayerState.completed) {
          _handleAyahCompleted();
        }
      });

      _player.onPositionChanged.listen((pos) {
        if (mounted) state = state.copyWith(position: pos);
      });

      _player.onDurationChanged.listen((dur) {
        if (mounted) state = state.copyWith(duration: dur);
      });
    } catch (_) {
      // Graceful in headless unit tests
    }
  }

  Future<void> _init() async {
    try {
      // Configure audio session for background playback across iOS & Android
      await _player.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: const {},
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: true,
          ),
        ),
      );

      final repeatStr = await QuranStorageService.loadRepeatMode();
      final repeat = QuranRepeatMode.values.firstWhere(
        (r) => r.name == repeatStr,
        orElse: () => QuranRepeatMode.off,
      );

      final speed = await QuranStorageService.loadPlaybackSpeed();
      try {
        await _player.setPlaybackRate(speed);
      } catch (_) {}

      if (mounted) {
        state = state.copyWith(
          repeatMode: repeat,
          playbackSpeed: speed,
        );
      }
    } catch (e) {
      debugPrint('QuranAudioNotifier: Initialization note: $e');
    }
  }

  Future<void> playAyah({required int surahNumber, required int ayahNumber}) async {
    final reciter = ref.read(selectedReciterProvider);
    final url = AudioUrlBuilder.buildAyahAudioUrl(
      reciterSubpath: reciter.subpath,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
    );

    if (mounted) {
      state = state.copyWith(
        status: QuranAudioStatus.loading,
        playingAyahNumber: ayahNumber,
        playingSurahNumber: surahNumber,
        position: Duration.zero,
        duration: Duration.zero,
        clearError: true,
      );
    }

    try {
      await _player.stop();
      await _player.setPlaybackRate(state.playbackSpeed);
      await _player.play(UrlSource(url));
      if (mounted) {
        state = state.copyWith(
          status: QuranAudioStatus.playing,
          playingAyahNumber: ayahNumber,
          playingSurahNumber: surahNumber,
          clearError: true,
        );
      }
      debugPrint('QuranAudioNotifier: Playing Surah $surahNumber Ayah $ayahNumber from $url');
    } catch (e, st) {
      debugPrint('QuranAudioNotifier: Failed to play audio: $e\n$st');
      if (mounted) {
        state = state.copyWith(
          status: QuranAudioStatus.error,
          errorMessage: 'audio_load_error',
        );
      }
    }
  }

  Future<void> togglePlayPause() async {
    if (state.isPlaying) {
      await _player.pause();
      if (mounted) state = state.copyWith(status: QuranAudioStatus.paused);
    } else if (state.status == QuranAudioStatus.paused) {
      await _player.resume();
      if (mounted) state = state.copyWith(status: QuranAudioStatus.playing);
    } else if (state.playingSurahNumber != null && state.playingAyahNumber != null) {
      await playAyah(
        surahNumber: state.playingSurahNumber!,
        ayahNumber: state.playingAyahNumber!,
      );
    }
  }

  Future<void> _handleAyahCompleted() async {
    if (state.playingAyahNumber == null || state.playingSurahNumber == null) return;

    final currentAyah = state.playingAyahNumber!;
    final currentSurahNumber = state.playingSurahNumber!;
    final currentSurah = TanzilQuranData.allSurahs.firstWhere(
      (s) => s.number == currentSurahNumber,
    );

    switch (state.repeatMode) {
      case QuranRepeatMode.ayah:
        // Replay same ayah
        await playAyah(surahNumber: currentSurahNumber, ayahNumber: currentAyah);
        break;

      case QuranRepeatMode.surah:
        if (currentAyah < currentSurah.numberOfAyahs) {
          await playAyah(surahNumber: currentSurahNumber, ayahNumber: currentAyah + 1);
        } else {
          // Loop back to Ayah 1 of the same surah
          await playAyah(surahNumber: currentSurahNumber, ayahNumber: 1);
        }
        break;

      case QuranRepeatMode.off:
        if (currentAyah < currentSurah.numberOfAyahs) {
          await playAyah(surahNumber: currentSurahNumber, ayahNumber: currentAyah + 1);
        } else {
          // End of Surah with Repeat Off: Clean stop (documented choice)
          await stop();
        }
        break;
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
        // Clean stop at end of surah
        await stop();
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

  Future<void> seek(Duration position) async {
    try {
      await _player.seek(position);
      if (mounted) state = state.copyWith(position: position);
    } catch (e) {
      debugPrint('QuranAudioNotifier: Seek error: $e');
    }
  }

  void cycleRepeatMode() {
    final nextMode = switch (state.repeatMode) {
      QuranRepeatMode.off => QuranRepeatMode.ayah,
      QuranRepeatMode.ayah => QuranRepeatMode.surah,
      QuranRepeatMode.surah => QuranRepeatMode.off,
    };
    if (mounted) state = state.copyWith(repeatMode: nextMode);
    QuranStorageService.saveRepeatMode(nextMode.name);
  }

  void setRepeatMode(QuranRepeatMode mode) {
    if (mounted) state = state.copyWith(repeatMode: mode);
    QuranStorageService.saveRepeatMode(mode.name);
  }

  Future<void> cyclePlaybackSpeed() async {
    final currentIndex = availableSpeeds.indexOf(state.playbackSpeed);
    final nextIndex = (currentIndex + 1) % availableSpeeds.length;
    final nextSpeed = availableSpeeds[nextIndex];
    await setPlaybackSpeed(nextSpeed);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    try {
      await _player.setPlaybackRate(speed);
      if (mounted) state = state.copyWith(playbackSpeed: speed);
      await QuranStorageService.savePlaybackSpeed(speed);
    } catch (e) {
      debugPrint('QuranAudioNotifier: Error setting playback speed: $e');
    }
  }

  void setSleepTimer(int? minutes) {
    _sleepTimer?.cancel();
    _sleepTimer = null;

    if (minutes == null || minutes <= 0) {
      if (mounted) state = state.copyWith(clearSleepTimer: true);
      return;
    }

    final duration = Duration(minutes: minutes);
    if (mounted) {
      state = state.copyWith(
        sleepTimerMinutes: minutes,
        sleepTimerRemaining: duration,
      );
    }

    _sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      final currentRemaining = state.sleepTimerRemaining;
      if (currentRemaining == null || currentRemaining.inSeconds <= 1) {
        timer.cancel();
        _sleepTimer = null;
        stop();
        if (mounted) state = state.copyWith(clearSleepTimer: true);
        debugPrint('QuranAudioNotifier: Sleep timer expired. Playback stopped.');
      } else {
        if (mounted) {
          state = state.copyWith(
            sleepTimerRemaining: currentRemaining - const Duration(seconds: 1),
          );
        }
      }
    });
  }

  Future<void> stop() async {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    try {
      await _player.stop();
    } catch (e) {
      debugPrint('QuranAudioNotifier: Error stopping audio player: $e');
    }
    if (mounted) {
      state = state.copyWith(
        status: QuranAudioStatus.stopped,
        position: Duration.zero,
        duration: Duration.zero,
        clearSleepTimer: true,
        clearError: true,
      );
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    try {
      _player.dispose();
    } catch (_) {}
    super.dispose();
  }
}

final quranAudioProvider =
    StateNotifierProvider<QuranAudioNotifier, QuranAudioState>((ref) {
  return QuranAudioNotifier(ref);
});

/// Context string passed when tapping "Ask Muslim AI" on an Ayah
final pendingAiQuestionContextProvider = StateProvider<String?>((ref) => null);
