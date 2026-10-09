import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hijri/data/hijri_calendar_service.dart';
import 'hijri_event_bottom_sheet.dart';

class HijriCountdownChip extends StatelessWidget {
  final UpcomingEventInfo info;

  const HijriCountdownChip({
    super.key,
    required this.info,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final eventName = info.event.localizedName(langCode);
    final days = info.daysRemaining;

    String countdownText;
    if (days == 0) {
      countdownText = '${l10n.todayEvent}! ✨';
    } else if (days == 1) {
      countdownText = '${l10n.tomorrow} 🌙';
    } else {
      countdownText = l10n.inDays(days);
    }

    return InkWell(
      onTap: () {
        HijriEventBottomSheet.show(
          context,
          event: info.event,
          hijriDate: info.hijriDate,
          gregorianDate: info.gregorianDate,
          daysRemaining: info.daysRemaining,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [
                    AppColors.midnightNavyCard,
                    AppColors.midnightNavyCardElevated,
                  ]
                : [
                    AppColors.sandCard,
                    AppColors.sandCardElevated,
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.gold.withValues(alpha: isDark ? 0.08 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.3),
                ),
              ),
              child: const Icon(
                Icons.stars_rounded,
                color: AppColors.gold,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    eventName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${info.hijriDate.day} ${info.hijriDate.monthNameEn} · ${info.gregorianDate.day}/${info.gregorianDate.month}/${info.gregorianDate.year}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                countdownText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.midnightNavy,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
