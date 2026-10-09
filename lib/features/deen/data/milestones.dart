import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

@immutable
class Milestone {
  final String id;
  final String title;
  final String description;
  final String icon;
  final String category;

  const Milestone({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.category,
  });

  /// Formatted text for clipboard share
  String getShareText() {
    return '🌟 Alhamdulillah! I just achieved a milestone on Muslim Ultra: $title — $description 🤲\n\nDaily Deen & Spiritual Growth with Muslim Ultra ✨';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Milestone && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Pure function to detect newly hit milestones
List<Milestone> checkMilestones({
  int prayerStreak = 0,
  int fastingStreak = 0,
  int totalXp = 0,
  bool hasCompletedKhatmah = false,
  int quizStreak = 0,
  Set<String> alreadyCelebratedIds = const {},
}) {
  final candidates = <Milestone>[];

  // Prayer Streak milestones
  if (prayerStreak >= 7) {
    candidates.add(const Milestone(
      id: 'prayer_streak_7',
      title: '7-Day Prayer Streak',
      description: '7 days of consistent prayer — Mashallah!',
      icon: '🕌',
      category: 'prayer',
    ));
  }
  if (prayerStreak >= 30) {
    candidates.add(const Milestone(
      id: 'prayer_streak_30',
      title: '30-Day Prayer Streak',
      description: 'A full month of prayers fulfilled — Tabarakallah!',
      icon: '🕌',
      category: 'prayer',
    ));
  }
  if (prayerStreak >= 100) {
    candidates.add(const Milestone(
      id: 'prayer_streak_100',
      title: '100-Day Prayer Streak',
      description: '100 days of devotion — Mashallah!',
      icon: '🌟',
      category: 'prayer',
    ));
  }
  if (prayerStreak >= 365) {
    candidates.add(const Milestone(
      id: 'prayer_streak_365',
      title: '365-Day Prayer Milestone',
      description: 'One complete year of prayer dedication — Alhamdulillah!',
      icon: '👑',
      category: 'prayer',
    ));
  }

  // Fasting Streak milestones
  if (fastingStreak >= 7) {
    candidates.add(const Milestone(
      id: 'fasting_streak_7',
      title: '7-Day Fasting Streak',
      description: '7 fasts observed with perseverance — Mashallah!',
      icon: '🌙',
      category: 'fasting',
    ));
  }
  if (fastingStreak >= 30) {
    candidates.add(const Milestone(
      id: 'fasting_streak_30',
      title: '30-Day Fasting Milestone',
      description: '30 fasts completed — May Allah accept your worship!',
      icon: '🌙',
      category: 'fasting',
    ));
  }
  if (fastingStreak >= 100) {
    candidates.add(const Milestone(
      id: 'fasting_streak_100',
      title: '100 Fasting Days',
      description: '100 fasts completed — Incredble dedication!',
      icon: '🌙',
      category: 'fasting',
    ));
  }
  if (fastingStreak >= 365) {
    candidates.add(const Milestone(
      id: 'fasting_streak_365',
      title: '365 Fasting Days Milestone',
      description: 'A monumental fasting journey — Mashallah!',
      icon: '👑',
      category: 'fasting',
    ));
  }

  // XP Milestones
  if (totalXp >= 1000) {
    candidates.add(const Milestone(
      id: 'xp_1000',
      title: '1,000 XP Club',
      description: 'Reached 1,000 Deen XP — Keep rising in rank!',
      icon: '⚡',
      category: 'xp',
    ));
  }
  if (totalXp >= 5000) {
    candidates.add(const Milestone(
      id: 'xp_5000',
      title: '5,000 XP Champion',
      description: '5,000 Deen XP earned — An inspiring achievement!',
      icon: '🏆',
      category: 'xp',
    ));
  }

  // Khatmah Milestone
  if (hasCompletedKhatmah) {
    candidates.add(const Milestone(
      id: 'khatmah_complete',
      title: 'Quran Khatmah Complete',
      description: 'Full recitation of the Holy Quran completed — Mubarak!',
      icon: '📖',
      category: 'quran',
    ));
  }

  // Quiz Streak Milestone
  if (quizStreak >= 30) {
    candidates.add(const Milestone(
      id: 'quiz_streak_30',
      title: '30-Day Quiz Scholar',
      description: '30 days of daily Islamic quizzes completed — Mashallah!',
      icon: '💡',
      category: 'quiz',
    ));
  }

  // Filter out any already celebrated
  return candidates
      .where((m) => !alreadyCelebratedIds.contains(m.id))
      .toList();
}

class MilestoneRepository {
  static const String storageKey = 'milestones_v1';

  /// Loads list of already celebrated milestone IDs
  Future<Set<String>> getCelebratedMilestones() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(storageKey);
    if (list != null) {
      return list.toSet();
    }
    // Fallback if stored as json
    final raw = prefs.getString(storageKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = json.decode(raw) as List<dynamic>;
        return decoded.map((e) => e.toString()).toSet();
      } catch (_) {}
    }
    return <String>{};
  }

  /// Mark milestone ID as celebrated
  Future<void> markCelebrated(String milestoneId) async {
    final prefs = await SharedPreferences.getInstance();
    final set = await getCelebratedMilestones();
    set.add(milestoneId);
    await prefs.setStringList(storageKey, set.toList());
  }

  /// Clear for test
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(storageKey);
  }
}
