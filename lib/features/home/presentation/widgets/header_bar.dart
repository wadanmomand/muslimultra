import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

class HomeHeaderBar extends ConsumerWidget {
  final VoidCallback? onOpenSettings;

  const HomeHeaderBar({
    super.key,
    this.onOpenSettings,
  });

  void _showNotificationSheet(BuildContext context, AppLocalizations l10n, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top drag handle
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.midnightNavyBorder
                          : AppColors.sandBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.notifications,
                        style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                            ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(sheetContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  // Empty state icon
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 26,
                      color: AppColors.gold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    l10n.noNotifications,
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                        ),
                  ),
                  const SizedBox(height: 6),
                  // Description
                  Text(
                    l10n.noNotificationsDesc,
                    textAlign: TextAlign.center,
                    style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          height: 1.4,
                        ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final hijriDate = ref.watch(hijriDateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isRtl = currentLocale.languageCode == 'ar' || currentLocale.languageCode == 'ur';
    final hijriFormatted = isRtl ? hijriDate.formattedAr() : hijriDate.formattedEn();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left: App Wordmark
          Flexible(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.appName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
                      ),
                ),
                Text(
                  l10n.tagline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Right: Hijri Date + Bell Icon
          Flexible(
            flex: 6,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.midnightNavyCardElevated
                          : AppColors.sandCardElevated,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDark
                            ? AppColors.midnightNavyBorder
                            : AppColors.sandBorder,
                      ),
                    ),
                    child: Text(
                      hijriFormatted,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Notification Bell Icon Button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _showNotificationSheet(context, l10n, isDark),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.midnightNavyCardElevated
                            : AppColors.sandCardElevated,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                            ? AppColors.midnightNavyBorder
                            : AppColors.sandBorder,
                        ),
                      ),
                      child: const Icon(
                        Icons.notifications_outlined,
                        size: 18,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
