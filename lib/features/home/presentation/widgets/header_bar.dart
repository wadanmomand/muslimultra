import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';

class HomeHeaderBar extends ConsumerWidget {
  final VoidCallback onOpenSettings;

  const HomeHeaderBar({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.appName,
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
                  ),
            ),
            Text(
              l10n.tagline,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            // Quick Language Selector Chip
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: PopupMenuButton<String>(
                icon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 18, color: AppColors.gold),
                    const SizedBox(width: 4),
                    Text(
                      currentLocale.languageCode.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: AppColors.gold,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.gold),
                  ],
                ),
                onSelected: (langCode) {
                  ref.read(localeProvider.notifier).setLanguage(langCode);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'en',
                    child: Text(
                      'English',
                      style: TextStyle(
                        fontWeight: currentLocale.languageCode == 'en' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ar',
                    child: Text(
                      'العربية (Arabic)',
                      style: TextStyle(
                        fontWeight: currentLocale.languageCode == 'ar' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  PopupMenuItem(
                    value: 'ur',
                    child: Text(
                      'اردو (Urdu)',
                      style: TextStyle(
                        fontWeight: currentLocale.languageCode == 'ur' ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Theme Toggle Button
            IconButton(
              tooltip: l10n.theme,
              style: IconButton.styleFrom(
                backgroundColor: isDark ? AppColors.midnightNavyCardElevated : AppColors.sandCardElevated,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
              ),
              icon: Icon(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                color: AppColors.gold,
                size: 20,
              ),
              onPressed: () {
                ref.read(themeModeProvider.notifier).toggleTheme();
              },
            ),
          ],
        ),
      ],
    );
  }
}
