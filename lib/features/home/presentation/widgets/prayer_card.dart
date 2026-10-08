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
        gradient: isDark ? AppColors.cardGradientDark : AppColors.sandCardGradientLight,
        color: isDark ? null : AppColors.sandCard,
        border: Border.all(
          color: isDark ? AppColors.gold.withValues(alpha: 0.35) : AppColors.sandBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : AppColors.midnightNavy.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Next Prayer Tag + Location Pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Next Prayer Tag
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.nextPrayer.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              // Location Pill
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 12, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          location.cityName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Dominant Hero Section: Prayer Name & Time
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dominant Prayer Name
              Expanded(
                child: Text(
                  nextPrayer.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.goldBright : AppColors.midnightNavy,
                      ) ??
                      TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: isDark ? AppColors.goldBright : AppColors.midnightNavy,
                      ),
                ),
              ),
              const SizedBox(width: 10),
              // Dominant Prayer Time
              Text(
                nextPrayer.formattedTime,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ) ??
                    TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Countdown Timer Pill
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.timer_outlined,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        countdownFormatted,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                          color: isDark ? AppColors.goldLight : AppColors.goldDark,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          l10n.remaining,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Divider before prayer strip
          Divider(
            color: isDark
                ? AppColors.midnightNavyBorder
                : AppColors.sandBorder,
            height: 1,
            thickness: 1,
          ),
          const SizedBox(height: 12),

          // Horizontal Prayer Times Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: prayers.map((p) {
                final isNext = p.isNext;
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isNext
                        ? AppColors.gold.withValues(alpha: 0.2)
                        : (isDark
                            ? AppColors.midnightNavyDark.withValues(alpha: 0.6)
                            : AppColors.sandCardElevated),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isNext
                          ? AppColors.gold
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      width: isNext ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p.name,
                        style: TextStyle(
                          fontSize: 11,
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
