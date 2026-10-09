import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/hijri/data/hijri_calendar_service.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_day_data.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_month_data.dart';

/// Target displayed Hijri year and month
class HijriMonthQuery {
  final int year;
  final int month;

  const HijriMonthQuery({required this.year, required this.month});

  HijriMonthQuery previous() {
    if (month == 1) {
      return HijriMonthQuery(year: year - 1, month: 12);
    }
    return HijriMonthQuery(year: year, month: month - 1);
  }

  HijriMonthQuery next() {
    if (month == 12) {
      return HijriMonthQuery(year: year + 1, month: 1);
    }
    return HijriMonthQuery(year: year, month: month + 1);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HijriMonthQuery &&
          runtimeType == other.runtimeType &&
          year == other.year &&
          month == other.month;

  @override
  int get hashCode => year.hashCode ^ month.hashCode;
}

class HijriMonthNotifier extends StateNotifier<HijriMonthQuery> {
  HijriMonthNotifier(super.initial);

  void goToPreviousMonth() {
    state = state.previous();
  }

  void goToNextMonth() {
    state = state.next();
  }

  void setMonth(int year, int month) {
    state = HijriMonthQuery(year: year, month: month);
  }

  void resetToToday(int todayYear, int todayMonth) {
    state = HijriMonthQuery(year: todayYear, month: todayMonth);
  }
}

/// Provider for the currently displayed month
final displayedHijriMonthProvider =
    StateNotifierProvider<HijriMonthNotifier, HijriMonthQuery>((ref) {
  final todayHijri = ref.watch(hijriDateProvider);
  return HijriMonthNotifier(
    HijriMonthQuery(year: todayHijri.year, month: todayHijri.month),
  );
});

/// Provider for selected day inside the current calendar view
final selectedHijriDayProvider = StateProvider<HijriDayData?>((ref) => null);

/// Provider for current month data
final currentHijriMonthDataProvider = Provider<HijriMonthData>((ref) {
  final query = ref.watch(displayedHijriMonthProvider);
  final params = ref.watch(prayerParametersProvider);

  return HijriCalendarService.getMonthData(
    query.year,
    query.month,
    offsetDays: params.hijriOffsetDays,
  );
});

/// Provider for the upcoming major Islamic event countdown
final nextMajorEventProvider = Provider<UpcomingEventInfo?>((ref) {
  final params = ref.watch(prayerParametersProvider);
  return HijriCalendarService.getNextMajorEvent(
    offsetDays: params.hijriOffsetDays,
  );
});
