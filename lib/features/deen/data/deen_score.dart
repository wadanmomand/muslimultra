import 'package:flutter/foundation.dart';

@immutable
class DeenScoreBreakdown {
  final int prayersPrayed;
  final int prayerScore;
  final int quranMinutes;
  final int quranScore;
  final bool dhikrDone;
  final int dhikrScore;
  final bool quizAnswered;
  final int quizScore;
  final bool learningViewed;
  final int learningScore;
  final int totalScore;

  const DeenScoreBreakdown({
    required this.prayersPrayed,
    required this.prayerScore,
    required this.quranMinutes,
    required this.quranScore,
    required this.dhikrDone,
    required this.dhikrScore,
    required this.quizAnswered,
    required this.quizScore,
    required this.learningViewed,
    required this.learningScore,
    required this.totalScore,
  });
}

/// Pure function to compute Daily Deen score (0–100)
DeenScoreBreakdown calculateDailyDeenScore({
  int prayersPrayed = 0,
  int quranMinutes = 0,
  bool dhikrDone = false,
  bool quizAnswered = false,
  bool learningViewed = false,
}) {
  final prayersCount = prayersPrayed.clamp(0, 5);
  final prayerScore = prayersCount * 12; // max 60
  final quranScore = quranMinutes >= 10 ? 15 : 0;
  final dhikrScore = dhikrDone ? 10 : 0;
  final quizScore = quizAnswered ? 10 : 0;
  final learningScore = learningViewed ? 5 : 0;

  final totalScore = (prayerScore + quranScore + dhikrScore + quizScore + learningScore).clamp(0, 100);

  return DeenScoreBreakdown(
    prayersPrayed: prayersCount,
    prayerScore: prayerScore,
    quranMinutes: quranMinutes,
    quranScore: quranScore,
    dhikrDone: dhikrDone,
    dhikrScore: dhikrScore,
    quizAnswered: quizAnswered,
    quizScore: quizScore,
    learningViewed: learningViewed,
    learningScore: learningScore,
    totalScore: totalScore,
  );
}

/// Pure helper for score calculation
int dailyScore({
  int prayersPrayed = 0,
  int quranMinutes = 0,
  bool dhikrDone = false,
  bool quizAnswered = false,
  bool learningViewed = false,
}) {
  return calculateDailyDeenScore(
    prayersPrayed: prayersPrayed,
    quranMinutes: quranMinutes,
    dhikrDone: dhikrDone,
    quizAnswered: quizAnswered,
    learningViewed: learningViewed,
  ).totalScore;
}
