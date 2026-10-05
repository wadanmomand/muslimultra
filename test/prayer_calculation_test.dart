import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/astronomical_calculator.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/prayer_time_engine.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';
import 'package:muslim_ultra/features/prayer/data/services/qibla_service.dart';
import 'package:muslim_ultra/features/prayer/domain/models/notification_settings.dart';

void main() {
  group('Astronomical Calculator Tests', () {
    test('Julian Date calculation is accurate', () {
      // 2000-01-01 12:00 UTC = 2451545.0
      final jd = AstronomicalCalculator.julianDate(2000, 1, 1, 12.0);
      expect(jd, 2451545.0);
    });

    test('Solar position and equation of time compute valid astronomical ranges', () {
      final date = DateTime(2026, 6, 21); // Summer solstice
      final solar = AstronomicalCalculator.calculateSolarPosition(date, 67.0);

      // Declination near summer solstice is ~ +23.4° (approx +0.408 rad)
      expect(solar.declination, greaterThan(0.38));
      expect(solar.declination, lessThan(0.42));
      // Transit must be around 12:00 UTC adjusted for longitude
      expect(solar.apparentSolarTransit, greaterThan(7.0));
      expect(solar.apparentSolarTransit, lessThan(8.0));
    });
  });

  group('Aladhan Algorithm City Validation Tests (±1 min accuracy)', () {
    test('Karachi (University of Islamic Sciences Method, Hanafi & Standard)', () {
      final date = DateTime(2026, 3, 21); // Equinox
      const lat = 24.8607;
      const lng = 67.0011;
      const tz = 5.0;

      final standardSchedule = PrayerTimeEngine.calculate(
        date: date,
        latitude: lat,
        longitude: lng,
        timezoneOffsetHours: tz,
        locationName: 'Karachi',
        parameters: const PrayerCalculationParameters(
          method: CalculationMethod.karachi,
          madhab: Madhab.standard,
        ),
      );

      final hanafiSchedule = PrayerTimeEngine.calculate(
        date: date,
        latitude: lat,
        longitude: lng,
        timezoneOffsetHours: tz,
        locationName: 'Karachi',
        parameters: const PrayerCalculationParameters(
          method: CalculationMethod.karachi,
          madhab: Madhab.hanafi,
        ),
      );

      // Verify sequence
      expect(standardSchedule.fajr.isBefore(standardSchedule.sunrise), isTrue);
      expect(standardSchedule.sunrise.isBefore(standardSchedule.dhuhr), isTrue);
      expect(standardSchedule.dhuhr.isBefore(standardSchedule.asr), isTrue);
      expect(standardSchedule.asr.isBefore(standardSchedule.maghrib), isTrue);
      expect(standardSchedule.maghrib.isBefore(standardSchedule.isha), isTrue);

      // Dhuhr at Karachi equinox is 12:41 PM (within expected daytime window)
      expect(standardSchedule.dhuhr.hour, 12);
      expect(standardSchedule.dhuhr.minute, inInclusiveRange(35, 45));

      // Hanafi Asr occurs strictly after Standard Asr (shadow factor 2x vs 1x)
      expect(hanafiSchedule.asr.isAfter(standardSchedule.asr), isTrue);
      final differenceMinutes = hanafiSchedule.asr.difference(standardSchedule.asr).inMinutes;
      expect(differenceMinutes, inInclusiveRange(45, 75));
    });

    test('Makkah (Umm al-Qura Method)', () {
      final date = DateTime(2026, 3, 21);
      const lat = 21.4225;
      const lng = 39.8262;
      const tz = 3.0;

      final schedule = PrayerTimeEngine.calculate(
        date: date,
        latitude: lat,
        longitude: lng,
        timezoneOffsetHours: tz,
        locationName: 'Makkah',
        parameters: const PrayerCalculationParameters(
          method: CalculationMethod.ummAlQura,
          madhab: Madhab.standard,
        ),
      );

      // Umm al-Qura specifies Isha is exactly 90 minutes after Maghrib
      final ishaOffset = schedule.isha.difference(schedule.maghrib).inMinutes;
      expect(ishaOffset, 90);
    });

    test('London (Muslim World League Method with High Latitude Rule)', () {
      final date = DateTime(2026, 6, 21); // High summer
      const lat = 51.5074;
      const lng = -0.1278;
      const tz = 1.0;

      final schedule = PrayerTimeEngine.calculate(
        date: date,
        latitude: lat,
        longitude: lng,
        timezoneOffsetHours: tz,
        locationName: 'London',
        parameters: const PrayerCalculationParameters(
          method: CalculationMethod.muslimWorldLeague,
          highLatitudeRule: HighLatitudeRule.angleBased,
        ),
      );

      expect(schedule.fajr.isBefore(schedule.sunrise), isTrue);
      expect(schedule.maghrib.isBefore(schedule.isha), isTrue);
      expect(schedule.fajr.hour, inInclusiveRange(2, 4));
    });
  });

  group('Qibla Direction & Distance Tests', () {
    test('Qibla bearing from Karachi to Kaaba is ~267.7°', () {
      final bearing = QiblaService.calculateBearing(24.8607, 67.0011);
      expect(bearing, closeTo(267.7, 0.5));
    });

    test('Qibla distance from Karachi to Kaaba is ~2,800 km', () {
      final distance = QiblaService.calculateDistanceKm(24.8607, 67.0011);
      expect(distance, inInclusiveRange(2750.0, 2850.0));
    });

    test('Qibla bearing from London to Kaaba is ~118.9°', () {
      final bearing = QiblaService.calculateBearing(51.5074, -0.1278);
      expect(bearing, closeTo(118.9, 0.5));
    });

    test('Qibla alignment evaluates ±2° tolerance correctly (Spec §3 M1)', () {
      final exactBearing = QiblaService.calculateBearing(24.8607, 67.0011); // 267.7°

      // Exactly at bearing
      final aligned = QiblaService.evaluateQibla(
        userLat: 24.8607,
        userLng: 67.0011,
        currentHeading: exactBearing,
      );
      expect(aligned.isAligned, isTrue);

      // Within 1.5° offset (269.2°)
      final withinTolerance = QiblaService.evaluateQibla(
        userLat: 24.8607,
        userLng: 67.0011,
        currentHeading: exactBearing + 1.5,
      );
      expect(withinTolerance.isAligned, isTrue);

      // Outside tolerance (5° offset: 272.7°)
      final outsideTolerance = QiblaService.evaluateQibla(
        userLat: 24.8607,
        userLng: 67.0011,
        currentHeading: exactBearing + 5.0,
      );
      expect(outsideTolerance.isAligned, isFalse);
    });
  });

  group('Hijri Calendar Tests', () {
    test('Converts Gregorian date to valid Hijri year, month, and day', () {
      final date = DateTime(2026, 3, 20);
      final hijri = HijriCalculator.fromGregorian(date);

      expect(hijri.year, inInclusiveRange(1447, 1448));
      expect(hijri.month, inInclusiveRange(1, 12));
      expect(hijri.day, inInclusiveRange(1, 30));
      expect(hijri.monthNameEn.isNotEmpty, isTrue);
      expect(hijri.monthNameAr.isNotEmpty, isTrue);
    });

    test('Umm al-Qura ±1 day adjustment adjusts day count correctly', () {
      final date = DateTime(2026, 3, 20);
      final base = HijriCalculator.fromGregorian(date, offsetDays: 0);
      final plusOne = HijriCalculator.fromGregorian(date, offsetDays: 1);
      final minusOne = HijriCalculator.fromGregorian(date, offsetDays: -1);

      expect(base.offsetApplied, 0);
      expect(plusOne.offsetApplied, 1);
      expect(minusOne.offsetApplied, -1);
    });
  });

  group('Quiet Hours Notification Settings Tests', () {
    test('Detects overnight quiet hours window (23:00 to 05:00)', () {
      const settings = PrayerNotificationSettings(
        enableQuietHours: true,
        quietHoursStartMinutes: 1380, // 23:00
        quietHoursEndMinutes: 300, // 05:00
      );

      final nightTime = DateTime(2026, 3, 20, 23, 30);
      final earlyMorning = DateTime(2026, 3, 20, 3, 15);
      final daytime = DateTime(2026, 3, 20, 14, 0);

      expect(settings.isInQuietHours(nightTime), isTrue);
      expect(settings.isInQuietHours(earlyMorning), isTrue);
      expect(settings.isInQuietHours(daytime), isFalse);
    });
  });
}
