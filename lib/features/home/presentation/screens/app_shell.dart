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

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) {
            ref.read(bottomNavIndexProvider.notifier).state = index;
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.today_outlined),
              activeIcon: const Icon(Icons.today),
              label: l10n.navHome,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.access_time_outlined),
              activeIcon: const Icon(Icons.access_time_filled),
              label: l10n.navPrayer,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.menu_book_outlined),
              activeIcon: const Icon(Icons.menu_book),
              label: l10n.navQuran,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.favorite_border),
              activeIcon: const Icon(Icons.favorite),
              label: l10n.navDua,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome_outlined),
              activeIcon: const Icon(Icons.auto_awesome),
              label: l10n.navAi, // "Muslim AI" (Spec §1)
            ),
          ],
        ),
      ),
    );
  }
}
