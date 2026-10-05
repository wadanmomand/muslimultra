import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/theme/app_typography.dart';

class DailyVerseCard extends StatelessWidget {
  const DailyVerseCard({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: isDark ? AppColors.cardGradientDark : null,
        color: isDark ? null : AppColors.sandCard,
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_stories, color: AppColors.gold, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    l10n.dailyVerse,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
              Text(
                'Surah Al-Baqarah (2:186)',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Arabic Text with Amiri Font
          Text(
            'وَإِذَا سَأَلَكَ عِبَادِي عَنِّي فَإِنِّي قَرِيبٌ ۖ أُجِيبُ دَعْوَةَ الدَّاعِ إِذَا دَعَانِ',
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: AppTypography.quranAyahText(
              color: isDark ? AppColors.goldLight : AppColors.midnightNavy,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '"And when My servants ask you concerning Me, indeed I am near. I respond to the invocation of the supplicant when he calls upon Me."',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}
