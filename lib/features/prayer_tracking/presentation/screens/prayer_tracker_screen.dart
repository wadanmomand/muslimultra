import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/providers/prayer_tracking_providers.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/widgets/prayer_log_row.dart';

class PrayerTrackerScreen extends ConsumerWidget {
  const PrayerTrackerScreen({super.key});

  String _getPrayerLocalizedName(AppLocalizations? l10n, TrackedPrayer prayer) {
    if (l10n == null) return prayer.keyName;
    switch (prayer) {
      case TrackedPrayer.fajr:
        return l10n.fajr;
      case TrackedPrayer.dhuhr:
        return l10n.dhuhr;
      case TrackedPrayer.asr:
        return l10n.asr;
      case TrackedPrayer.maghrib:
        return l10n.maghrib;
      case TrackedPrayer.isha:
        return l10n.isha;
    }
  }

  String _getPrayerTime(WidgetRef ref, TrackedPrayer prayer) {
    try {
      final schedule = ref.watch(prayerScheduleProvider);
      switch (prayer) {
        case TrackedPrayer.fajr:
          return DateFormat('hh:mm a').format(schedule.fajr);
        case TrackedPrayer.dhuhr:
          return DateFormat('hh:mm a').format(schedule.dhuhr);
        case TrackedPrayer.asr:
          return DateFormat('hh:mm a').format(schedule.asr);
        case TrackedPrayer.maghrib:
          return DateFormat('hh:mm a').format(schedule.maghrib);
        case TrackedPrayer.isha:
          return DateFormat('hh:mm a').format(schedule.isha);
      }
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    final selectedDate = ref.watch(selectedTrackerDateProvider);
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    final logsAsync = ref.watch(prayerLogsForSelectedDateProvider);
    final currentStreakAsync = ref.watch(currentPrayerStreakProvider);
    final bestStreakAsync = ref.watch(bestPrayerStreakProvider);
    final weeklyStatsAsync = ref.watch(weeklyPrayerStatsProvider);
    final monthlyConsistencyAsync = ref.watch(monthlyPrayerConsistencyProvider);

    final currentLogs = logsAsync.value ?? {};

    // Count prayed today
    var prayedCount = 0;
    for (final prayer in TrackedPrayer.all) {
      if (currentLogs[prayer.keyName]?.status == PrayerLogStatus.prayed) {
        prayedCount++;
      }
    }

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('prayer_tracker_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.prayerTrackerTitle ?? 'Prayer Log',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 17,
              ),
            ),
            Text(
              l10n?.prayerTrackerSubtitle ?? 'Daily tracking & streaks',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: secondaryTextColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 36),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Date Switcher Header
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor.withAlpha((0.7 * 255).round()),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  IconButton(
                    key: const ValueKey('btn_prev_date'),
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.gold),
                    onPressed: () {
                      ref.read(selectedTrackerDateProvider.notifier).state =
                          selectedDate.subtract(const Duration(days: 1));
                    },
                  ),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isToday
                              ? '${l10n?.today ?? "Today"} · ${DateFormat("d MMM yyyy").format(selectedDate)}'
                              : DateFormat('EEEE, d MMM yyyy').format(selectedDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n?.prayedCountOfTotal(prayedCount) ?? '$prayedCount of 5 prayers',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('btn_next_date'),
                    icon: Icon(
                      Icons.chevron_right_rounded,
                      color: isToday
                          ? (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary)
                          : AppColors.gold,
                    ),
                    onPressed: isToday
                        ? null
                        : () {
                            ref.read(selectedTrackerDateProvider.notifier).state =
                                selectedDate.add(const Duration(days: 1));
                          },
                  ),
                ],
              ),
            ),

            // Hint Text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                l10n?.tapPrayerToLogHint ?? 'Tap a status to log your prayer.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 4),

            // 5 Obligatory Prayer Rows
            ...TrackedPrayer.all.map((prayer) {
              final entry = currentLogs[prayer.keyName];
              final prayerName = _getPrayerLocalizedName(l10n, prayer);
              final timeStr = _getPrayerTime(ref, prayer);

              return PrayerLogRow(
                key: ValueKey('prayer_row_${prayer.keyName}'),
                prayer: prayer,
                prayerName: prayerName,
                formattedTime: timeStr,
                currentStatus: entry?.status,
                onStatusSelected: (newStatus) {
                  ref.read(prayerLogControllerProvider).setPrayerStatus(
                        date: selectedDate,
                        prayer: prayer.keyName,
                        status: newStatus,
                      );
                },
              );
            }),

            const SizedBox(height: 12),

            // Streaks Card (Current Streak & Best Streak)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.cardGradientDark : null,
                color: isDark ? null : AppColors.sandCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor.withAlpha((0.8 * 255).round()),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? (0.25 * 255).round() : (0.04 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Current Streak
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            gradient: AppColors.goldGradient,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.gold.withAlpha((0.3 * 255).round()),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.midnightNavyDark,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${currentStreakAsync.value ?? 0}',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n?.currentPrayerStreak ?? 'Day Streak',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Divider
                  Container(
                    height: 34,
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    color: borderColor.withAlpha((0.6 * 255).round()),
                  ),

                  // Best Streak
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withAlpha((0.15 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.gold.withAlpha((0.4 * 255).round()),
                              width: 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.emoji_events_rounded,
                            color: AppColors.gold,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${bestStreakAsync.value ?? 0}',
                                style: TextStyle(
                                  color: primaryTextColor,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                l10n?.bestPrayerStreak ?? 'Best Streak',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 6),

            // Weekly Bar Summary Card
            weeklyStatsAsync.when(
              data: (stats) {
                final dailyPrayed = (stats['dailyPrayedCounts'] as List<dynamic>?)
                        ?.map((e) => (e as num).toInt())
                        .toList() ??
                    [0, 0, 0, 0, 0, 0, 0];
                final dailyLabels =
                    (stats['dailyLabels'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
                        ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                final totalPrayedWeek = (stats['totalPrayed'] as num?)?.toInt() ?? 0;

                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor.withAlpha((0.7 * 255).round()),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              l10n?.weeklyPrayerSummary ?? 'Weekly Summary',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          Text(
                            '$totalPrayedWeek / 35',
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // 7-day Bar chart
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: List.generate(dailyPrayed.length, (idx) {
                          final count = dailyPrayed[idx];
                          final label = dailyLabels[idx];
                          final barHeight = ((count / 5.0) * 44.0).clamp(4.0, 44.0);
                          final isFull = count == 5;

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$count',
                                style: TextStyle(
                                  color: isFull ? AppColors.gold : secondaryTextColor,
                                  fontSize: 9.5,
                                  fontWeight: isFull ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Container(
                                width: 16,
                                height: barHeight,
                                decoration: BoxDecoration(
                                  gradient: isFull ? AppColors.goldGradient : null,
                                  color: isFull
                                      ? null
                                      : (count > 0
                                          ? AppColors.gold.withAlpha((0.4 * 255).round())
                                          : (isDark
                                              ? AppColors.midnightNavyDark
                                              : AppColors.sandBorder)),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                label,
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

            const SizedBox(height: 6),

            // Monthly Consistency Card
            monthlyConsistencyAsync.when(
              data: (consistency) {
                final percentage = (consistency * 100).round();
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: borderColor.withAlpha((0.7 * 255).round()),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha((0.15 * 255).round()),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n?.monthlyPrayerConsistency ?? 'Monthly Consistency',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: primaryTextColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: consistency,
                                backgroundColor: isDark
                                    ? AppColors.midnightNavyDark
                                    : AppColors.sandCardElevated,
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}
