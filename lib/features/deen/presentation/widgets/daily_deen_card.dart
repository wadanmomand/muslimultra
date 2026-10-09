import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/deen/domain/models/deen_xp.dart';
import 'package:muslim_ultra/features/deen/presentation/providers/deen_providers.dart';
import 'package:muslim_ultra/features/deen/presentation/screens/weekly_report_screen.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/providers/prayer_tracking_providers.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/screens/prayer_tracker_screen.dart';

class DailyDeenCard extends ConsumerWidget {
  const DailyDeenCard({super.key});

  void _showStreakFreezeDialog(BuildContext context, WidgetRef ref, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Row(
            children: [
              const Text('❄', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              Text(
                l10n?.freezeDialogTitle ?? 'Use Streak Freeze',
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
            ],
          ),
          content: Text(
            l10n?.freezeDialogBody ??
                'Life happens. Use this week\'s streak freeze to protect your streak from breaking.',
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: Text(
                l10n?.cancel ?? 'Cancel',
                style: TextStyle(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
              ),
            ),
            ElevatedButton(
              key: const ValueKey('btn_confirm_freeze'),
              onPressed: () async {
                final success = await ref
                    .read(deenControllerProvider)
                    .useStreakFreeze(yesterday);
                if (context.mounted) {
                  Navigator.of(dialogCtx).pop();
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          l10n?.freezeAppliedToast ?? 'Streak freeze applied! Your streak is safe. ❄',
                        ),
                        backgroundColor: AppColors.midnightNavyCard,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                l10n?.applyFreezeButton ?? 'Apply Freeze',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAddQuranMinutesDialog(BuildContext context, WidgetRef ref, AppLocalizations? l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (dialogCtx) {
        return SimpleDialog(
          backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: Text(
            l10n?.logQuranMinutesTitle ?? 'Log Quran Reading',
            style: const TextStyle(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          children: [
            SimpleDialogOption(
              onPressed: () async {
                await ref.read(deenControllerProvider).addQuranMinutes(5);
                if (context.mounted) Navigator.of(dialogCtx).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('+5 Minutes (+5 XP)', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await ref.read(deenControllerProvider).addQuranMinutes(10);
                if (context.mounted) Navigator.of(dialogCtx).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('+10 Minutes (+10 XP)', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
            SimpleDialogOption(
              onPressed: () async {
                await ref.read(deenControllerProvider).addQuranMinutes(15);
                if (context.mounted) Navigator.of(dialogCtx).pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 6),
                child: Text('+15 Minutes (+15 XP)', style: TextStyle(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final xpAsync = ref.watch(deenXpProvider);
    final dailyStateAsync = ref.watch(dailyDeenStateProvider);
    final prayerLogsAsync = ref.watch(prayerLogsForSelectedDateProvider);
    final streakAsync = ref.watch(currentPrayerStreakProvider);
    final isFreezeAvailableAsync = ref.watch(isFreezeAvailableProvider);

    final xp = xpAsync.value ?? const DeenXp(totalXp: 0);
    final dailyState = dailyStateAsync.value ?? const DailyDeenState(date: '');
    final prayerLogs = prayerLogsAsync.value ?? {};
    final streak = streakAsync.value ?? 0;
    final isFreezeAvailable = isFreezeAvailableAsync.value ?? false;

    // Check prayers prayed count
    var prayedCount = 0;
    for (final p in TrackedPrayer.all) {
      if (prayerLogs[p.keyName]?.status == PrayerLogStatus.prayed) {
        prayedCount++;
      }
    }

    final levelName = xp.level.title;
    final nextLevelName = xp.level.nextLevel?.title ?? 'Max';
    final remainingXp = xp.remainingToNext;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.cardGradientDark : null,
        color: isDark ? null : cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withAlpha((0.35 * 255).round()),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? (0.25 * 255).round() : (0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Today's Deen + Level Badge + Weekly Report Action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: AppColors.midnightNavyDark,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        l10n?.todaysDeenTitle ?? 'Today\'s Deen',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Level Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withAlpha((0.15 * 255).round()),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.gold.withAlpha((0.4 * 255).round()),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      levelName,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.w800,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),
                  // Weekly Report Icon Button
                  IconButton(
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                    key: const ValueKey('btn_open_weekly_report'),
                    tooltip: l10n?.weeklyReportTitle ?? 'Weekly Report',
                    icon: const Icon(Icons.insights_rounded, color: AppColors.gold, size: 20),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WeeklyReportScreen()),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // XP Progress Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${xp.totalXp} XP',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.w800,
                      fontSize: 12.5,
                    ),
                  ),
                  Text(
                    xp.level.nextLevel != null
                        ? '$remainingXp XP ${l10n?.xpToNextLevelSuffix ?? "to"} $nextLevelName'
                        : l10n?.maxLevelReached ?? 'Mastery Level',
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: xp.progressFraction,
                  backgroundColor: isDark
                      ? AppColors.midnightNavyDark
                      : AppColors.sandCardElevated,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                  minHeight: 6,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1, thickness: 0.8, color: AppColors.midnightNavyBorder),
          const SizedBox(height: 12),

          // Checklist Rows:
          // 1. 5 Prayers Row
          Material(
            color: Colors.transparent,
            child: InkWell(
              key: const ValueKey('daily_deen_prayer_row'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const PrayerTrackerScreen()),
                );
              },
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.gold.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.gold, size: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.fivePrayersChecklistLabel ?? '5 Obligatory Prayers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '$prayedCount / 5 ${l10n?.prayedStatusSuffix ?? "prayed"}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: secondaryTextColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    // 5 mini indicators
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: TrackedPrayer.all.map((p) {
                        final isPrayed = prayerLogs[p.keyName]?.status == PrayerLogStatus.prayed;
                        return Container(
                          margin: const EdgeInsets.only(left: 3),
                          width: 17,
                          height: 17,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isPrayed ? AppColors.gold : borderColor,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            p.keyName[0].toUpperCase(),
                            style: TextStyle(
                              color: isPrayed ? AppColors.midnightNavyDark : secondaryTextColor,
                              fontSize: 8.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // 2. Quran Reading Row
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.menu_book, color: AppColors.gold, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.quranGoalChecklistLabel ?? 'Daily Quran',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '${dailyState.quranMinutes}m ${l10n?.quranMinutesGoalSuffix ?? "today (goal: 10m)"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.all(4),
                  key: const ValueKey('btn_add_quran_minutes'),
                  icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.gold, size: 22),
                  onPressed: () => _showAddQuranMinutesDialog(context, ref, l10n),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // 3. Morning & Evening Dhikr Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.gold.withAlpha((0.15 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const Icon(Icons.fingerprint_rounded, color: AppColors.gold, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n?.dhikrChecklistLabel ?? 'Adhkar',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              // Morning Dhikr Toggle
              FilterChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                key: const ValueKey('chip_morning_dhikr'),
                label: Text(
                  l10n?.morningDhikrChip ?? 'Morning',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: dailyState.morningDhikr ? AppColors.midnightNavyDark : secondaryTextColor,
                  ),
                ),
                selected: dailyState.morningDhikr,
                selectedColor: AppColors.gold,
                backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandCardElevated,
                checkmarkColor: AppColors.midnightNavyDark,
                onSelected: (val) {
                  ref.read(deenControllerProvider).toggleMorningDhikr(val);
                },
              ),
              const SizedBox(width: 4),
              // Evening Dhikr Toggle
              FilterChip(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                labelPadding: const EdgeInsets.symmetric(horizontal: 2),
                key: const ValueKey('chip_evening_dhikr'),
                label: Text(
                  l10n?.eveningDhikrChip ?? 'Evening',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: dailyState.eveningDhikr ? AppColors.midnightNavyDark : secondaryTextColor,
                  ),
                ),
                selected: dailyState.eveningDhikr,
                selectedColor: AppColors.gold,
                backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandCardElevated,
                checkmarkColor: AppColors.midnightNavyDark,
                onSelected: (val) {
                  ref.read(deenControllerProvider).toggleEveningDhikr(val);
                },
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(height: 1, thickness: 0.8, color: AppColors.midnightNavyBorder),
          const SizedBox(height: 10),

          // Footer: Streak & Freeze Protection
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.local_fire_department_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        '$streak ${l10n?.streakDaysCount ?? "Day Streak"}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isFreezeAvailable)
                TextButton.icon(
                  key: const ValueKey('btn_streak_freeze'),
                  icon: const Text('❄', style: TextStyle(fontSize: 14)),
                  label: Text(
                    l10n?.streakFreezeAvailableButton ?? 'Freeze Available',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onPressed: () => _showStreakFreezeDialog(context, ref, l10n),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
