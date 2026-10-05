import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class HomePrayerCard extends ConsumerWidget {
  const HomePrayerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final schedule = ref.watch(prayerScheduleProvider);
    final countdown = ref.watch(nextPrayerCountdownProvider);
    final location = ref.watch(locationProvider);

    final prayers = schedule.prayers;
    final nextPrayer = countdown?.nextPrayer ?? schedule.nextPrayer(DateTime.now());
    final countdownFormatted = countdown?.formattedCountdown ?? '00h 00m 00s';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark ? AppColors.cardGradientDark : null,
        color: isDark ? null : AppColors.sandCard,
        border: Border.all(
          color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.access_time_filled_rounded,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.nextPrayer} (in $countdownFormatted)',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        '${nextPrayer.name} · ${nextPrayer.formattedTime}',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.gold,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.35),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.location_on_outlined, size: 14, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      location.cityName,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.gold,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Prayer list horizontal strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: prayers.map((p) {
                final isNext = p.isNext;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isNext
                        ? AppColors.gold.withValues(alpha: 0.18)
                        : (isDark
                            ? AppColors.midnightNavyDark.withValues(alpha: 0.6)
                            : AppColors.sandCardElevated),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isNext
                          ? AppColors.gold
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      width: isNext ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isNext ? FontWeight.bold : FontWeight.w500,
                          color: isNext
                              ? AppColors.gold
                              : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        p.formattedTime,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
