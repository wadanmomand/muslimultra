import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fast_log_entry.dart';
import 'package:muslim_ultra/features/fasting/domain/models/fasting_countdown_state.dart';
import 'package:muslim_ultra/features/fasting/data/fasting_repository.dart';

final fastingRepositoryProvider = Provider<FastingRepository>((ref) {
  return FastingRepository();
});

/// StateNotifier for managing the list of logged fasts
class FastLogNotifier extends StateNotifier<List<FastLogEntry>> {
  final FastingRepository _repository;

  FastLogNotifier(this._repository) : super([]) {
    load();
  }

  Future<void> load() async {
    final entries = await _repository.loadLogEntries();
    state = entries;
  }

  Future<void> saveEntry(FastLogEntry entry) async {
    await _repository.saveLogEntry(entry);
    await load();
  }

  Future<void> deleteEntry(String dateKey) async {
    await _repository.deleteLogEntry(dateKey);
    await load();
  }
}

final fastLogEntriesProvider =
    StateNotifierProvider<FastLogNotifier, List<FastLogEntry>>((ref) {
  final repo = ref.watch(fastingRepositoryProvider);
  return FastLogNotifier(repo);
});

/// StateNotifier for today's fasting intention toggle
class FastingIntentionNotifier extends StateNotifier<bool> {
  final FastingRepository _repository;
  final String _todayKey;

  FastingIntentionNotifier(this._repository, this._todayKey) : super(false) {
    _init();
  }

  Future<void> _init() async {
    final isFasting = await _repository.getFastingIntention(_todayKey);
    state = isFasting;
  }

  Future<void> toggle() async {
    final updated = !state;
    state = updated;
    await _repository.setFastingIntention(_todayKey, updated);
  }

  Future<void> setIntention(bool isFasting) async {
    state = isFasting;
    await _repository.setFastingIntention(_todayKey, isFasting);
  }
}

final todayDateKeyProvider = Provider<String>((ref) {
  final now = DateTime.now();
  final y = now.year.toString().padLeft(4, '0');
  final m = now.month.toString().padLeft(2, '0');
  final d = now.day.toString().padLeft(2, '0');
  return '$y-$m-$d';
});

final fastingIntentionProvider =
    StateNotifierProvider<FastingIntentionNotifier, bool>((ref) {
  final repo = ref.watch(fastingRepositoryProvider);
  final todayKey = ref.watch(todayDateKeyProvider);
  return FastingIntentionNotifier(repo, todayKey);
});

/// Real-time live countdown state for fasting (Suhoor / Iftar / Completed)
final liveFastingCountdownProvider =
    Provider.autoDispose<FastingCountdownState>((ref) {
  // Trigger tick every second
  ref.watch(countdownTickProvider);

  final schedule = ref.watch(prayerScheduleProvider);
  final now = DateTime.now();

  return FastingCountdownState.compute(
    now: now,
    fajr: schedule.fajr,
    maghrib: schedule.maghrib,
  );
});

/// Computed statistics for fasting
class FastingStats {
  final int streak;
  final int fastsThisMonth;
  final int makeupDaysOwed;

  const FastingStats({
    required this.streak,
    required this.fastsThisMonth,
    required this.makeupDaysOwed,
  });
}

final fastingStatsProvider = Provider<FastingStats>((ref) {
  final entries = ref.watch(fastLogEntriesProvider);
  final hijri = ref.watch(hijriDateProvider);

  final streak = FastingRepository.calculateStreak(entries);
  final fastsThisMonth = FastingRepository.calculateFastsThisMonth(
    entries,
    hijri.month,
    hijri.year,
  );
  final makeupOwed = FastingRepository.calculateMakeupDaysOwed(entries);

  return FastingStats(
    streak: streak,
    fastsThisMonth: fastsThisMonth,
    makeupDaysOwed: makeupOwed,
  );
});

/// Indicates if current Hijri month is Ramadan (Month 9)
final isRamadanActiveProvider = Provider<bool>((ref) {
  final hijri = ref.watch(hijriDateProvider);
  return hijri.month == 9;
});
