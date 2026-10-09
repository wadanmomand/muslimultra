import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/qaza/domain/models/qaza_debt.dart';
import 'package:muslim_ultra/features/qaza/presentation/providers/qaza_providers.dart';

class QazaDebtScreen extends ConsumerWidget {
  const QazaDebtScreen({super.key});

  String _getPrayerName(AppLocalizations? l10n, TrackedPrayer prayer) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final debtAsync = ref.watch(qazaDebtProvider);
    final controller = ref.read(qazaControllerProvider);

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('qaza_debt_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              l10n?.qazaDebtTitle ?? 'Qaza Debt Balance',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            Text(
              l10n?.qazaDebtSubtitle ?? 'Make up missed prayers at your own pace',
              style: TextStyle(
                fontSize: 11,
                color: secondaryTextColor,
              ),
            ),
          ],
        ),
      ),
      body: debtAsync.when(
        data: (debt) => _buildContent(
          context,
          ref,
          debt: debt,
          controller: controller,
          isDark: isDark,
          l10n: l10n,
          primaryTextColor: primaryTextColor,
          secondaryTextColor: secondaryTextColor,
          cardBg: cardBg,
          borderColor: borderColor,
        ),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.gold),
        ),
        error: (_, __) => Center(
          child: Text(
            l10n?.qazaLoadError ?? 'Unable to load Qaza balance',
            style: TextStyle(color: secondaryTextColor),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref, {
    required QazaDebt debt,
    required QazaController controller,
    required bool isDark,
    required AppLocalizations? l10n,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required Color cardBg,
    required Color borderColor,
  }) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Total Balance & Weekly Repaid Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cardGradientDark : AppColors.sandCardGradientLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.gold.withValues(alpha: 0.4),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isDark
                      ? Colors.black.withValues(alpha: 0.3)
                      : AppColors.midnightNavy.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                // Total Count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.qazaTotalBalanceLabel ?? 'Total Pending Qaza',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: secondaryTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '${debt.total}',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.gold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n?.qazaPrayersUnit ?? 'prayers',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        debt.total == 0
                            ? (l10n?.qazaEmptyState ?? 'No pending qaza — mashaAllah!')
                            : (l10n?.qazaGentleEncouragement ?? 'Take it one prayer at a time 🤲'),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: primaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // Progress Ring: Repaid this week
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandBackground,
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.check_circle_outline_rounded,
                          size: 16,
                          color: AppColors.gold,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+${debt.repaidThisWeek}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          l10n?.qazaThisWeekLabel ?? 'This week',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Section Title
          Text(
            l10n?.qazaBreakdownTitle ?? 'Per-Prayer Breakdown',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: primaryTextColor,
            ),
          ),
          const SizedBox(height: 10),

          // Per-prayer breakdown rows
          ...TrackedPrayer.all.map((prayer) {
            final count = debt.countFor(prayer);
            final prayerName = _getPrayerName(l10n, prayer);

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.15)
                        : AppColors.midnightNavy.withValues(alpha: 0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Prayer icon indicator
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.14),
                    ),
                    child: const Icon(
                      Icons.access_time_rounded,
                      size: 18,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Prayer Name & Count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          prayerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: primaryTextColor,
                          ),
                        ),
                        Text(
                          l10n?.qazaPrayerDue(count) ?? '$count pending',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: count > 0 ? AppColors.gold : secondaryTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // "+1 Qaza prayed" button
                  ElevatedButton(
                    key: ValueKey('btn_repay_${prayer.keyName}'),
                    onPressed: () async {
                      await controller.repay(prayer);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              l10n?.qazaRepaidSnackbar(prayerName) ??
                                  '+1 $prayerName Qaza logged! May Allah accept it 🤲',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            backgroundColor: AppColors.midnightNavy,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.gold, width: 0.8),
                            ),
                            action: SnackBarAction(
                              label: l10n?.undo ?? 'Undo',
                              textColor: AppColors.gold,
                              onPressed: () async {
                                await controller.undo(prayer);
                              },
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.midnightNavyCardElevated
                          : AppColors.sandBackground,
                      foregroundColor: AppColors.gold,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: AppColors.gold.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, size: 16, color: AppColors.gold),
                        const SizedBox(width: 4),
                        Text(
                          l10n?.qazaRepayButton ?? '+1 Qaza Prayed',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
