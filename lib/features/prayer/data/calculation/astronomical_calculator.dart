import 'dart:math' as math;

/// Solar Astronomical Coordinates & Equation of Time Calculator
/// Pure on-device computation implementing standard celestial mechanics.
class SolarCoordinates {
  final double declination; // Solar declination in radians
  final double equationOfTime; // Equation of time in minutes
  final double apparentSolarTransit; // Solar transit (noon) in fractional hours UTC

  const SolarCoordinates({
    required this.declination,
    required this.equationOfTime,
    required this.apparentSolarTransit,
  });
}

class AstronomicalCalculator {
  static const double d2r = math.pi / 180.0;
  static const double r2d = 180.0 / math.pi;

  /// Calculate Julian Date from Gregorian Date
  static double julianDate(int year, int month, int day, [double hours = 12.0]) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100).floor();
    final b = 2 - a + (a / 4).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5 +
        (hours / 24.0);
  }

  /// Calculates Solar Position (Declination, Equation of Time, Transit)
  static SolarCoordinates calculateSolarPosition(DateTime date, double longitude) {
    final jd = julianDate(date.year, date.month, date.day, 12.0);
    final d = jd - 2451545.0; // Days since J2000.0

    // Mean anomaly of the Sun
    final g = fixAngle(357.529 + 0.98560028 * d);

    // Mean longitude of the Sun
    final q = fixAngle(280.459 + 0.98564736 * d);

    // Geocentric apparent ecliptic longitude of the Sun
    final l = fixAngle(q + 1.915 * math.sin(g * d2r) + 0.020 * math.sin(2 * g * d2r));

    // Mean obliquity of the ecliptic
    final e = 23.439 - 0.00000036 * d;

    // Sun's declination
    final sinDeclination = math.sin(e * d2r) * math.sin(l * d2r);
    final declination = math.asin(sinDeclination);

    // Sun's right ascension
    final num = math.cos(e * d2r) * math.sin(l * d2r);
    final den = math.cos(l * d2r);
    var ra = math.atan2(num, den) * r2d;
    ra = fixAngle(ra) / 15.0; // in hours

    // Equation of time in minutes (normalized to [-12, +12] hours)
    var diffRa = (q / 15.0) - ra;
    while (diffRa > 12.0) {
      diffRa -= 24.0;
    }
    while (diffRa < -12.0) {
      diffRa += 24.0;
    }
    final eqt = diffRa * 60.0;

    // Solar transit in fractional hours UTC
    final transitUtc = 12.0 - (longitude / 15.0) - (eqt / 60.0);

    return SolarCoordinates(
      declination: declination,
      equationOfTime: eqt,
      apparentSolarTransit: transitUtc,
    );
  }

  /// Compute Hour Angle for a given solar altitude angle
  static double? computeHourAngle(double latitude, double declination, double angleDegrees) {
    final latRad = latitude * d2r;
    final angleRad = angleDegrees * d2r;

    final cosH = (math.sin(angleRad) - (math.sin(latRad) * math.sin(declination))) /
        (math.cos(latRad) * math.cos(declination));

    if (cosH > 1.0 || cosH < -1.0) {
      // Sun never reaches this angle at this latitude (e.g. extreme polar regions)
      return null;
    }

    return math.acos(cosH) * r2d / 15.0; // In fractional hours
  }

  /// Compute Asr Hour Angle given shadow ratio (Standard = 1, Hanafi = 2)
  static double computeAsrHourAngle(double latitude, double declination, int shadowFactor) {
    final latRad = latitude * d2r;
    // Asr altitude angle above horizon: arccot(t + tan(|latitude - declination|))
    final angleRad = math.atan(1.0 / (shadowFactor + math.tan((latRad - declination).abs())));
    final angleDeg = angleRad * r2d;

    final ha = computeHourAngle(latitude, declination, angleDeg);
    return ha ?? 3.5; // fallback
  }

  /// Normalize angle to 0..360
  static double fixAngle(double angle) {
    var result = angle - 360.0 * (angle / 360.0).floor();
    return result < 0 ? result + 360.0 : result;
  }

  /// Convert fractional hours to DateTime
  static DateTime fractionalHoursToDateTime(DateTime baseDate, double hours, double timezoneOffsetHours) {
    var localHours = hours + timezoneOffsetHours;
    while (localHours < 0) {
      localHours += 24.0;
    }
    while (localHours >= 24) {
      localHours -= 24.0;
    }

    final totalMinutes = (localHours * 60.0).round();
    final h = (totalMinutes ~/ 60) % 24;
    final m = totalMinutes % 60;

    return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m);
  }
}
