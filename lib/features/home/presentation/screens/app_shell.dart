import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/settings/presentation/screens/settings_sheet.dart';
import 'package:muslim_ultra/features/home/presentation/screens/home_screen.dart';
import 'package:muslim_ultra/features/prayer/presentation/screens/prayer_screen.dart';
import 'package:muslim_ultra/features/quran/presentation/screens/quran_screen.dart';
import 'package:muslim_ultra/features/dua/presentation/screens/dua_screen.dart';
import 'package:muslim_ultra/features/ai/presentation/screens/ai_deen_screen.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      HomeScreen(onOpenSettings: () => SettingsSheet.show(context)),
      const PrayerScreen(),
      const QuranScreen(),
      const DuaScreen(),
      const AiDeenScreen(),
    ];

    final navItems = [
      (icon: Icons.today_outlined, activeIcon: Icons.today_rounded, label: l10n.navHome),
      (icon: Icons.access_time_outlined, activeIcon: Icons.access_time_filled_rounded, label: l10n.navPrayer),
      (icon: Icons.menu_book_outlined, activeIcon: Icons.menu_book_rounded, label: l10n.navQuran),
      (icon: Icons.favorite_border_rounded, activeIcon: Icons.favorite_rounded, label: l10n.navDua),
      (icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome_rounded, label: l10n.navAi),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.midnightNavy : AppColors.sandCard,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.3)
                  : AppColors.midnightNavy.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(navItems.length, (index) {
                final item = navItems[index];
                final isSelected = currentIndex == index;

                return Expanded(
                  child: InkWell(
                    onTap: () {
                      ref.read(bottomNavIndexProvider.notifier).state = index;
                    },
                    borderRadius: BorderRadius.circular(16),
                    splashColor: AppColors.gold.withValues(alpha: 0.1),
                    highlightColor: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.gold.withValues(alpha: 0.18)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              size: 22,
                              color: isSelected
                                  ? AppColors.gold
                                  : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected
                                  ? (isDark ? AppColors.goldLight : AppColors.goldDark)
                                  : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
