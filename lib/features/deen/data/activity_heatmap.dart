import 'dart:math';

/// Represents single-day engagement activity for the heatmap
class DayActivity {
  final DateTime date;
  final double score; // 0.0 to 1.0
  final int prayersPrayed;
  final bool isFasting;
  final int quranMinutes;
  final bool isDhikrDone;
  final bool isQuizDone;
  final int estimatedXp;

  const DayActivity({
    required this.date,
    required this.score,
    this.prayersPrayed = 0,
    this.isFasting = false,
    this.quranMinutes = 0,
    this.isDhikrDone = false,
    this.isQuizDone = false,
    this.estimatedXp = 0,
  });

  /// 5 discrete color intensity steps (0 to 4)
  int get intensityLevel {
    if (score <= 0.0) return 0;
    if (score < 0.25) return 1;
    if (score < 0.50) return 2;
    if (score < 0.75) return 3;
    return 4;
  }
}

/// Pure functions for computing the 53-week GitHub-style Daily Deen Activity Heatmap
class ActivityHeatmapService {
  /// Pure function calculating score for a single day:
  /// - Prayer completion: 50% ((prayed / 5) * 0.50)
  /// - Fasting: 20% (0.20 if kept)
  /// - Quran: 15% (capped at 30 min -> (min(quranMins, 30) / 30) * 0.15)
  /// - Dhikr (10%) + Quiz (5%): 15%
  static double calculateDayScore({
    required int prayersPrayed,
    required bool isFasting,
    required int quranMinutes,
    required bool isDhikrDone,
    required bool isQuizDone,
  }) {
    final prayerRatio = (prayersPrayed.clamp(0, 5) / 5.0) * 0.50;
    final fastRatio = isFasting ? 0.20 : 0.0;
    final quranRatio = (min(quranMinutes.clamp(0, 30), 30) / 30.0) * 0.15;
    final dhikrRatio = isDhikrDone ? 0.10 : 0.0;
    final quizRatio = isQuizDone ? 0.05 : 0.0;

    final total = prayerRatio + fastRatio + quranRatio + dhikrRatio + quizRatio;
    return total.clamp(0.0, 1.0);
  }

  /// Builds a complete contiguous list of [DayActivity] spanning [totalWeeks] (default 53 weeks = 371 days)
  /// aligned to start on Monday and end on the current week's Sunday (or today).
  static List<DayActivity> buildHeatmap({
    Map<String, int> prayersMap = const {},
    Set<String> fastsKeptSet = const {},
    Map<String, int> quranMinutesMap = const {},
    Set<String> dhikrDoneSet = const {},
    Set<String> quizDoneSet = const {},
    DateTime? endDate,
    int totalWeeks = 53,
  }) {
    final end = endDate ?? DateTime.now();
    final normalizedEnd = DateTime.utc(end.year, end.month, end.day);

    // End at the current week's end (Sunday) or today
    // Let's compute total days = totalWeeks * 7
    final totalDays = totalWeeks * 7;
    // We want the last day in the grid to be the upcoming Sunday or normalizedEnd
    // Aligning standard weekday: Monday = 1, Sunday = 7
    final daysToSunday = 7 - normalizedEnd.weekday;
    final gridEnd = normalizedEnd.add(Duration(days: daysToSunday));
    final gridStart = gridEnd.subtract(Duration(days: totalDays - 1));

    final result = <DayActivity>[];

    for (var i = 0; i < totalDays; i++) {
      final cur = gridStart.add(Duration(days: i));
      final dateKey = _formatDateKey(cur);

      if (cur.isAfter(normalizedEnd)) {
        // Future date placeholder in current week
        result.add(DayActivity(
          date: cur,
          score: 0.0,
        ));
        continue;
      }

      final prayers = prayersMap[dateKey] ?? 0;
      final isFasting = fastsKeptSet.contains(dateKey);
      final quranMins = quranMinutesMap[dateKey] ?? 0;
      final isDhikr = dhikrDoneSet.contains(dateKey);
      final isQuiz = quizDoneSet.contains(dateKey);

      final score = calculateDayScore(
        prayersPrayed: prayers,
        isFasting: isFasting,
        quranMinutes: quranMins,
        isDhikrDone: isDhikr,
        isQuizDone: isQuiz,
      );

      final xp = (prayers * 10) + quranMins + (isDhikr ? 10 : 0) + (isQuiz ? 20 : 0);

      result.add(DayActivity(
        date: cur,
        score: score,
        prayersPrayed: prayers,
        isFasting: isFasting,
        quranMinutes: quranMins,
        isDhikrDone: isDhikr,
        isQuizDone: isQuiz,
        estimatedXp: xp,
      ));
    }

    return result;
  }

  static String _formatDateKey(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }
}

/// Top-level helper function matching the spec signature
List<DayActivity> buildHeatmap({
  Map<String, int> prayersMap = const {},
  Set<String> fastsKeptSet = const {},
  Map<String, int> quranMinutesMap = const {},
  Set<String> dhikrDoneSet = const {},
  Set<String> quizDoneSet = const {},
  DateTime? endDate,
  int totalWeeks = 53,
}) {
  return ActivityHeatmapService.buildHeatmap(
    prayersMap: prayersMap,
    fastsKeptSet: fastsKeptSet,
    quranMinutesMap: quranMinutesMap,
    dhikrDoneSet: dhikrDoneSet,
    quizDoneSet: quizDoneSet,
    endDate: endDate,
    totalWeeks: totalWeeks,
  );
}

