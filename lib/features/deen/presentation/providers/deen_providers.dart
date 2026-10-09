import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/deen/data/weekly_report.dart';
import 'package:muslim_ultra/features/deen/domain/models/deen_xp.dart';
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
    ref.invalidate(deenXpProvider);
  }

  Future<void> toggleEveningDhikr(bool done) async {
    await repo.setEveningDhikr(done);
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(deenXpProvider);
  }

  Future<void> addQuranMinutes(int minutes) async {
    await repo.addQuranMinutes(minutes);
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(deenXpProvider);
  }

  Future<void> markLearningViewed() async {
    await repo.setLearningViewed();
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(deenXpProvider);
  }

  Future<bool> useStreakFreeze(DateTime date) async {
    final success = await repo.useFreeze(date);
    if (success) {
      ref.invalidate(isFreezeAvailableProvider);
    }
    return success;
  }
}

final deenControllerProvider = Provider<DeenController>((ref) {
  final repo = ref.watch(deenRepositoryProvider);
  return DeenController(ref, repo);
});
