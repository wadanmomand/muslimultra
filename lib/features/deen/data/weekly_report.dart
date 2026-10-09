import 'package:flutter/services.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';

/// Structured Weekly Deen Report for the last 7 days
class WeeklyDeenReport {
  final int prayersDone;
  final int prayersTotal; // 35 for 7 days * 5 prayers
  final int quranMinutes;
  final int xpEarned;
  final int currentStreak;
  final int bestStreak;
  final int quizCorrect;
  final int quizTotal;

  const WeeklyDeenReport({
    required this.prayersDone,
    this.prayersTotal = 35,
    required this.quranMinutes,
    required this.xpEarned,
    required this.currentStreak,
    required this.bestStreak,
    required this.quizCorrect,
    this.quizTotal = 7,
  });

  /// Prayer completion rate percentage (0 to 100)
  int get prayerPercentage => prayersTotal > 0 ? ((prayersDone / prayersTotal) * 100).round() : 0;

  /// Quiz accuracy percentage
  int get quizPercentage => quizTotal > 0 ? ((quizCorrect / quizTotal) * 100).round() : 0;

  /// Formats the weekly summary as a text message for clipboard sharing
  String formatShareText(AppLocalizations? l10n) {
    final title = l10n?.weeklyReportTitle ?? 'My Weekly Deen Report';
    final appName = 'Muslim Ultra';

    return '''🌙 $title — $appName
━━━━━━━━━━━━━━━━━━━━
🤲 Prayers: $prayersDone / $prayersTotal ($prayerPercentage%)
📖 Quran: $quranMinutes minutes
⚡ Deen XP Earned: +$xpEarned XP
🔥 Current Streak: $currentStreak days (Best: $bestStreak days)
💡 Daily Quiz: $quizCorrect / $quizTotal correct ($quizPercentage%)
━━━━━━━━━━━━━━━━━━━━
Track your journey with Muslim Ultra ✨''';
  }

  /// Copies report text to clipboard
  Future<void> copyToClipboard(AppLocalizations? l10n) async {
    final text = formatShareText(l10n);
    await Clipboard.setData(ClipboardData(text: text));
  }
}
