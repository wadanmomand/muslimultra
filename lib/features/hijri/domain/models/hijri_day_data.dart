import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'hijri_event.dart';

/// Represents a single cell/day in the Hijri month grid
class HijriDayData {
  final HijriDate hijriDate;
  final DateTime gregorianDate;
  final bool isToday;
  final List<HijriEvent> events;

  const HijriDayData({
    required this.hijriDate,
    required this.gregorianDate,
    required this.isToday,
    required this.events,
  });

  int get hijriDay => hijriDate.day;
  int get hijriMonth => hijriDate.month;
  int get hijriYear => hijriDate.year;
  int get weekday => gregorianDate.weekday; // 1 = Monday, 7 = Sunday

  bool get hasEvent => events.isNotEmpty;
  bool get hasMajorEvent => events.any((e) => e.isMajor);
  bool get hasNamedEvent => events.any((e) => !e.isNewMonthMarker);
}
