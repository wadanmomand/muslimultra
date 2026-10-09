import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/deen/presentation/widgets/daily_deen_card.dart';
import 'package:muslim_ultra/features/deen/presentation/widgets/learning_card.dart';
import 'package:muslim_ultra/features/deen/presentation/widgets/name_of_day_card.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/header_bar.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/prayer_card.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/daily_verse_card.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/quick_actions.dart';
import 'package:muslim_ultra/features/quiz/presentation/widgets/daily_quiz_card.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onOpenSettings;

  const HomeScreen({
    super.key,
    required this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 600));
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(0, 8, 0, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: HomeHeaderBar(onOpenSettings: onOpenSettings),
                ),
                const SizedBox(height: 8),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: HomePrayerCard(),
                ),

                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: HomeQuickActions(),
                ),

                const SizedBox(height: 16),
                // Today's Deen card with XP, prayers, quran, dhikr, and streaks
                const DailyDeenCard(),

                const SizedBox(height: 12),
                // Daily Quiz Challenge Card
                const DailyQuizCard(),

                const SizedBox(height: 6),
                // Today's Learning Card
                const LearningCard(),

                const SizedBox(height: 6),
                // Name of Allah of the Day Card
                const NameOfDayCard(),

                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: DailyVerseCard(),
                ),

                const SizedBox(height: 16),
                // Privacy Notice Banner
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.midnightNavyDark.withValues(alpha: 0.5)
                          : AppColors.sandCardElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.shield_outlined, size: 18, color: AppColors.gold),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.privacyNotice,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
