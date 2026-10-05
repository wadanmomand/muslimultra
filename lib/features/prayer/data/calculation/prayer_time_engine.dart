import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/domain/models/prayer_time.dart';
import 'astronomical_calculator.dart';

/// Comprehensive Prayer Time Engine (Spec §3 M1)
/// Implements and calibrates the exact astronomical calculation algorithms.
class PrayerTimeEngine {
  /// Standard atmospheric refraction and solar disc radius angle for Sunrise/Sunset
  static const double standardSolarDepression = -0.8333;

  /// Calculate prayer schedule for a given date, coordinates, and calculation parameters
  static PrayerSchedule calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required double timezoneOffsetHours,
    required String locationName,
    PrayerCalculationParameters parameters = const PrayerCalculationParameters(),
  }) {
    // 1. Calculate Solar Coordinates at midday
    final solar = AstronomicalCalculator.calculateSolarPosition(date, longitude);
    final transit = solar.apparentSolarTransit; // Fractional UTC hours

    // 2. Compute Hour Angles for each prayer phase
    // Sunrise & Sunset
    final sunriseSunsetHa = AstronomicalCalculator.computeHourAngle(
          latitude,
          solar.declination,
          standardSolarDepression,
        ) ??
        6.0;

    // Fajr Hour Angle
    var fajrHa = AstronomicalCalculator.computeHourAngle(
      latitude,
      solar.declination,
      -parameters.method.fajrAngle,
    );

    // Isha Hour Angle (if angle-based)
    double? ishaHa;
    if (parameters.method.ishaAngle != null) {
      ishaHa = AstronomicalCalculator.computeHourAngle(
        latitude,
        solar.declination,
        -parameters.method.ishaAngle!,
      );
    }

    // High Latitude Adjustments (if sun doesn't reach twilight angles)
    final nightDurationHours = (24.0 - (2.0 * sunriseSunsetHa)).abs();

    fajrHa ??= _applyHighLatitudeRule(
      parameters.highLatitudeRule,
      parameters.method.fajrAngle,
      sunriseSunsetHa,
      nightDurationHours,
    );

    if (ishaHa == null && parameters.method.ishaAngle != null) {
      ishaHa = _applyHighLatitudeRule(
        parameters.highLatitudeRule,
        parameters.method.ishaAngle!,
        sunriseSunsetHa,
        nightDurationHours,
      );
    }

    // Asr Hour Angle based on Madhab shadow factor
    final asrHa = AstronomicalCalculator.computeAsrHourAngle(
      latitude,
      solar.declination,
      parameters.madhab.shadowFactor,
    );

    // 3. Raw times in fractional hours UTC
    final fajrUtc = transit - fajrHa;
    final sunriseUtc = transit - sunriseSunsetHa;
    final dhuhrUtc = transit + (1.0 / 60.0); // +1 min after solar noon (safe Zawaal)
    final asrUtc = transit + asrHa;
    final sunsetUtc = transit + sunriseSunsetHa;
    final maghribUtc = sunsetUtc; // Sunset equals Maghrib in standard Fiqh

    double ishaUtc;
    if (parameters.method.ishaInterval != null) {
      // e.g. Umm al-Qura: 90 minutes after Maghrib
      ishaUtc = maghribUtc + (parameters.method.ishaInterval! / 60.0);
    } else {
      ishaUtc = transit + (ishaHa ?? 1.5);
    }

    // 4. Convert UTC fractional hours to local DateTime objects
    var fajrDt = AstronomicalCalculator.fractionalHoursToDateTime(date, fajrUtc, timezoneOffsetHours);
    var sunriseDt = AstronomicalCalculator.fractionalHoursToDateTime(date, sunriseUtc, timezoneOffsetHours);
    var dhuhrDt = AstronomicalCalculator.fractionalHoursToDateTime(date, dhuhrUtc, timezoneOffsetHours);
    var asrDt = AstronomicalCalculator.fractionalHoursToDateTime(date, asrUtc, timezoneOffsetHours);
    var maghribDt = AstronomicalCalculator.fractionalHoursToDateTime(date, maghribUtc, timezoneOffsetHours);
    var ishaDt = AstronomicalCalculator.fractionalHoursToDateTime(date, ishaUtc, timezoneOffsetHours);

    // Method specific fine-tuning (e.g. Diyanet Turkey adjustments if chosen)
    if (parameters.method == CalculationMethod.diyanet) {
      // Diyanet applies standard -7 min Fajr/Sunrise & +7 min Sunset/Maghrib adjustments
      fajrDt = fajrDt.subtract(const Duration(minutes: 1));
      maghribDt = maghribDt.add(const Duration(minutes: 1));
    }

    return PrayerSchedule(
      date: date,
      fajr: fajrDt,
      sunrise: sunriseDt,
      dhuhr: dhuhrDt,
      asr: asrDt,
      maghrib: maghribDt,
      isha: ishaDt,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
    );
  }

  static double _applyHighLatitudeRule(
    HighLatitudeRule rule,
    double angle,
    double sunriseSunsetHa,
    double nightDurationHours,
  ) {
    switch (rule) {
      case HighLatitudeRule.middleOfTheNight:
        return sunriseSunsetHa + (nightDurationHours / 2.0);
      case HighLatitudeRule.oneSeventh:
        return sunriseSunsetHa + (nightDurationHours / 7.0);
      case HighLatitudeRule.angleBased:
        final portion = angle / 60.0;
        return sunriseSunsetHa + (portion * nightDurationHours);
    }
  }
}
