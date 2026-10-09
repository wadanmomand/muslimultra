import 'package:flutter/material.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';

class AyahShareCard extends StatelessWidget {
  final AyahModel ayah;
  final String surahName;
  final String? translationText;
  final String languageCode;
  final GlobalKey? boundaryKey;

  const AyahShareCard({
    super.key,
    required this.ayah,
    required this.surahName,
    this.translationText,
    this.languageCode = 'en',
    this.boundaryKey,
  });

  @override
  Widget build(BuildContext context) {
    final translation = translationText ??
        (languageCode == 'ur' ? ayah.translationUrdu : ayah.translationEnglish);

    // Dynamic sizing based on Arabic ayah text length
    final arabicLength = ayah.textUthmani.length;
    double arabicFontSize = 22;
    if (arabicLength < 60) {
      arabicFontSize = 26;
    } else if (arabicLength < 150) {
      arabicFontSize = 21;
    } else if (arabicLength < 300) {
      arabicFontSize = 18;
    } else {
      arabicFontSize = 16;
    }

    final isUrdu = languageCode == 'ur';

    return RepaintBoundary(
      key: boundaryKey,
      child: Container(
        width: 360,
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
        decoration: BoxDecoration(
          color: AppColors.midnightNavyCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.55),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Ornament & Surah Reference Header
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 24,
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.auto_stories_rounded,
                  color: AppColors.gold,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '$surahName • ${ayah.surahNumber}:${ayah.numberInSurah}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Arabic Ayah Text
            Directionality(
              textDirection: TextDirection.rtl,
              child: Text(
                ayah.textUthmani,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: arabicFontSize,
                  height: 1.85,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Divider
            Center(
              child: Container(
                width: 60,
                height: 1.5,
                decoration: BoxDecoration(
                  gradient: AppColors.goldGradient,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Translation Text (English / Urdu / Arabic)
            if (translation.trim().isNotEmpty)
              Directionality(
                textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                child: Text(
                  translation,
                  textAlign: TextAlign.center,
                  maxLines: 12,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                    fontSize: isUrdu ? 14 : 13,
                    height: isUrdu ? 1.9 : 1.45,
                    fontWeight: FontWeight.w400,
                    color: AppColors.darkTextSecondary,
                  ),
                ),
              ),
            const SizedBox(height: 20),

            // Watermark Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.midnightNavyDark,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.3),
                      width: 0.8,
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.nights_stay_rounded,
                        color: AppColors.gold,
                        size: 11,
                      ),
                      SizedBox(width: 5),
                      Text(
                        'Muslim Ultra',
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
