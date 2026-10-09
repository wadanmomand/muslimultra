import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/widgets/daily_ayat.dart';
import 'package:muslim_ultra/features/widgets/widget_bridge.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Daily Ayat Determinism & Rotation', () {
    test('Curated list contains exactly 30 hopeful ayat', () {
      expect(DailyAyatService.curated30.length, 30);
    });

    test('Rotation is deterministic for the same date', () {
      final dateA = DateTime(2026, 4, 15, 10, 0);
      final dateB = DateTime(2026, 4, 15, 23, 59);

      final refA = DailyAyatService.getRefForDate(dateA);
      final refB = DailyAyatService.getRefForDate(dateB);

      expect(refA.surah, refB.surah);
      expect(refA.ayah, refB.ayah);
    });

    test('30-day cycle covers all 30 distinct entries without repeating within cycle', () {
      final baseDate = DateTime(2026, 1, 1);
      final seenRefs = <String>{};

      for (int day = 0; day < 30; day++) {
        final currentDate = baseDate.add(Duration(days: day));
        final ref = DailyAyatService.getRefForDate(currentDate);
        final refKey = '${ref.surah}:${ref.ayah}';
        seenRefs.add(refKey);
      }

      // Exactly 30 unique references visited
      expect(seenRefs.length, 30);
    });
  });

  group('Bundled Quran Asset Resolution', () {
    test('All 30 curated ayat exist and resolve correctly from assets/quran/quran_full.json', () async {
      // Load bundled quran
      final jsonString = await rootBundle.loadString('assets/quran/quran_full.json');
      final Map<String, dynamic> quranMap = json.decode(jsonString) as Map<String, dynamic>;
      final surahs = quranMap['surahs'] as List<dynamic>;

      // Verify every curated reference resolves
      for (final ref in DailyAyatService.curated30) {
        final surahObj = surahs.firstWhere(
          (s) => (s as Map<String, dynamic>)['number'] == ref.surah,
          orElse: () => null,
        ) as Map<String, dynamic>?;
        expect(surahObj, isNotNull, reason: 'Surah ${ref.surah} must exist in bundle');

        final ayahs = surahObj!['ayahs'] as List<dynamic>;
        final ayahObj = ayahs.firstWhere(
          (a) => (a as Map<String, dynamic>)['n'] == ref.ayah,
          orElse: () => null,
        ) as Map<String, dynamic>?;
        expect(
          ayahObj,
          isNotNull,
          reason: 'Surah ${ref.surah}:${ref.ayah} must exist in bundle',
        );

        final text = (ayahObj!['t'] as String?)?.trim() ?? '';
        final translation = (ayahObj['en'] as String?)?.trim() ?? '';

        expect(text.isNotEmpty, isTrue);
        expect(translation.isNotEmpty, isTrue);

        // Also test the helper method resolveAyah
        final resolved = await DailyAyatService.resolveAyah(ref);
        expect(resolved.arabic.isNotEmpty, isTrue);
        expect(resolved.english.isNotEmpty, isTrue);
        expect(resolved.referenceText, 'Surah ${ref.surah}:${ref.ayah}');
      }
    });
  });

  group('WidgetBridge Platform Channel & SharedPreferences', () {
    test('updatePrayerWidget stores keys in SharedPreferences', () async {
      await WidgetBridge.updatePrayerWidget(
        nextPrayerName: 'Asr',
        nextPrayerTime: '4:15 PM',
        nextPrayerTimestamp: 1728480000000,
      );

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(WidgetBridge.keyNextPrayerName), 'Asr');
      expect(prefs.getString(WidgetBridge.keyNextPrayerTime), '4:15 PM');
      expect(prefs.getInt(WidgetBridge.keyNextPrayerTimestamp), 1728480000000);
      expect(prefs.getInt(WidgetBridge.keyLastUpdated), isNotNull);
    });

    test('updateAyahWidget stores resolved ayah in SharedPreferences', () async {
      final date = DateTime(2026, 4, 15);
      await WidgetBridge.updateAyahWidget(date);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString(WidgetBridge.keyDailyAyahArabic), isNotEmpty);
      expect(prefs.getString(WidgetBridge.keyDailyAyahTranslation), isNotEmpty);
      expect(prefs.getString(WidgetBridge.keyDailyAyahRef), isNotEmpty);
      expect(prefs.getInt(WidgetBridge.keyLastUpdated), isNotNull);
    });
  });
}
