import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/academy/presentation/screens/academy_home_screen.dart';
import 'package:muslim_ultra/features/asma/presentation/screens/asma_list_screen.dart';
import 'package:muslim_ultra/features/dua_journal/presentation/screens/dua_journal_screen.dart';
import 'package:muslim_ultra/features/fasting/presentation/screens/fasting_dashboard_screen.dart';
import 'package:muslim_ultra/features/hadith/presentation/screens/hadith_library_screen.dart';
import 'package:muslim_ultra/features/hajj/presentation/screens/hajj_guide_screen.dart';
import 'package:muslim_ultra/features/hijri/presentation/screens/hijri_calendar_screen.dart';
import 'package:muslim_ultra/features/muhasaba/presentation/screens/muhasaba_screen.dart';
import 'package:muslim_ultra/features/situations/presentation/screens/situations_screen.dart';
import 'package:muslim_ultra/features/khatmah/presentation/screens/khatmah_screen.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/screens/prayer_tracker_screen.dart';
import 'package:muslim_ultra/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:muslim_ultra/features/sadaqah/presentation/screens/sadaqah_screen.dart';
import 'package:muslim_ultra/features/tasbih/presentation/screens/tasbih_screen.dart';
import 'package:muslim_ultra/features/zakat/presentation/screens/zakat_calculator_screen.dart';

class HomeQuickActions extends ConsumerWidget {
  const HomeQuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final actions = [
      {
        'title': l10n.quickActionPrayerLog,
        'icon': Icons.check_circle_outline_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const PrayerTrackerScreen()),
          );
        },
      },
      {
        'title': l10n.tasbih,
        'icon': Icons.fingerprint_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TasbihScreen()),
          );
        },
      },
      {
        'title': l10n.hijriCalendar,
        'icon': Icons.calendar_month_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HijriCalendarScreen()),
          );
        },
      },
      {
        'title': l10n.quickActionHadith,
        'icon': Icons.auto_stories_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HadithLibraryScreen()),
          );
        },
      },
      {
        'title': l10n.qibla,
        'icon': Icons.explore_rounded,
        'onTap': () {
          ref.read(prayerTabModeProvider.notifier).state = PrayerTabMode.qibla;
          ref.read(bottomNavIndexProvider.notifier).state = 1;
        },
      },
      {
        'title': l10n.navQuran,
        'icon': Icons.menu_book_rounded,
        'onTap': () {
          ref.read(bottomNavIndexProvider.notifier).state = 2;
        },
      },
      {
        'title': l10n.hajjQuickActionTitle,
        'icon': Icons.luggage_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HajjGuideScreen()),
          );
        },
      },
      {
        'title': l10n.muhasabaTitle,
        'icon': Icons.nights_stay_outlined,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MuhasabaScreen()),
          );
        },
      },
      {
        'title': l10n.situationsQuickActionTitle,
        'icon': Icons.support_agent_outlined,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SituationsScreen()),
          );
        },
      },
      {
        'title': l10n.khatmahQuickActionTitle,
        'icon': Icons.bookmark_added_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const KhatmahScreen()),
          );
        },
      },
      {
        'title': l10n.sadaqahQuickActionTitle,
        'icon': Icons.volunteer_activism_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SadaqahScreen()),
          );
        },
      },
      {
        'title': l10n.quizQuickActionTitle,
        'icon': Icons.quiz_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const QuizScreen()),
          );
        },
      },
      {
        'title': l10n.duaJournalQuickActionTitle,
        'icon': Icons.edit_note_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const DuaJournalScreen()),
          );
        },
      },


      {
        'title': l10n.fasting,
        'icon': Icons.nights_stay_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const FastingDashboardScreen()),
          );
        },
      },
      {
        'title': l10n.asmaUlHusna,
        'icon': Icons.stars_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AsmaListScreen()),
          );
        },
      },
      {
        'title': l10n.zakat,
        'icon': Icons.calculate_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen()),
          );
        },
      },
      {
        'title': l10n.academy,
        'icon': Icons.school_rounded,
        'onTap': () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AcademyHomeScreen()),
          );
        },
      },
      {
        'title': l10n.navDua,
        'icon': Icons.favorite_border_rounded,
        'onTap': () {
          ref.read(bottomNavIndexProvider.notifier).state = 3;
        },
      },
      {
        'title': l10n.navAi,
        'icon': Icons.auto_awesome,
        'onTap': () {
          ref.read(bottomNavIndexProvider.notifier).state = 4;
        },
      },
      {
        'title': l10n.prayerTimes,
        'icon': Icons.access_time_filled_rounded,
        'onTap': () {
          ref.read(prayerTabModeProvider.notifier).state = PrayerTabMode.times;
          ref.read(bottomNavIndexProvider.notifier).state = 1;
        },
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.features,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: actions.map((act) {
              final title = act['title'] as String;
              final icon = act['icon'] as IconData;
              final onTap = act['onTap'] as VoidCallback;

              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 76,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDark
                              ? Colors.black.withValues(alpha: 0.2)
                              : AppColors.midnightNavy.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.gold.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.gold.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: AppColors.gold,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
