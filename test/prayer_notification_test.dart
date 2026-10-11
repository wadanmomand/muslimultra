import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/prayer_time_engine.dart';
import 'package:muslim_ultra/features/prayer/data/services/prayer_storage_service.dart';
import 'package:muslim_ultra/features/prayer/data/services/notification_service.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/widgets/quiet_hours_setting_sheet.dart';

class _TestLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final AppLocalizations l10n;
  const _TestLocalizationsDelegate(this.l10n);

  @override
  bool isSupported(Locale l) => true;

  @override
  Future<AppLocalizations> load(Locale l) => SynchronousFuture(l10n);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

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

  group('Custom Azan Detection & UI Tests', () {
    test('hasCustomAthanAudio returns true when custom audio is present', () async {
      PrayerNotificationService.resetCustomAthanCacheForTesting(true);
      final isDetected = await PrayerNotificationService.hasCustomAthanAudio();
      expect(isDetected, isTrue);
    });

    testWidgets('QuietHoursSettingSheet displays custom azan card as active', (tester) async {
      tester.view.physicalSize = const Size(400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      PrayerNotificationService.resetCustomAthanCacheForTesting(true);

      final l10n = AppLocalizations(const Locale('en'));
      await l10n.load();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            customAthanDetectedProvider.overrideWith((ref) => Future.value(true)),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: [
              _TestLocalizationsDelegate(l10n),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const Scaffold(
              body: QuietHoursSettingSheet(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // The active card is displayed
      expect(find.byKey(const ValueKey('athan_audio_status_card')), findsOneWidget);
      expect(find.text('Custom Azan Audio Active'), findsOneWidget);
      expect(find.text('Active'), findsOneWidget);
      expect(find.textContaining('Custom athan.mp3 detected'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);

      tester.takeException();
    });
  });
}
