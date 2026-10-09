import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';

class PrayerLogRow extends StatelessWidget {
  final TrackedPrayer prayer;
  final String prayerName;
  final String formattedTime;
  final PrayerLogStatus? currentStatus;
  final ValueChanged<PrayerLogStatus> onStatusSelected;

  const PrayerLogRow({
    super.key,
    required this.prayer,
    required this.prayerName,
    required this.formattedTime,
    required this.currentStatus,
    required this.onStatusSelected,
  });

  IconData _getPrayerIcon(TrackedPrayer p) {
    switch (p) {
      case TrackedPrayer.fajr:
        return Icons.wb_twilight_rounded;
      case TrackedPrayer.dhuhr:
        return Icons.wb_sunny_rounded;
      case TrackedPrayer.asr:
        return Icons.brightness_5_rounded;
      case TrackedPrayer.maghrib:
        return Icons.nights_stay_rounded;
      case TrackedPrayer.isha:
        return Icons.bedtime_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: currentStatus == PrayerLogStatus.prayed
              ? AppColors.gold.withAlpha((0.6 * 255).round())
              : borderColor.withAlpha((0.7 * 255).round()),
          width: currentStatus == PrayerLogStatus.prayed ? 1.2 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? (0.2 * 255).round() : (0.04 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Prayer Icon with circular badge
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: currentStatus == PrayerLogStatus.prayed
                  ? AppColors.gold.withAlpha((0.2 * 255).round())
                  : (isDark
                      ? AppColors.midnightNavyDark.withAlpha((0.6 * 255).round())
                      : AppColors.sandCardElevated),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: currentStatus == PrayerLogStatus.prayed
                    ? AppColors.gold
                    : borderColor.withAlpha((0.5 * 255).round()),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              _getPrayerIcon(prayer),
              size: 16,
              color: currentStatus == PrayerLogStatus.prayed
                  ? AppColors.gold
                  : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
            ),
          ),
          const SizedBox(width: 8),

          // Prayer Name & Scheduled Time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  prayerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: primaryTextColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                if (formattedTime.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    formattedTime,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4),

          // Status Button Selector (Prayed / Missed / Qada)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusButton(
                keyName: 'btn_${prayer.keyName}_prayed',
                label: l10n?.statusPrayed ?? 'Prayed',
                status: PrayerLogStatus.prayed,
                isSelected: currentStatus == PrayerLogStatus.prayed,
                selectedBg: AppColors.gold,
                selectedFg: AppColors.midnightNavyDark,
                isDark: isDark,
              ),
              const SizedBox(width: 3),
              _buildStatusButton(
                keyName: 'btn_${prayer.keyName}_qada',
                label: l10n?.statusQadaPrayer ?? 'Qada',
                status: PrayerLogStatus.qada,
                isSelected: currentStatus == PrayerLogStatus.qada,
                selectedBg: const Color(0xFFFFB74D), // Warm Amber
                selectedFg: AppColors.midnightNavyDark,
                isDark: isDark,
              ),
              const SizedBox(width: 3),
              _buildStatusButton(
                keyName: 'btn_${prayer.keyName}_missed',
                label: l10n?.statusMissedPrayer ?? 'Missed',
                status: PrayerLogStatus.missed,
                isSelected: currentStatus == PrayerLogStatus.missed,
                selectedBg: const Color(0xFF64748B), // Slate Grey (neutral)
                selectedFg: Colors.white,
                isDark: isDark,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton({
    required String keyName,
    required String label,
    required PrayerLogStatus status,
    required bool isSelected,
    required Color selectedBg,
    required Color selectedFg,
    required bool isDark,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: ValueKey(keyName),
        onTap: () => onStatusSelected(status),
        borderRadius: BorderRadius.circular(6),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? selectedBg
                : (isDark
                    ? AppColors.midnightNavyDark.withAlpha((0.5 * 255).round())
                    : AppColors.sandCardElevated),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isSelected
                  ? selectedBg
                  : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? selectedFg
                  : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
