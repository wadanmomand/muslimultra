import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hadith/domain/models/hadith_entry.dart';

class HadithCard extends StatelessWidget {
  final HadithEntry hadith;
  final VoidCallback onTap;

  const HadithCard({
    super.key,
    required this.hadith,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);

    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor.withAlpha((0.7 * 255).round()),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(isDark ? (0.25 * 255).round() : (0.05 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.gold.withAlpha((0.15 * 255).round()),
          highlightColor: AppColors.gold.withAlpha((0.08 * 255).round()),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Row: Number Badge, Title, and Arrow
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Number Badge
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gold.withAlpha((0.3 * 255).round()),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${hadith.number}',
                        style: const TextStyle(
                          color: AppColors.midnightNavyDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title and Narrator
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hadith.titleEn,
                            style: TextStyle(
                              color: primaryTextColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            hadith.narrator.isNotEmpty
                                ? '${hadith.narrator} · ${hadith.source}'
                                : hadith.source,
                            style: TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: AppColors.gold.withAlpha((0.7 * 255).round()),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Arabic snippet preview (2 lines max)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.midnightNavyDark.withAlpha((0.5 * 255).round())
                        : AppColors.sandCardElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: borderColor.withAlpha((0.4 * 255).round()),
                      width: 0.8,
                    ),
                  ),
                  child: Text(
                    hadith.arabic,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.amiri(
                      fontSize: 16,
                      height: 1.8,
                      color: primaryTextColor.withAlpha((0.9 * 255).round()),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Bottom row: Category tags
                if (hadith.categories.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: hadith.categories.take(3).map((cat) {
                      final localizedCat = l10n != null ? l10n.getHadithCategoryName(cat) : cat;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha((0.12 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: AppColors.gold.withAlpha((0.3 * 255).round()),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          localizedCat,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
