import 'hijri_day_data.dart';
import 'hijri_event.dart';

/// Represents a complete Hijri month with all its days and associated events
class HijriMonthData {
  final int hijriYear;
  final int hijriMonth;
  final String monthNameEn;
  final String monthNameAr;
  final String monthNameUr;
  final List<HijriDayData> days;
  final DateTime gregorianStartDate;
  final DateTime gregorianEndDate;
  final int offsetApplied;

  const HijriMonthData({
    required this.hijriYear,
    required this.hijriMonth,
    required this.monthNameEn,
    required this.monthNameAr,
    required this.monthNameUr,
    required this.days,
    required this.gregorianStartDate,
    required this.gregorianEndDate,
    this.offsetApplied = 0,
  });

  int get daysInMonth => days.length;
  int get startWeekday => days.isNotEmpty ? days.first.weekday : 1; // 1 = Monday .. 7 = Sunday

  String localizedMonthName(String langCode) {
    if (langCode.startsWith('ar')) return monthNameAr;
    if (langCode.startsWith('ur')) return monthNameUr;
    return monthNameEn;
  }

  /// All unique events occurring in this Hijri month
  List<HijriEvent> get allEvents {
    final list = <HijriEvent>[];
    for (final day in days) {
      for (final event in day.events) {
        if (!event.isNewMonthMarker && !list.any((e) => e.id == event.id)) {
          list.add(event);
        }
      }
    }
    return list;
  }
}
