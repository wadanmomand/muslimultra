import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/core/config/app_config.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const SettingsSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLocale = ref.watch(localeProvider);
    final currentThemeMode = ref.watch(themeModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                const Icon(Icons.settings, color: AppColors.gold),
                const SizedBox(width: 10),
                Text(
                  l10n.settings,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Language Selection Section
            Text(
              l10n.language,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildLanguageOption(
                  context,
                  ref,
                  code: 'en',
                  title: 'English',
                  selected: currentLocale.languageCode == 'en',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildLanguageOption(
                  context,
                  ref,
                  code: 'ar',
                  title: 'العربية',
                  selected: currentLocale.languageCode == 'ar',
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildLanguageOption(
                  context,
                  ref,
                  code: 'ur',
                  title: 'اردو',
                  selected: currentLocale.languageCode == 'ur',
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Theme Selection Section
            Text(
              l10n.theme,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildThemeOption(
                  context,
                  ref,
                  mode: ThemeMode.dark,
                  title: l10n.themeDark,
                  icon: Icons.dark_mode_outlined,
                  selected: currentThemeMode == ThemeMode.dark,
                  isDark: isDark,
                ),
                const SizedBox(width: 8),
                _buildThemeOption(
                  context,
                  ref,
                  mode: ThemeMode.light,
                  title: l10n.themeLight,
                  icon: Icons.light_mode_outlined,
                  selected: currentThemeMode == ThemeMode.light,
                  isDark: isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // App Information & Privacy Badge
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user_outlined, color: AppColors.gold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${AppConfig.appName} (${AppConfig.milestone})',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                        Text(
                          AppConfig.packageName,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(
    BuildContext context,
    WidgetRef ref, {
    required String code,
    required String title,
    required bool selected,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(localeProvider.notifier).setLanguage(code);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.2)
                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: selected
                  ? AppColors.gold
                  : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    WidgetRef ref, {
    required ThemeMode mode,
    required String title,
    required IconData icon,
    required bool selected,
    required bool isDark,
  }) {
    return Expanded(
      child: InkWell(
        onTap: () {
          ref.read(themeModeProvider.notifier).setThemeMode(mode);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.gold.withValues(alpha: 0.2)
                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.gold
                  : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected
                    ? AppColors.gold
                    : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? AppColors.gold
                        : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
