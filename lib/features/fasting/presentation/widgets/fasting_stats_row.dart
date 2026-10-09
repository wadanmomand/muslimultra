import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/fasting/presentation/providers/fasting_providers.dart';

class FastingStatsRow extends StatelessWidget {
  final FastingStats stats;

  const FastingStatsRow({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        // 1. Current Streak
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.local_fire_department_rounded,
            value: '${stats.streak}',
            unit: l10n.daysUnit,
            title: l10n.currentStreak,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // 2. Total this Month
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.calendar_today_rounded,
            value: '${stats.fastsThisMonth}',
            unit: l10n.fastsUnit,
            title: l10n.fastsThisMonth,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),

        // 3. Makeup Days Owed
        Expanded(
          child: _buildStatCard(
            context,
            icon: Icons.restore_rounded,
            value: '${stats.makeupDaysOwed}',
            unit: l10n.daysUnit,
            title: l10n.makeupOwed,
            isDark: isDark,
            isWarning: stats.makeupDaysOwed > 0,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String value,
    required String unit,
    required String title,
    required bool isDark,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isWarning
              ? AppColors.warning.withValues(alpha: 0.5)
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
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
          Icon(
            icon,
            size: 20,
            color: isWarning ? AppColors.warning : AppColors.gold,
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(width: 3),
              Flexible(
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
