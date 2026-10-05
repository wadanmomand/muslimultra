import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/widgets/calculation_settings_dialog.dart';
import 'package:muslim_ultra/features/prayer/presentation/widgets/quiet_hours_setting_sheet.dart';
import 'package:muslim_ultra/features/prayer/presentation/widgets/qibla_compass_dial.dart';

class PrayerScreen extends ConsumerWidget {
  const PrayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentMode = ref.watch(prayerTabModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(currentMode == PrayerTabMode.times ? l10n.navPrayer : l10n.qiblaCompass),
        actions: [
          // Settings & Methods Button
          IconButton(
            tooltip: 'Calculation Settings',
            icon: const Icon(Icons.tune, color: AppColors.gold),
            onPressed: () => CalculationSettingsDialog.show(context),
          ),
          // Quiet Hours Button
          IconButton(
            tooltip: 'Quiet Hours',
            icon: const Icon(Icons.bedtime_outlined, color: AppColors.goldLight),
            onPressed: () => QuietHoursSettingSheet.show(context),
          ),
          // Segmented toggle
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton.outlined(
              tooltip: currentMode == PrayerTabMode.times ? l10n.qiblaCompass : l10n.navPrayer,
              icon: Icon(
                currentMode == PrayerTabMode.times ? Icons.explore_rounded : Icons.access_time_filled_rounded,
                color: AppColors.gold,
              ),
              onPressed: () {
                ref.read(prayerTabModeProvider.notifier).state =
                    currentMode == PrayerTabMode.times ? PrayerTabMode.qibla : PrayerTabMode.times;
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Switcher Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCardElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ref.read(prayerTabModeProvider.notifier).state = PrayerTabMode.times;
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: currentMode == PrayerTabMode.times
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: currentMode == PrayerTabMode.times
                              ? Border.all(color: AppColors.gold, width: 1.2)
                              : null,
                        ),
                        child: Text(
                          l10n.navPrayer,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: currentMode == PrayerTabMode.times ? FontWeight.bold : FontWeight.w500,
                            color: currentMode == PrayerTabMode.times
                                ? AppColors.gold
                                : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        ref.read(prayerTabModeProvider.notifier).state = PrayerTabMode.qibla;
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: currentMode == PrayerTabMode.qibla
                              ? AppColors.gold.withValues(alpha: 0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          border: currentMode == PrayerTabMode.qibla
                              ? Border.all(color: AppColors.gold, width: 1.2)
                              : null,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.explore_outlined,
                              size: 16,
                              color: currentMode == PrayerTabMode.qibla
                                  ? AppColors.gold
                                  : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              l10n.qiblaCompass,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: currentMode == PrayerTabMode.qibla ? FontWeight.bold : FontWeight.w500,
                                color: currentMode == PrayerTabMode.qibla
                                    ? AppColors.gold
                                    : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: currentMode == PrayerTabMode.times
                ? _buildPrayerTimesView(context, l10n, isDark, ref)
                : const QiblaCompassDial(),
          ),
        ],
      ),
    );
  }

  Widget _buildPrayerTimesView(BuildContext context, AppLocalizations l10n, bool isDark, WidgetRef ref) {
    final schedule = ref.watch(prayerScheduleProvider);
    final countdown = ref.watch(nextPrayerCountdownProvider);
    final hijriDate = ref.watch(hijriDateProvider);
    final params = ref.watch(prayerParametersProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final location = ref.watch(locationProvider);
    final qiblaData = ref.watch(qiblaDataProvider);

    final prayers = schedule.prayers;
    final nextPrayer = countdown?.nextPrayer ?? schedule.nextPrayer(DateTime.now());
    final countdownText = countdown?.formattedCountdown ?? '00h 00m 00s';

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Hijri Date Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.calendar_month, size: 16, color: AppColors.gold),
                    const SizedBox(width: 8),
                    Text(
                      hijriDate.formattedEn(),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Text(
                  hijriDate.formattedAr(),
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 14,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Next Prayer Live Countdown Banner
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cardGradientDark : null,
              color: isDark ? null : AppColors.sandCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Text(
                  l10n.nextPrayer,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  nextPrayer.name,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'in $countdownText',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.goldLight,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                InkWell(
                  onTap: () => CalculationSettingsDialog.show(context),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_pin, size: 15, color: AppColors.gold),
                      const SizedBox(width: 4),
                      Text(
                        '${location.displayName} · ${params.method.name.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.edit, size: 12, color: AppColors.gold),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Prominent Qibla Entry Banner
          InkWell(
            onTap: () {
              ref.read(prayerTabModeProvider.notifier).state = PrayerTabMode.qibla;
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.explore, color: AppColors.gold, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.qiblaCompass,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          'Kaaba Bearing: ${qiblaData.qiblaBearing.toStringAsFixed(1)}° · ${qiblaData.distanceKm.toInt()} km',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.gold),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Real Timetable List
          ...prayers.map((item) {
            final isCurrent = item.isCurrent;
            final isNext = item.isNext;
            final isNotifEnabled = notificationSettings.isPrayerEnabled(item.name);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isNext
                    ? AppColors.gold.withValues(alpha: 0.14)
                    : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isNext
                      ? AppColors.gold
                      : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                  width: isNext ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: Icon(
                          isNotifEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                          size: 18,
                          color: isNotifEnabled
                              ? (isNext ? AppColors.gold : AppColors.goldLight)
                              : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                        ),
                        onPressed: () {
                          ref.read(notificationSettingsProvider.notifier).togglePrayer(item.name);
                        },
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isNext || isCurrent ? FontWeight.bold : FontWeight.w600,
                              color: isNext
                                  ? AppColors.gold
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                            ),
                          ),
                          if (isNext)
                            const Text(
                              'Next Prayer',
                              style: TextStyle(fontSize: 10, color: AppColors.gold, fontWeight: FontWeight.bold),
                            ),
                        ],
                      ),
                    ],
                  ),
                  Text(
                    item.formattedTime,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isNext
                          ? AppColors.gold
                          : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
