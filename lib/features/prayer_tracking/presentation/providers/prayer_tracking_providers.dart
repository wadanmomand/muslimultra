import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/prayer_tracking/data/prayer_tracking_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/widgets/widget_bridge.dart';

/// Repository provider
final prayerTrackingRepositoryProvider = Provider<PrayerTrackingRepository>((ref) {
  return PrayerTrackingRepository();
});

/// Currently selected date in the tracker screen (default: today)
final selectedTrackerDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});

/// Revision counter to refresh future providers when a prayer is logged
final prayerLogRevisionProvider = StateProvider<int>((ref) => 0);

/// Prayer logs for the selected date
final prayerLogsForSelectedDateProvider =
    FutureProvider<Map<String, PrayerLogEntry>>((ref) async {
  ref.watch(prayerLogRevisionProvider);
  final repo = ref.watch(prayerTrackingRepositoryProvider);
  final selectedDate = ref.watch(selectedTrackerDateProvider);
  final dateStr = PrayerTrackingRepository.formatDate(selectedDate);
  return repo.getEntriesForDate(dateStr);
});

/// Current streak provider
final currentPrayerStreakProvider = FutureProvider<int>((ref) async {
  ref.watch(prayerLogRevisionProvider);
  final repo = ref.watch(prayerTrackingRepositoryProvider);
  return repo.currentStreak();
});

/// Best streak provider
final bestPrayerStreakProvider = FutureProvider<int>((ref) async {
  ref.watch(prayerLogRevisionProvider);
  final repo = ref.watch(prayerTrackingRepositoryProvider);
  return repo.bestStreak();
});

/// Weekly stats provider
final weeklyPrayerStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(prayerLogRevisionProvider);
  final repo = ref.watch(prayerTrackingRepositoryProvider);
  final selectedDate = ref.watch(selectedTrackerDateProvider);
  return repo.weeklyStats(selectedDate);
});

/// Monthly consistency provider
final monthlyPrayerConsistencyProvider = FutureProvider<double>((ref) async {
  ref.watch(prayerLogRevisionProvider);
  final repo = ref.watch(prayerTrackingRepositoryProvider);
  final selectedDate = ref.watch(selectedTrackerDateProvider);
  return repo.monthlyConsistency(selectedDate);
});

/// Controller to log or change prayer status
class PrayerLogController {
  final Ref ref;
  PrayerLogController(this.ref);

  Future<void> setPrayerStatus({
    required DateTime date,
    required String prayer,
    required PrayerLogStatus status,
  }) async {
    final repo = ref.read(prayerTrackingRepositoryProvider);
    final dateStr = PrayerTrackingRepository.formatDate(date);

    final entry = PrayerLogEntry(
      date: dateStr,
      prayer: prayer.toLowerCase(),
      status: status,
      timestamp: DateTime.now(),
    );

    await repo.logPrayer(entry);

    // Bump revision to update all dependent providers
    ref.read(prayerLogRevisionProvider.notifier).state++;

    // Notify Android Home-Screen Widgets of changes
    try {
      await WidgetBridge.updatePrayerWidget();
    } catch (_) {}
  }
}

final prayerLogControllerProvider = Provider<PrayerLogController>((ref) {
  return PrayerLogController(ref);
});
