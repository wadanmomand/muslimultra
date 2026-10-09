import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/hijri_calculator.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_event.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_day_data.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_month_data.dart';
import 'islamic_events_data.dart';

/// Information about an upcoming Islamic event and days remaining
class UpcomingEventInfo {
  final HijriEvent event;
  final DateTime gregorianDate;
  final HijriDate hijriDate;
  final int daysRemaining;

  const UpcomingEventInfo({
    required this.event,
    required this.gregorianDate,
    required this.hijriDate,
    required this.daysRemaining,
  });
}

/// Service for constructing Hijri months and computing event countdowns
class HijriCalendarService {
  /// Locates the exact Gregorian Date corresponding to Day 1 of [hijriYear]-[hijriMonth]
  static DateTime findGregorianFirstDayOfMonth(int hijriYear, int hijriMonth, {int offsetDays = 0}) {
    final approxGregorianYear = (622 + (hijriYear * 354.367 / 365.2425)).round();
    var searchDate = DateTime(approxGregorianYear, 1, 1).add(
      Duration(days: ((hijriMonth - 1) * 29.53).round()),
    );

    var currentHijri = HijriCalculator.fromGregorian(searchDate, offsetDays: offsetDays);

    // Coarse adjustment jumps
    int safety = 0;
    while (safety++ < 100 &&
        (currentHijri.year < hijriYear || (currentHijri.year == hijriYear && currentHijri.month < hijriMonth))) {
      final diffMonths = (hijriYear - currentHijri.year) * 12 + (hijriMonth - currentHijri.month);
      searchDate = searchDate.add(Duration(days: (diffMonths * 29.5).clamp(1, 400).toInt()));
      currentHijri = HijriCalculator.fromGregorian(searchDate, offsetDays: offsetDays);
    }
    while (safety++ < 200 &&
        (currentHijri.year > hijriYear || (currentHijri.year == hijriYear && currentHijri.month > hijriMonth))) {
      final diffMonths = (currentHijri.year - hijriYear) * 12 + (currentHijri.month - hijriMonth);
      searchDate = searchDate.subtract(Duration(days: (diffMonths * 29.5).clamp(1, 400).toInt()));
      currentHijri = HijriCalculator.fromGregorian(searchDate, offsetDays: offsetDays);
    }

    // Fine adjustment backward if we passed day 1
    while (currentHijri.year == hijriYear && currentHijri.month == hijriMonth && currentHijri.day > 1) {
      searchDate = searchDate.subtract(const Duration(days: 1));
      currentHijri = HijriCalculator.fromGregorian(searchDate, offsetDays: offsetDays);
    }

    // Fine adjustment forward if we stepped before target month
    while (currentHijri.year < hijriYear || (currentHijri.year == hijriYear && currentHijri.month < hijriMonth)) {
      searchDate = searchDate.add(const Duration(days: 1));
      currentHijri = HijriCalculator.fromGregorian(searchDate, offsetDays: offsetDays);
    }

    return DateTime(searchDate.year, searchDate.month, searchDate.day);
  }

  /// Builds complete [HijriMonthData] for a given Hijri month and year
  static HijriMonthData getMonthData(
    int hijriYear,
    int hijriMonth, {
    int offsetDays = 0,
    DateTime? referenceToday,
  }) {
    final firstDay = findGregorianFirstDayOfMonth(hijriYear, hijriMonth, offsetDays: offsetDays);
    final today = referenceToday ?? DateTime.now();
    final todayClean = DateTime(today.year, today.month, today.day);

    final days = <HijriDayData>[];
    var cur = firstDay;

    while (true) {
      final h = HijriCalculator.fromGregorian(cur, offsetDays: offsetDays);
      if (h.year != hijriYear || h.month != hijriMonth) {
        break;
      }

      final isToday = (cur.year == todayClean.year && cur.month == todayClean.month && cur.day == todayClean.day);
      final events = IslamicEventsData.getEventsFor(h.month, h.day);

      days.add(HijriDayData(
        hijriDate: h,
        gregorianDate: cur,
        isToday: isToday,
        events: events,
      ));

      cur = cur.add(const Duration(days: 1));
    }

    final monthIndex = (hijriMonth - 1).clamp(0, 11);
    final monthNameEn = HijriDate.monthsEn[monthIndex];
    final monthNameAr = HijriDate.monthsAr[monthIndex];
    final monthNameUr = HijriDate.monthsUr[monthIndex];

    return HijriMonthData(
      hijriYear: hijriYear,
      hijriMonth: hijriMonth,
      monthNameEn: monthNameEn,
      monthNameAr: monthNameAr,
      monthNameUr: monthNameUr,
      days: days,
      gregorianStartDate: days.first.gregorianDate,
      gregorianEndDate: days.last.gregorianDate,
      offsetApplied: offsetDays,
    );
  }

  /// Calculates the next major Islamic event and days remaining
  static UpcomingEventInfo? getNextMajorEvent({DateTime? fromDate, int offsetDays = 0}) {
    final now = fromDate ?? DateTime.now();
    final todayClean = DateTime(now.year, now.month, now.day);

    // Scan forward day by day up to 365 days
    for (int i = 0; i <= 365; i++) {
      final targetDate = todayClean.add(Duration(days: i));
      final h = HijriCalculator.fromGregorian(targetDate, offsetDays: offsetDays);
      final events = IslamicEventsData.getEventsFor(h.month, h.day);
      final majorEvent = events.where((e) => e.isMajor).firstOrNull;

      if (majorEvent != null) {
        return UpcomingEventInfo(
          event: majorEvent,
          gregorianDate: targetDate,
          hijriDate: h,
          daysRemaining: i,
        );
      }
    }
    return null;
  }
}
