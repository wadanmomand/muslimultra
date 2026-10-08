import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/prayer_time_engine.dart';
import 'package:muslim_ultra/features/prayer/data/services/prayer_storage_service.dart';
import 'package:muslim_ultra/features/prayer/data/services/notification_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrayerNotificationSettings Model Tests', () {
    test('Default values match spec expectations', () {
      const settings = PrayerNotificationSettings();
      expect(settings.enableFajr, isTrue);
      expect(settings.enableSunrise, isFalse);
      expect(settings.enableDhuhr, isTrue);
      expect(settings.enableAsr, isTrue);
      expect(settings.enableMaghrib, isTrue);
      expect(settings.enableIsha, isTrue);
      expect(settings.enablePrePrayerReminder, isFalse);
      expect(settings.prePrayerReminderMinutes, 15);
      expect(settings.enableQuietHours, isFalse);
      expect(settings.quietHoursStartMinutes, 1380); // 23:00
      expect(settings.quietHoursEndMinutes, 300); // 05:00
    });

    test('isPrayerEnabled accurately evaluates per-prayer toggles', () {
      const settings = PrayerNotificationSettings(
        enableFajr: true,
        enableSunrise: false,
        enableDhuhr: false,
        enableAsr: true,
        enableMaghrib: true,
        enableIsha: false,
      );

      expect(settings.isPrayerEnabled('Fajr'), isTrue);
      expect(settings.isPrayerEnabled('fajr'), isTrue);
      expect(settings.isPrayerEnabled('Sunrise'), isFalse);
      expect(settings.isPrayerEnabled('Dhuhr'), isFalse);
      expect(settings.isPrayerEnabled('Asr'), isTrue);
      expect(settings.isPrayerEnabled('Maghrib'), isTrue);
      expect(settings.isPrayerEnabled('Isha'), isFalse);
      expect(settings.isPrayerEnabled('Other'), isTrue);
    });

    test('Quiet hours overnight evaluation (23:00 to 05:00)', () {
      const settings = PrayerNotificationSettings(
        enableQuietHours: true,
        quietHoursStartMinutes: 1380, // 23:00
        quietHoursEndMinutes: 300, // 05:00
      );

      // Exactly at boundary 23:00
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 23, 0)), isTrue);
      // Inside window: 02:30
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 2, 30)), isTrue);
      // Just before end: 04:59
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 4, 59)), isTrue);
      // Exactly at end: 05:00 (out of quiet hours)
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 5, 0)), isFalse);
      // Midday: 13:00
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 13, 0)), isFalse);
    });

    test('Quiet hours same-day evaluation (e.g. 01:00 to 06:00)', () {
      const settings = PrayerNotificationSettings(
        enableQuietHours: true,
        quietHoursStartMinutes: 60, // 01:00
        quietHoursEndMinutes: 360, // 06:00
      );

      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 0, 30)), isFalse);
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 1, 0)), isTrue);
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 4, 0)), isTrue);
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 6, 0)), isFalse);
    });

    test('When quiet hours are disabled, isInQuietHours always returns false', () {
      const settings = PrayerNotificationSettings(
        enableQuietHours: false,
        quietHoursStartMinutes: 1380,
        quietHoursEndMinutes: 300,
      );

      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 23, 30)), isFalse);
      expect(settings.isInQuietHours(DateTime(2026, 5, 10, 3, 0)), isFalse);
    });

    test('copyWith properly updates pre-prayer reminder and flags', () {
      const initial = PrayerNotificationSettings();
      final updated = initial.copyWith(
        enablePrePrayerReminder: true,
        prePrayerReminderMinutes: 20,
        enableFajr: false,
      );

      expect(updated.enablePrePrayerReminder, isTrue);
      expect(updated.prePrayerReminderMinutes, 20);
      expect(updated.enableFajr, isFalse);
      expect(updated.enableDhuhr, isTrue);
    });
  });

  group('PrayerStorageService Persistence Tests', () {
    test('Saves and loads full notification settings correctly', () async {
      SharedPreferences.setMockInitialValues({});

      final customSettings = const PrayerNotificationSettings(
        enableFajr: true,
        enableSunrise: true,
        enableDhuhr: false,
        enableAsr: true,
        enableMaghrib: false,
        enableIsha: true,
        enablePrePrayerReminder: true,
        prePrayerReminderMinutes: 15,
        enableQuietHours: true,
        quietHoursStartMinutes: 1320, // 22:00
        quietHoursEndMinutes: 360, // 06:00
      );

      await PrayerStorageService.saveNotificationSettings(customSettings);
      final loaded = await PrayerStorageService.loadNotificationSettings();

      expect(loaded.enableFajr, isTrue);
      expect(loaded.enableSunrise, isTrue);
      expect(loaded.enableDhuhr, isFalse);
      expect(loaded.enableAsr, isTrue);
      expect(loaded.enableMaghrib, isFalse);
      expect(loaded.enableIsha, isTrue);
      expect(loaded.enablePrePrayerReminder, isTrue);
      expect(loaded.prePrayerReminderMinutes, 15);
      expect(loaded.enableQuietHours, isTrue);
      expect(loaded.quietHoursStartMinutes, 1320);
      expect(loaded.quietHoursEndMinutes, 360);
    });
  });

  group('Rolling Schedule Window Calculation Tests', () {
    test('Calculates tomorrow schedule independently with proper date and tomorrow Fajr', () {
      final today = DateTime(2026, 5, 10, 15, 0); // 3:00 PM
      final tomorrow = today.add(const Duration(days: 1));

      final todaySchedule = PrayerTimeEngine.calculate(
        date: today,
        latitude: 24.8607,
        longitude: 67.0011,
        timezoneOffsetHours: 5.0,
        locationName: 'Karachi',
        parameters: const PrayerCalculationParameters(method: CalculationMethod.karachi),
      );

      final tomorrowSchedule = PrayerTimeEngine.calculate(
        date: tomorrow,
        latitude: 24.8607,
        longitude: 67.0011,
        timezoneOffsetHours: 5.0,
        locationName: 'Karachi',
        parameters: const PrayerCalculationParameters(method: CalculationMethod.karachi),
      );

      // Tomorrow Fajr must be on the next calendar day
      expect(tomorrowSchedule.fajr.day, tomorrow.day);
      expect(tomorrowSchedule.fajr.month, tomorrow.month);
      expect(tomorrowSchedule.fajr.isAfter(todaySchedule.fajr), isTrue);

      // Tomorrow Fajr is ~24 hours after today's Fajr
      final diff = tomorrowSchedule.fajr.difference(todaySchedule.fajr);
      expect(diff.inHours, inInclusiveRange(23, 25));
    });

    test('PrayerNotificationService executes safely in test environment without crashing', () async {
      final today = DateTime.now();
      final tomorrow = today.add(const Duration(days: 1));

      final todaySchedule = PrayerTimeEngine.calculate(
        date: today,
        latitude: 24.8607,
        longitude: 67.0011,
        timezoneOffsetHours: 5.0,
        locationName: 'Karachi',
        parameters: const PrayerCalculationParameters(method: CalculationMethod.karachi),
      );

      final tomorrowSchedule = PrayerTimeEngine.calculate(
        date: tomorrow,
        latitude: 24.8607,
        longitude: 67.0011,
        timezoneOffsetHours: 5.0,
        locationName: 'Karachi',
        parameters: const PrayerCalculationParameters(method: CalculationMethod.karachi),
      );

      // Should complete without throwing exceptions
      await PrayerNotificationService.schedulePrayerNotifications(
        schedule: todaySchedule,
        tomorrowSchedule: tomorrowSchedule,
        settings: const PrayerNotificationSettings(
          enablePrePrayerReminder: true,
          enableQuietHours: true,
        ),
      );

      final canSchedule = await PrayerNotificationService.canScheduleExactAlarms();
      expect(canSchedule, isNotNull);
    });
  });
}
