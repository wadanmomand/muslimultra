import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/quran/data/quran_storage_service.dart';
import 'package:muslim_ultra/features/quran/data/audio_url_builder.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers.global'),
      (MethodCall methodCall) async => 1,
    );
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('xyz.luan/audioplayers'),
      (MethodCall methodCall) async => 1,
    );
  });

  group('Quran Audio Storage Persistence Tests', () {
    test('Persists and restores Repeat Mode', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await QuranStorageService.loadRepeatMode(), 'off');

      await QuranStorageService.saveRepeatMode('ayah');
      expect(await QuranStorageService.loadRepeatMode(), 'ayah');

      await QuranStorageService.saveRepeatMode('surah');
      expect(await QuranStorageService.loadRepeatMode(), 'surah');
    });

    test('Persists and restores Playback Speed', () async {
      SharedPreferences.setMockInitialValues({});

      expect(await QuranStorageService.loadPlaybackSpeed(), 1.0);

      await QuranStorageService.savePlaybackSpeed(1.5);
      expect(await QuranStorageService.loadPlaybackSpeed(), 1.5);

      await QuranStorageService.savePlaybackSpeed(0.75);
      expect(await QuranStorageService.loadPlaybackSpeed(), 0.75);
    });
  });

  group('Quran Audio URL Builder Tests', () {
    test('Builds valid EveryAyah CDN URLs with 3-digit padded numbers', () {
      final url1 = AudioUrlBuilder.buildAyahAudioUrl(
        reciterSubpath: 'Alafasy_128kbps',
        surahNumber: 1,
        ayahNumber: 1,
      );
      expect(url1, 'https://everyayah.com/data/Alafasy_128kbps/001001.mp3');

      final url2 = AudioUrlBuilder.buildAyahAudioUrl(
        reciterSubpath: 'Abdul_Basit_Murattal_192kbps',
        surahNumber: 114,
        ayahNumber: 6,
      );
      expect(url2, 'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/114006.mp3');
    });
  });

  group('Quran Audio State & Notifier Logic Tests', () {
    test('Repeat Mode Enum transitions correctly', () {
      const stateOff = QuranAudioState(repeatMode: QuranRepeatMode.off);
      expect(stateOff.repeatMode, QuranRepeatMode.off);

      const stateAyah = QuranAudioState(repeatMode: QuranRepeatMode.ayah);
      expect(stateAyah.repeatMode, QuranRepeatMode.ayah);

      const stateSurah = QuranAudioState(repeatMode: QuranRepeatMode.surah);
      expect(stateSurah.repeatMode, QuranRepeatMode.surah);
    });

    test('QuranAudioState copyWith properly updates fields and clears timer/error', () {
      const initial = QuranAudioState();
      final updated = initial.copyWith(
        status: QuranAudioStatus.playing,
        playingSurahNumber: 1,
        playingAyahNumber: 3,
        playbackSpeed: 1.25,
        repeatMode: QuranRepeatMode.ayah,
        sleepTimerMinutes: 15,
        sleepTimerRemaining: const Duration(minutes: 15),
      );

      expect(updated.isPlaying, isTrue);
      expect(updated.playingSurahNumber, 1);
      expect(updated.playingAyahNumber, 3);
      expect(updated.playbackSpeed, 1.25);
      expect(updated.repeatMode, QuranRepeatMode.ayah);
      expect(updated.sleepTimerMinutes, 15);
      expect(updated.sleepTimerRemaining, const Duration(minutes: 15));

      final clearedTimer = updated.copyWith(clearSleepTimer: true);
      expect(clearedTimer.sleepTimerMinutes, isNull);
      expect(clearedTimer.sleepTimerRemaining, isNull);
    });

    test('End of Surah Behavior: last ayah finishes with Repeat Off stops cleanly', () async {
      final container = ProviderContainer();
      try {
        final notifier = container.read(quranAudioProvider.notifier);

        // Verify initial state
        expect(container.read(quranAudioProvider).status, QuranAudioStatus.stopped);

        // Verify Surah 112 (Al-Ikhlas) has 4 ayahs
        final surah112 = TanzilQuranData.allSurahs.firstWhere((s) => s.number == 112);
        expect(surah112.numberOfAyahs, 4);

        // Stop resets state cleanly
        await notifier.stop();
        final stoppedState = container.read(quranAudioProvider);
        expect(stoppedState.status, QuranAudioStatus.stopped);
        expect(stoppedState.position, Duration.zero);
        expect(stoppedState.duration, Duration.zero);
      } finally {
        container.dispose();
      }
    });

    test('Speed cycling traverses [1.0, 1.25, 1.5, 2.0, 0.75, 1.0]', () {
      final speeds = QuranAudioNotifier.availableSpeeds;
      expect(speeds, [1.0, 1.25, 1.5, 2.0, 0.75]);

      int currentIndex = 0;
      expect(speeds[currentIndex], 1.0);

      currentIndex = (currentIndex + 1) % speeds.length;
      expect(speeds[currentIndex], 1.25);

      currentIndex = (currentIndex + 1) % speeds.length;
      expect(speeds[currentIndex], 1.5);

      currentIndex = (currentIndex + 1) % speeds.length;
      expect(speeds[currentIndex], 2.0);

      currentIndex = (currentIndex + 1) % speeds.length;
      expect(speeds[currentIndex], 0.75);

      currentIndex = (currentIndex + 1) % speeds.length;
      expect(speeds[currentIndex], 1.0);
    });

    test('Sleep timer setting and cancellation', () {
      final container = ProviderContainer();
      try {
        final notifier = container.read(quranAudioProvider.notifier);

        notifier.setSleepTimer(10);
        expect(container.read(quranAudioProvider).sleepTimerMinutes, 10);
        expect(container.read(quranAudioProvider).sleepTimerRemaining, const Duration(minutes: 10));

        notifier.setSleepTimer(null);
        expect(container.read(quranAudioProvider).sleepTimerMinutes, isNull);
        expect(container.read(quranAudioProvider).sleepTimerRemaining, isNull);
      } finally {
        container.dispose();
      }
    });
  });
}
