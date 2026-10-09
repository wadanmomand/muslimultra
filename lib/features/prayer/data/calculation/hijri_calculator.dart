import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'astronomical_calculator.dart';

/// Hijri Calendar Conversion Engine (Spec §3 M1)
/// Implements standard Umm al-Qura algorithmic approximation with ±1 day adjustment.
class HijriCalculator {
  /// Convert Gregorian Date to HijriDate with optional day offset (±1 day)
  static HijriDate fromGregorian(DateTime gregorianDate, {int offsetDays = 0}) {
    final adjustedDate = gregorianDate.add(Duration(days: offsetDays));

    final jd = AstronomicalCalculator.julianDate(
      adjustedDate.year,
      adjustedDate.month,
      adjustedDate.day,
      12.0,
    );

    // Julian day to Islamic calendar conversion (Kuwaiti Algorithm / Umm al-Qura approximation)
    final l = (jd - 1948440 + 10632).floor();
    final n = ((l - 1) / 10631).floor();
    final l2 = l - 10631 * n + 354;
    final j = (((10985 - l2) / 5316).floor()) * (((50 * l2) / 17719).floor()) +
        ((l2 / 5670).floor()) * (((43 * l2) / 15238).floor());
    final l3 = l2 -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final m = ((24 * l3) / 709).floor();
    final d = l3 - ((709 * m) / 24).floor();
    final y = 30 * n + j - 30;

    final monthIndex = (m - 1).clamp(0, 11);
    final dayOfWeekNames = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final dayOfWeek = dayOfWeekNames[gregorianDate.weekday - 1];

    return HijriDate(
      year: y,
      month: m,
      day: d,
      monthNameEn: HijriDate.monthsEn[monthIndex],
      monthNameAr: HijriDate.monthsAr[monthIndex],
      monthNameUr: HijriDate.monthsUr[monthIndex],
      dayOfWeek: dayOfWeek,
      offsetApplied: offsetDays,
    );
  }
}
