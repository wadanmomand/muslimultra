import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/presentation/screens/surah_reader_screen.dart';
import 'package:muslim_ultra/features/situations/domain/models/situation.dart';
import 'package:muslim_ultra/features/situations/presentation/providers/situations_providers.dart';

class SituationDetailScreen extends ConsumerWidget {
  final SituationModel situation;

  const SituationDetailScreen({
    super.key,
    required this.situation,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);

    final title = situation.getTitle(locale.languageCode);
    final comfort = situation.getComfort(locale.languageCode);
    final dhikrTranslation = situation.getDhikr(locale.languageCode);

    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('situation_detail_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 17,
            color: primaryTextColor,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Comfort Section Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: isDark ? AppColors.cardGradientDark : AppColors.sandCardGradientLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : AppColors.midnightNavy.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          situation.icon,
                          size: 16,
                          color: AppColors.gold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n?.situationsComfortHeader ?? 'Words of Comfort',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    comfort,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                      color: primaryTextColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Quran Ayat Section Header
            Row(
              children: [
                const Icon(Icons.menu_book_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Text(
                  l10n?.situationsAyatHeader ?? 'Quranic Solace',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Ayat List Cards
            ...situation.ayat.map((refAyah) {
              final ayahAsync = ref.watch(situationAyahProvider(refAyah));

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.15)
                          : AppColors.midnightNavy.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ayahAsync.when(
                  data: (ayah) {
                    if (ayah == null) return const SizedBox.shrink();
                    final surahInfo = TanzilQuranData.allSurahs.firstWhere(
                      (s) => s.number == refAyah.surah,
                      orElse: () => TanzilQuranData.allSurahs.first,
                    );
                    final isUrdu = locale.languageCode == 'ur';
                    final translation = isUrdu
                        ? ayah.translationUrdu
                        : ayah.translationEnglish;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Surah Header & Open Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${surahInfo.englishName} (${refAyah.surah}:${refAyah.ayah})',
                              style: const TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SurahReaderScreen(surah: surahInfo),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      l10n?.situationsOpenInQuran ?? 'Open',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    const Icon(Icons.arrow_forward_ios_rounded,
                                        size: 10, color: AppColors.gold),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Arabic Ayah
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Text(
                            ayah.textUthmani,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Translation
                        if (translation.trim().isNotEmpty)
                          Directionality(
                            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                            child: Text(
                              translation,
                              textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                              style: TextStyle(
                                fontFamily: isUrdu ? 'NotoNastaliqUrdu' : null,
                                fontSize: isUrdu ? 13 : 12.5,
                                height: isUrdu ? 1.8 : 1.4,
                                color: secondaryTextColor,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.gold),
                    ),
                  ),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              );
            }),

            const SizedBox(height: 12),

            // Dhikr / Dua Section Header
            Row(
              children: [
                const Icon(Icons.favorite_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n?.situationsDhikrHeader ?? 'Recommended Dua & Dhikr',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dhikr Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.2)
                        : AppColors.midnightNavy.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Arabic Dhikr
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Text(
                      situation.dhikrAr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        height: 1.8,
                        fontWeight: FontWeight.bold,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Dhikr Translation
                  Directionality(
                    textDirection: locale.languageCode == 'ur' ? TextDirection.rtl : TextDirection.ltr,
                    child: Text(
                      dhikrTranslation,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: locale.languageCode == 'ur' ? 'NotoNastaliqUrdu' : null,
                        fontSize: locale.languageCode == 'ur' ? 13.5 : 13,
                        height: 1.5,
                        color: primaryTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Copy Button
                  Center(
                    child: OutlinedButton.icon(
                      key: const ValueKey('btn_copy_situation_dhikr'),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(
                          text: '${situation.dhikrAr}\n\n$dhikrTranslation',
                        ));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle_outline_rounded,
                                    color: Colors.white, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    l10n?.situationsDhikrCopiedToast ?? 'Dua copied to clipboard',
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: AppColors.midnightNavy,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AppColors.gold, width: 0.8),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 15, color: AppColors.gold),
                      label: Text(
                        l10n?.copy ?? 'Copy',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Supportive Disclaimer Notice
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 15, color: AppColors.gold),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.situationsDisclaimer ??
                          'Comfort texts are original supportive words, not religious rulings.',
                      style: TextStyle(
                        fontSize: 11,
                        color: secondaryTextColor,
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
    );
  }
}
