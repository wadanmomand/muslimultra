import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/muhasaba/presentation/providers/muhasaba_providers.dart';

class MuhasabaSummaryCard extends ConsumerWidget {
  const MuhasabaSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final weekAsync = ref.watch(muhasabaWeekProvider);
    final streakAsync = ref.watch(muhasabaStreakProvider);

    final today = DateTime.now();
    // 7 days ending today
    final days = List.generate(7, (i) => today.subtract(Duration(days: 6 - i)));

    final streak = streakAsync.value ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.2)
                : AppColors.midnightNavy.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_view_week_rounded,
                      size: 16,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    l10n?.muhasabaWeeklySummary ?? 'Weekly Reflection',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                ],
              ),
              if (streak > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department_rounded,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n?.muhasabaStreak(streak) ?? '$streak day streak',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // 7 Weekly Dots
          weekAsync.when(
            data: (entries) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final day = days[index];
                  final entry = index < entries.length ? entries[index] : null;
                  final isCompleted = entry != null && entry.isCompleted;
                  final isCurrentDay = index == 6;

                  final dayLabel = DateFormat('E', l10n?.localeName).format(day).substring(0, 1).toUpperCase();
                  final dateNum = day.day.toString();

                  return Column(
                    children: [
                      Text(
                        dayLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.w500,
                          color: isCurrentDay
                              ? AppColors.gold
                              : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCompleted
                              ? AppColors.gold
                              : (isDark
                                  ? AppColors.midnightNavyCardElevated
                                  : AppColors.sandBackground),
                          border: Border.all(
                            color: isCompleted
                                ? AppColors.gold
                                : (isCurrentDay
                                    ? AppColors.gold.withValues(alpha: 0.6)
                                    : (isDark
                                        ? AppColors.midnightNavyBorder
                                        : AppColors.sandBorder)),
                            width: isCurrentDay ? 1.5 : 1,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: AppColors.midnightNavyDark,
                                )
                              : Text(
                                  dateNum,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
                                    color: isCurrentDay
                                        ? (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary)
                                        : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                }),
              );
            },
            loading: () => const Center(
              child: SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
              ),
            ),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
