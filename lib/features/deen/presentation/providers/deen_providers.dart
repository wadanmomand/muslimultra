import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/deen/data/activity_heatmap.dart';
import 'package:muslim_ultra/features/deen/data/checkin_reminder.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/deen/data/deen_score.dart';
import 'package:muslim_ultra/features/deen/data/milestones.dart';
import 'package:muslim_ultra/features/deen/data/weekly_report.dart';
import 'package:muslim_ultra/features/deen/domain/models/deen_xp.dart';
import 'package:muslim_ultra/features/fasting/data/fasting_repository.dart';
import 'package:muslim_ultra/features/fasting/presentation/providers/fasting_providers.dart';
import 'package:muslim_ultra/features/prayer_tracking/data/prayer_tracking_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/providers/prayer_tracking_providers.dart';
import 'package:muslim_ultra/features/quiz/presentation/providers/quiz_providers.dart';

final deenRepositoryProvider = Provider<DeenRepository>((ref) {
  return DeenRepository();
});

final deenXpProvider = FutureProvider<DeenXp>((ref) async {
  final repo = ref.watch(deenRepositoryProvider);
  return repo.getDeenXp();
});

final dailyDeenStateProvider = FutureProvider<DailyDeenState>((ref) async {
  final repo = ref.watch(deenRepositoryProvider);
  return repo.getDailyState();
});

final isFreezeAvailableProvider = FutureProvider<bool>((ref) async {
  final repo = ref.watch(deenRepositoryProvider);
  return repo.isFreezeAvailable();
});

final milestoneRepositoryProvider = Provider<MilestoneRepository>((ref) {
  return MilestoneRepository();
});

final uncelebratedMilestonesProvider = FutureProvider<List<Milestone>>((ref) async {
  final prayerRepo = ref.watch(prayerTrackingRepositoryProvider);
  final fastingRepo = ref.watch(fastingRepositoryProvider);
  final deenRepo = ref.watch(deenRepositoryProvider);
  final milestoneRepo = ref.watch(milestoneRepositoryProvider);

  final now = DateTime.now();
  final prayerStreak = await prayerRepo.currentStreak(now);

  final fastLogs = await fastingRepo.loadLogEntries();
  final fastingStreak = FastingRepository.calculateStreak(fastLogs, referenceToday: now);

  final xp = await deenRepo.getDeenXp();

  // Check khatmah completion
  final khatmahList = await deenRepo.getAllDailyStates();
  final hasCompletedKhatmah = khatmahList.values.any((s) => s.quranMinutes >= 600);

  // Celebrated IDs
  final celebrated = await milestoneRepo.getCelebratedMilestones();

  return checkMilestones(
    prayerStreak: prayerStreak,
    fastingStreak: fastingStreak,
    totalXp: xp.totalXp,
    hasCompletedKhatmah: hasCompletedKhatmah,
    quizStreak: 0,
    alreadyCelebratedIds: celebrated,
  );
});

final dailyDeenScoreProvider = FutureProvider<DeenScoreBreakdown>((ref) async {
  final prayerRepo = ref.watch(prayerTrackingRepositoryProvider);
  final deenRepo = ref.watch(deenRepositoryProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);

  final now = DateTime.now();
  final dateStr = PrayerTrackingRepository.formatDate(now);

  final prayerMap = await prayerRepo.getEntriesForDate(dateStr);
  final prayersPrayed = prayerMap.values
      .where((e) => e.status == PrayerLogStatus.prayed)
      .length;

  final dailyState = await deenRepo.getDailyState(now);
  final quizRecord = await quizRepo.getAnswerForDay(now);

  return calculateDailyDeenScore(
    prayersPrayed: prayersPrayed,
    quranMinutes: dailyState.quranMinutes,
    dhikrDone: dailyState.morningDhikr || dailyState.eveningDhikr,
    quizAnswered: quizRecord != null,
    learningViewed: dailyState.learningViewed,
  );
});

final activityHeatmapProvider = FutureProvider<List<DayActivity>>((ref) async {
  final prayerRepo = ref.watch(prayerTrackingRepositoryProvider);
  final fastingRepo = ref.watch(fastingRepositoryProvider);
  final deenRepo = ref.watch(deenRepositoryProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);

  final prayerEntries = await prayerRepo.getAllEntries();
  final prayersMap = <String, int>{};
  for (final e in prayerEntries) {
    if (e.status == PrayerLogStatus.prayed) {
      prayersMap[e.date] = (prayersMap[e.date] ?? 0) + 1;
    }
  }

  final fastLogs = await fastingRepo.loadLogEntries();
  final fastsKeptSet = <String>{};
  for (final f in fastLogs) {
    if (f.isKept || f.isQada) {
      fastsKeptSet.add(f.dateKey);
    }
  }

  final dailyMap = await deenRepo.getAllDailyStates();
  final quranMap = <String, int>{};
  final dhikrSet = <String>{};
  for (final entry in dailyMap.entries) {
    final key = entry.key;
    final state = entry.value;
    if (state.quranMinutes > 0) {
      quranMap[key] = state.quranMinutes;
    }
    if (state.morningDhikr || state.eveningDhikr) {
      dhikrSet.add(key);
    }
  }

  final quizDoneSet = <String>{};
  final now = DateTime.now();
  for (var i = 0; i < 365; i++) {
    final day = now.subtract(Duration(days: i));
    final rec = await quizRepo.getAnswerForDay(day);
    if (rec != null) {
      final key = PrayerTrackingRepository.formatDate(day);
      quizDoneSet.add(key);
    }
  }

  return ActivityHeatmapService.buildHeatmap(
    prayersMap: prayersMap,
    fastsKeptSet: fastsKeptSet,
    quranMinutesMap: quranMap,
    dhikrDoneSet: dhikrSet,
    quizDoneSet: quizDoneSet,
    endDate: now,
    totalWeeks: 53,
  );
});

final checkinReminderEnabledProvider = FutureProvider<bool>((ref) async {
  return CheckinReminderService.isReminderEnabled();
});

final weeklyReportProvider = FutureProvider<WeeklyDeenReport>((ref) async {
  final deenRepo = ref.watch(deenRepositoryProvider);
  final prayerRepo = ref.watch(prayerTrackingRepositoryProvider);
  final quizRepo = ref.watch(quizRepositoryProvider);

  final now = DateTime.now();
  final prayerStats = await prayerRepo.weeklyStats(now);
  final prayersDone = (prayerStats['totalPrayed'] as num?)?.toInt() ?? 0;
  final currStreak = await prayerRepo.currentStreak(now);
  final bestStreak = await prayerRepo.bestStreak();

  var quranMinutes = 0;
  var quizCorrect = 0;
  var quizTotal = 0;

  for (var i = 0; i < 7; i++) {
    final day = now.subtract(Duration(days: i));
    final dailyState = await deenRepo.getDailyState(day);
    quranMinutes += dailyState.quranMinutes;

    final quizRecord = await quizRepo.getAnswerForDay(day);
    if (quizRecord != null) {
      quizTotal++;
      if (quizRecord.isCorrect) quizCorrect++;
    }
  }

  // Estimated XP earned this week
  final xpEarned = (prayersDone * 10) + quranMinutes + (quizCorrect * 20);

  return WeeklyDeenReport(
    prayersDone: prayersDone,
    prayersTotal: 35,
    quranMinutes: quranMinutes,
    xpEarned: xpEarned,
    currentStreak: currStreak,
    bestStreak: bestStreak,
    quizCorrect: quizCorrect,
    quizTotal: quizTotal > 0 ? quizTotal : 7,
  );
});

class DeenController {
  final Ref ref;
  final DeenRepository repo;

  DeenController(this.ref, this.repo);

  Future<void> toggleMorningDhikr(bool done) async {
    await repo.setMorningDhikr(done);
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(dailyDeenScoreProvider);
    ref.invalidate(deenXpProvider);
    ref.invalidate(activityHeatmapProvider);
  }

  Future<void> toggleEveningDhikr(bool done) async {
    await repo.setEveningDhikr(done);
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(dailyDeenScoreProvider);
    ref.invalidate(deenXpProvider);
    ref.invalidate(activityHeatmapProvider);
  }

  Future<void> addQuranMinutes(int minutes) async {
    await repo.addQuranMinutes(minutes);
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(dailyDeenScoreProvider);
    ref.invalidate(deenXpProvider);
    ref.invalidate(activityHeatmapProvider);
  }

  Future<void> markLearningViewed() async {
    await repo.setLearningViewed();
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(dailyDeenScoreProvider);
    ref.invalidate(deenXpProvider);
  }

  Future<bool> useStreakFreeze(DateTime date) async {
    final success = await repo.useFreeze(date);
    if (success) {
      ref.invalidate(isFreezeAvailableProvider);
    }
    return success;
  }

  Future<void> setEveningReminder(bool enabled) async {
    await CheckinReminderService.setReminderEnabled(enabled);
    ref.invalidate(checkinReminderEnabledProvider);
  }
}

final deenControllerProvider = Provider<DeenController>((ref) {
  final repo = ref.watch(deenRepositoryProvider);
  return DeenController(ref, repo);
});
