import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import '../widgets/header_bar.dart';
import '../widgets/prayer_card.dart';
import '../widgets/daily_verse_card.dart';
import '../widgets/quick_actions.dart';

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HomeHeaderBar(onOpenSettings: onOpenSettings),
                const SizedBox(height: 20),
                const HomePrayerCard(),
                const SizedBox(height: 24),
                const HomeQuickActions(),
                const SizedBox(height: 24),
                const DailyVerseCard(),
                const SizedBox(height: 24),
                // Daily Checklist Card
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppColors.gold, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                l10n.dailyChecklist,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '2/5 Completed',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildChecklistItem(context, l10n.fajr, true, isDark),
                      _buildChecklistItem(context, 'Morning Adhkar', true, isDark),
                      _buildChecklistItem(context, l10n.dhuhr, false, isDark),
                      _buildChecklistItem(context, 'Surah Al-Mulk', false, isDark),
                      _buildChecklistItem(context, l10n.isha, false, isDark),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Privacy Notice Banner (Spec §7)
                Container(
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
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistItem(BuildContext context, String title, bool checked, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
            color: checked ? AppColors.gold : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              decoration: checked ? TextDecoration.lineThrough : null,
              color: checked
                  ? (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary)
                  : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
