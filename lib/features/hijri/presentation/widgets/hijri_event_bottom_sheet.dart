import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hijri/domain/models/hijri_event.dart';
import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';

class HijriEventBottomSheet extends StatelessWidget {
  final HijriEvent event;
  final HijriDate? hijriDate;
  final DateTime? gregorianDate;
  final int? daysRemaining;

  const HijriEventBottomSheet({
    super.key,
    required this.event,
    this.hijriDate,
    this.gregorianDate,
    this.daysRemaining,
  });

  static Future<void> show(
    BuildContext context, {
    required HijriEvent event,
    HijriDate? hijriDate,
    DateTime? gregorianDate,
    int? daysRemaining,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => HijriEventBottomSheet(
        event: event,
        hijriDate: hijriDate,
        gregorianDate: gregorianDate,
        daysRemaining: daysRemaining,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final langCode = Localizations.localeOf(context).languageCode;

    final name = event.localizedName(langCode);
    final description = event.localizedDescription(langCode);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: AppColors.gold.withValues(alpha: 0.35),
            width: 1.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.midnightNavyBorder
                      : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Arabic calligraphy / name header
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.gold.withValues(alpha: 0.25),
                  ),
                ),
                child: Text(
                  event.nameAr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                    fontFamily: 'Amiri',
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Event Title
            Text(
              name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Date pills row
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                if (hijriDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: Text(
                      '${hijriDate!.day} ${hijriDate!.monthNameEn} ${hijriDate!.year} AH',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                    ),
                  ),
                if (gregorianDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: Text(
                      '${gregorianDate!.day}/${gregorianDate!.month}/${gregorianDate!.year}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                    ),
                  ),
                if (daysRemaining != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.gold,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      daysRemaining == 0
                          ? l10n.todayEvent
                          : daysRemaining == 1
                              ? l10n.tomorrow
                              : l10n.inDays(daysRemaining!),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.midnightNavy,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Significance / Description Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.gold, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        l10n.eventDetails,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Moon sighting disclaimer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.moonSightingDisclaimer,
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
