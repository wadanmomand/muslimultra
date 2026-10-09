import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/theme/app_typography.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/quran/domain/models/surah.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/quran/domain/models/reciter.dart';
import 'package:muslim_ultra/features/quran/domain/models/tajweed_rule.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/tajweed_providers.dart';
import 'package:muslim_ultra/features/quran/presentation/widgets/tajweed_legend_sheet.dart';
import 'package:muslim_ultra/features/quran/presentation/widgets/tajweed_ayah_text.dart';
import 'package:muslim_ultra/features/tafsir/domain/models/tafsir_entry.dart';
import 'package:muslim_ultra/features/tafsir/presentation/providers/tafsir_providers.dart';
import 'package:muslim_ultra/features/tafsir/presentation/widgets/tafsir_sheet.dart';
import 'package:muslim_ultra/features/share_card/presentation/widgets/ayah_share_preview_dialog.dart';

class SurahReaderScreen extends ConsumerStatefulWidget {
  final SurahModel surah;

  const SurahReaderScreen({
    super.key,
    required this.surah,
  });

  @override
  ConsumerState<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends ConsumerState<SurahReaderScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showAppearanceSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuranAppearanceSheet(),
    );
  }

  void _showReciterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const ReciterSelectionSheet(),
    );
  }

  void _navigateToSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > 114) return;
    final nextSurah = TanzilQuranData.allSurahs[surahNumber - 1];
    ref.read(activeSurahProvider.notifier).state = nextSurah;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SurahReaderScreen(surah: nextSurah),
      ),
    );
  }

  String _toArabicIndicDigits(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((char) {
      final d = int.tryParse(char);
      return d != null ? digits[d] : char;
    }).join('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ayahsAsync = ref.watch(surahAyahsProvider(widget.surah.number));
    final fontSizes = ref.watch(fontSizesProvider);
    final audioState = ref.watch(quranAudioProvider);
    final readingMode = ref.watch(quranReadingModeProvider);
    final isTajweedEnabled = ref.watch(tajweedEnabledProvider);
    final tajweedAsync = ref.watch(surahTajweedAnnotationsProvider(widget.surah.number));
    final tajweedMap = tajweedAsync.valueOrNull ?? const {};
    final currentLocale = ref.watch(localeProvider);
    final isUrdu = currentLocale.languageCode == 'ur';

    // Tafsir data (v1.9)
    final tafsirAsync = ref.watch(allTafsirProvider);
    final tafsirMap = tafsirAsync.valueOrNull ?? const <String, TafsirEntry>{};
    final isFullyCovered = widget.surah.number == 1 || widget.surah.number >= 78;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${widget.surah.number}. ${widget.surah.englishName}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              '${widget.surah.englishNameTranslation} · ${widget.surah.numberOfAyahs} Ayahs',
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Audio Reciter',
            icon: const Icon(Icons.record_voice_over_outlined, color: AppColors.gold),
            onPressed: () => _showReciterSheet(context),
          ),
          IconButton(
            tooltip: 'Text Size',
            icon: const Icon(Icons.format_size, color: AppColors.goldLight),
            onPressed: () => _showAppearanceSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Reading Mode & Tajweed Mode Controls
          _buildReadingControls(context, isDark, l10n, readingMode, isTajweedEnabled),

          // Tafsir Coverage Indicator Hint (Step 3: shown for partially / not covered surahs)
          if (!isFullyCovered)
            _buildTafsirCoverageHint(context, isDark, l10n),

          Expanded(
            child: ayahsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (err, _) => _buildErrorState(context, isDark, l10n),
              data: (ayahs) {
                if (readingMode == QuranReadingMode.mushaf) {
                  return _buildMushafView(
                    context: context,
                    ayahs: ayahs,
                    tajweedMap: tajweedMap,
                    isTajweedEnabled: isTajweedEnabled,
                    isDark: isDark,
                    fontSizes: fontSizes,
                    audioState: audioState,
                    l10n: l10n,
                    tafsirMap: tafsirMap,
                  );
                }

                // Translation Mode View
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: ayahs.length + 2, // +1 Bismillah Header, +1 Footer
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Bismillah Header (except for Surah At-Tawbah 9)
                      if (widget.surah.number == 9) return const SizedBox(height: 8);
                      return _buildBismillahHeader(isDark);
                    }

                    if (index == ayahs.length + 1) {
                      return _buildSurahNavigationFooter(isDark, l10n);
                    }

                    final ayahIndex = index - 1;
                    final ayah = ayahs[ayahIndex];
                    final isPlaying = audioState.playingSurahNumber == widget.surah.number &&
                        audioState.playingAyahNumber == ayah.numberInSurah;
                    final tafsirEntry = tafsirMap['${ayah.surahNumber}:${ayah.numberInSurah}'];

                    return _buildAyahCard(
                      context: context,
                      ayah: ayah,
                      tajweedAnnotations: tajweedMap[ayah.numberInSurah],
                      isTajweedEnabled: isTajweedEnabled,
                      isPlaying: isPlaying,
                      isDark: isDark,
                      fontSizes: fontSizes,
                      isUrdu: isUrdu,
                      l10n: l10n,
                      tafsirEntry: tafsirEntry,
                    );
                  },
                );
              },
            ),
          ),

          // Bottom Audio Control Bar
          if (audioState.playingAyahNumber != null &&
              audioState.playingSurahNumber == widget.surah.number)
            _buildAudioPlayerBar(context, isDark, audioState),
        ],
      ),
    );
  }

  Widget _buildTafsirCoverageHint(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Container(
      key: const ValueKey('tafsir_coverage_hint_banner'),
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, size: 14, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              l10n.tafsirCoverageHint,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.goldLight : AppColors.goldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadingControls(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
    QuranReadingMode currentMode,
    bool isTajweedEnabled,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 4),
      child: Row(
        children: [
          // Segmented Reading Mode (Translation / Mushaf)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildToggleOption(
                      key: const ValueKey('toggle_mode_translation'),
                      title: l10n.readingModeTranslation,
                      icon: Icons.translate_rounded,
                      isSelected: currentMode == QuranReadingMode.translation,
                      isDark: isDark,
                      onTap: () {
                        ref
                            .read(quranReadingModeProvider.notifier)
                            .setMode(QuranReadingMode.translation);
                      },
                    ),
                  ),
                  const SizedBox(width: 3),
                  Expanded(
                    child: _buildToggleOption(
                      key: const ValueKey('toggle_mode_mushaf'),
                      title: l10n.readingModeMushaf,
                      icon: Icons.menu_book_rounded,
                      isSelected: currentMode == QuranReadingMode.mushaf,
                      isDark: isDark,
                      onTap: () {
                        ref
                            .read(quranReadingModeProvider.notifier)
                            .setMode(QuranReadingMode.mushaf);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Tajweed Mode Toggle Pill + Info Legend Button
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isTajweedEnabled
                    ? AppColors.gold.withValues(alpha: 0.5)
                    : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  key: const ValueKey('toggle_tajweed_mode'),
                  onTap: () {
                    ref.read(tajweedEnabledProvider.notifier).toggle();
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isTajweedEnabled ? AppColors.gold : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isTajweedEnabled
                          ? [
                              BoxShadow(
                                color: AppColors.gold.withValues(alpha: 0.25),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          size: 14,
                          color: isTajweedEnabled
                              ? AppColors.midnightNavyDark
                              : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.sandTextSecondary),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          l10n.tajweedMode,
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: isTajweedEnabled ? FontWeight.bold : FontWeight.w500,
                            color: isTajweedEnabled
                                ? AppColors.midnightNavyDark
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.sandTextPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                InkWell(
                  key: const ValueKey('btn_tajweed_legend'),
                  onTap: () => TajweedLegendSheet.show(context),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      Icons.info_outline_rounded,
                      size: 15,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption({
    Key? key,
    required String title,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      key: key,
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.gold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.gold.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected
                  ? AppColors.midnightNavyDark
                  : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.sandTextSecondary),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.midnightNavyDark
                      : (isDark
                          ? AppColors.darkTextPrimary
                          : AppColors.sandTextPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMushafView({
    required BuildContext context,
    required List<AyahModel> ayahs,
    required Map<int, List<TajweedAnnotation>> tajweedMap,
    required bool isTajweedEnabled,
    required bool isDark,
    required Map<String, double> fontSizes,
    required QuranAudioState audioState,
    required AppLocalizations l10n,
    required Map<String, TafsirEntry> tafsirMap,
  }) {
    final arabicFontSize = fontSizes['arabic'] ?? 24.0;
    final bookmarks = ref.watch(quranBookmarksProvider);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: ayahs.length + 2, // 0: Surah Header & Bismillah, 1..N: Ayahs, N+1: Navigation Footer
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _buildMushafSurahHeader(isDark),
              if (widget.surah.number != 9) ...[
                const SizedBox(height: 12),
                _buildBismillahHeader(isDark),
              ],
              const SizedBox(height: 8),
            ],
          );
        }

        if (index == ayahs.length + 1) {
          return _buildSurahNavigationFooter(isDark, l10n);
        }

        final ayah = ayahs[index - 1];
        final isPlaying = audioState.playingSurahNumber == widget.surah.number &&
            audioState.playingAyahNumber == ayah.numberInSurah;
        final isBookmarked =
            bookmarks.contains('${ayah.surahNumber}:${ayah.numberInSurah}');
        final tafsirEntry = tafsirMap['${ayah.surahNumber}:${ayah.numberInSurah}'];

        return _buildMushafAyahCard(
          context: context,
          ayah: ayah,
          tajweedAnnotations: tajweedMap[ayah.numberInSurah],
          isTajweedEnabled: isTajweedEnabled,
          isPlaying: isPlaying,
          isBookmarked: isBookmarked,
          isDark: isDark,
          fontSize: arabicFontSize,
          l10n: l10n,
          tafsirEntry: tafsirEntry,
        );
      },
    );
  }

  Widget _buildMushafSurahHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.gold.withValues(alpha: 0.45),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.gold.withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.auto_awesome,
                  size: 13,
                  color: AppColors.gold.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.surah.name,
            textDirection: TextDirection.rtl,
            style: AppTypography.quranAyahText(
              color: AppColors.gold,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${widget.surah.englishName} · ${widget.surah.revelationType} · Juz ${widget.surah.startJuz} · ${widget.surah.numberOfAyahs} Ayahs',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.sandTextSecondary,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.35),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.auto_awesome,
                  size: 13,
                  color: AppColors.gold.withValues(alpha: 0.7),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: AppColors.gold.withValues(alpha: 0.35),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMushafAyahCard({
    required BuildContext context,
    required AyahModel ayah,
    List<TajweedAnnotation>? tajweedAnnotations,
    required bool isTajweedEnabled,
    required bool isPlaying,
    required bool isBookmarked,
    required bool isDark,
    required double fontSize,
    required AppLocalizations l10n,
    TafsirEntry? tafsirEntry,
  }) {
    final arabicNumber = _toArabicIndicDigits(ayah.numberInSurah);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          if (isPlaying) {
            ref.read(quranAudioProvider.notifier).togglePlayPause();
          } else {
            ref.read(quranAudioProvider.notifier).playAyah(
                  surahNumber: ayah.surahNumber,
                  ayahNumber: ayah.numberInSurah,
                );
            ref.read(lastReadProvider.notifier).setLastRead(
                  ayah.surahNumber,
                  ayah.numberInSurah,
                );
          }
        },
        onLongPress: () {
          _showMushafAyahActionSheet(context, ayah, isBookmarked, isDark, l10n, tafsirEntry);
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            color: isPlaying
                ? AppColors.gold.withValues(alpha: 0.15)
                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? AppColors.gold
                  : (isBookmarked
                      ? AppColors.gold.withValues(alpha: 0.5)
                      : (isDark
                          ? AppColors.midnightNavyBorder
                          : AppColors.sandBorder)),
              width: isPlaying ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isPlaying || isBookmarked || tafsirEntry != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (isPlaying)
                        Row(
                          children: [
                            const Icon(
                              Icons.volume_up_rounded,
                              size: 14,
                              color: AppColors.gold,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Ayah ${ayah.numberInSurah}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          'Ayah ${ayah.numberInSurah}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (tafsirEntry != null) ...[
                            InkWell(
                              key: ValueKey('btn_mushaf_tafsir_${ayah.surahNumber}_${ayah.numberInSurah}'),
                              onTap: () {
                                TafsirSheet.show(
                                  context,
                                  tafsir: tafsirEntry,
                                  surahName: widget.surah.englishName,
                                  surahNumber: ayah.surahNumber,
                                  ayahNumber: ayah.numberInSurah,
                                );
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.menu_book_outlined, size: 12, color: AppColors.gold),
                                    const SizedBox(width: 4),
                                    Text(
                                      l10n.tafsir,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          if (isBookmarked)
                            const Icon(
                              Icons.bookmark,
                              size: 16,
                              color: AppColors.goldLight,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Uthmani Arabic Text with Tajweed Coloring support & traditional end marker
              TajweedAyahText(
                textUthmani: ayah.textUthmani,
                annotations: tajweedAnnotations,
                isTajweedEnabled: isTajweedEnabled,
                isDark: isDark,
                fontSize: fontSize,
                endMarker: ' ﴿$arabicNumber﴾ ',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMushafAyahActionSheet(
    BuildContext context,
    AyahModel ayah,
    bool isBookmarked,
    bool isDark,
    AppLocalizations l10n,
    TafsirEntry? tafsirEntry,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border(
            top: BorderSide(
              color: isDark
                  ? AppColors.gold.withValues(alpha: 0.3)
                  : AppColors.sandBorder,
            ),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.midnightNavyBorder
                        : AppColors.sandBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${widget.surah.englishName} · Ayah ${ayah.numberInSurah}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              if (tafsirEntry != null)
                ListTile(
                  key: ValueKey('action_mushaf_tafsir_${ayah.surahNumber}_${ayah.numberInSurah}'),
                  leading: const Icon(Icons.menu_book_outlined, color: AppColors.gold),
                  title: Text(l10n.tafsir),
                  onTap: () {
                    Navigator.pop(ctx);
                    TafsirSheet.show(
                      context,
                      tafsir: tafsirEntry,
                      surahName: widget.surah.englishName,
                      surahNumber: ayah.surahNumber,
                      ayahNumber: ayah.numberInSurah,
                    );
                  },
                ),
              ListTile(
                key: ValueKey('action_mushaf_share_${ayah.surahNumber}_${ayah.numberInSurah}'),
                leading: const Icon(Icons.share_outlined, color: AppColors.gold),
                title: Text(l10n.shareAyahLabel),
                onTap: () {
                  Navigator.pop(ctx);
                  AyahSharePreviewDialog.show(
                    context,
                    ayah: ayah,
                    surahName: widget.surah.englishName,
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.play_circle_outline, color: AppColors.gold),
                title: const Text('Play Ayah Audio'),
                onTap: () {
                  Navigator.pop(ctx);
                  ref.read(quranAudioProvider.notifier).playAyah(
                        surahNumber: ayah.surahNumber,
                        ayahNumber: ayah.numberInSurah,
                      );
                  ref.read(lastReadProvider.notifier).setLastRead(
                        ayah.surahNumber,
                        ayah.numberInSurah,
                      );
                },
              ),
              ListTile(
                leading: Icon(
                  isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: AppColors.goldLight,
                ),
                title: Text(isBookmarked ? 'Remove Bookmark' : 'Bookmark Ayah'),
                onTap: () {
                  ref.read(quranBookmarksProvider.notifier).toggle(
                        ayah.surahNumber,
                        ayah.numberInSurah,
                      );
                  Navigator.pop(ctx);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSurahNavigationFooter(bool isDark, AppLocalizations l10n) {
    final hasPrevious = widget.surah.number > 1;
    final hasNext = widget.surah.number < 114;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasPrevious)
            OutlinedButton.icon(
              icon: const Icon(Icons.arrow_back, size: 16),
              label: Text(
                'Surah ${widget.surah.number - 1}',
                style: const TextStyle(fontSize: 12),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gold,
                side: BorderSide(color: AppColors.gold.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: () => _navigateToSurah(widget.surah.number - 1),
            )
          else
            const SizedBox.shrink(),
          if (hasNext)
            ElevatedButton.icon(
              icon: const Icon(Icons.arrow_forward, size: 16),
              label: Text(
                'Surah ${widget.surah.number + 1}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.midnightNavyDark,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
              ),
              onPressed: () => _navigateToSurah(widget.surah.number + 1),
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, bool isDark, AppLocalizations l10n) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : AppColors.midnightNavy.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
                ),
                child: const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.gold,
                  size: 30,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                l10n.quranLoadErrorTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.quranLoadErrorDesc,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: Text(l10n.retry),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.midnightNavyDark,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ref.invalidate(surahAyahsProvider(widget.surah.number));
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBismillahHeader(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
        ),
      ),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textDirection: TextDirection.rtl,
          style: AppTypography.quranAyahText(
            color: AppColors.gold,
            fontSize: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildAyahCard({
    required BuildContext context,
    required AyahModel ayah,
    List<TajweedAnnotation>? tajweedAnnotations,
    required bool isTajweedEnabled,
    required bool isPlaying,
    required bool isDark,
    required Map<String, double> fontSizes,
    required bool isUrdu,
    required AppLocalizations l10n,
    TafsirEntry? tafsirEntry,
  }) {
    final bookmarks = ref.watch(quranBookmarksProvider);
    final isBookmarked = bookmarks.contains('${ayah.surahNumber}:${ayah.numberInSurah}');

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isPlaying
            ? AppColors.gold.withValues(alpha: 0.12)
            : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isPlaying
              ? AppColors.gold
              : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
          width: isPlaying ? 1.8 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Ayah Header Strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  '${ayah.surahNumber}:${ayah.numberInSurah}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ),
              Row(
                children: [
                  // Tafsir Button (Affordance shown only when hasTafsir is true)
                  if (tafsirEntry != null) ...[
                    InkWell(
                      key: ValueKey('btn_tafsir_${ayah.surahNumber}_${ayah.numberInSurah}'),
                      onTap: () {
                        TafsirSheet.show(
                          context,
                          tafsir: tafsirEntry,
                          surahName: widget.surah.englishName,
                          surahNumber: ayah.surahNumber,
                          ayahNumber: ayah.numberInSurah,
                        );
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.menu_book_outlined, size: 13, color: AppColors.gold),
                            const SizedBox(width: 3),
                            Text(
                              l10n.tafsir,
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                  ],

                  // Share Ayah Card Button
                  IconButton(
                    key: ValueKey('btn_share_ayah_${ayah.surahNumber}_${ayah.numberInSurah}'),
                    tooltip: l10n.shareAyahLabel,
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.share_outlined,
                      color: AppColors.gold,
                      size: 18,
                    ),
                    onPressed: () {
                      AyahSharePreviewDialog.show(
                        context,
                        ayah: ayah,
                        surahName: widget.surah.englishName,
                      );
                    },
                  ),

                  // Play Audio Button
                  IconButton(
                    tooltip: 'Play Ayah Audio',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                      color: AppColors.gold,
                      size: 20,
                    ),
                    onPressed: () {
                      if (isPlaying) {
                        ref.read(quranAudioProvider.notifier).togglePlayPause();
                      } else {
                        ref.read(quranAudioProvider.notifier).playAyah(
                              surahNumber: ayah.surahNumber,
                              ayahNumber: ayah.numberInSurah,
                            );
                        ref.read(lastReadProvider.notifier).setLastRead(
                              ayah.surahNumber,
                              ayah.numberInSurah,
                            );
                      }
                    },
                  ),
                  // Bookmark Button
                  IconButton(
                    tooltip: 'Bookmark',
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.goldLight,
                      size: 18,
                    ),
                    onPressed: () {
                      ref.read(quranBookmarksProvider.notifier).toggle(
                            ayah.surahNumber,
                            ayah.numberInSurah,
                          );
                    },
                  ),
                  // "Ask Muslim AI" on Ayah Button (Spec §3 M2)
                  InkWell(
                    onTap: () {
                      final contextPrompt =
                          'Explain the context, meaning, and reflection for Surah ${widget.surah.englishName} (${ayah.surahNumber}:${ayah.numberInSurah}): "${ayah.textUthmani}" — Translation: "${isUrdu ? ayah.translationUrdu : ayah.translationEnglish}"';
                      ref.read(pendingAiQuestionContextProvider.notifier).state = contextPrompt;
                      // Switch navigation to the Muslim AI Tab (Index 4)
                      ref.read(bottomNavIndexProvider.notifier).state = 4;
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 13, color: AppColors.gold),
                          SizedBox(width: 3),
                          Text(
                            'Ask AI',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Uthmani Arabic Text with Tajweed Coloring support
          TajweedAyahText(
            textUthmani: ayah.textUthmani,
            annotations: tajweedAnnotations,
            isTajweedEnabled: isTajweedEnabled,
            isDark: isDark,
            fontSize: fontSizes['arabic'] ?? 24.0,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 10),

          // Translation Text (Saheeh International / Jalandhry Urdu)
          Text(
            isUrdu ? (ayah.translationUrdu.isNotEmpty ? ayah.translationUrdu : ayah.translationEnglish) : ayah.translationEnglish,
            textAlign: isUrdu ? TextAlign.right : TextAlign.left,
            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
            style: TextStyle(
              fontSize: fontSizes['translation'] ?? 14.0,
              fontFamily: isUrdu ? 'NotoNastaliqUrdu' : 'Inter',
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  Widget _buildAudioPlayerBar(
    BuildContext context,
    bool isDark,
    QuranAudioState audioState,
  ) {
    final reciter = ref.watch(selectedReciterProvider);
    final l10n = AppLocalizations.of(context)!;

    final posMs = audioState.position.inMilliseconds.toDouble();
    final durMs = audioState.duration.inMilliseconds.toDouble();
    final maxMs = durMs > 0 ? durMs : 1.0;
    final currentSliderVal = posMs.clamp(0.0, maxMs);

    final repeatIcon = switch (audioState.repeatMode) {
      QuranRepeatMode.off => Icons.repeat_rounded,
      QuranRepeatMode.ayah => Icons.repeat_one_rounded,
      QuranRepeatMode.surah => Icons.repeat_on_rounded,
    };

    final repeatLabel = switch (audioState.repeatMode) {
      QuranRepeatMode.off => l10n.audioRepeatOff,
      QuranRepeatMode.ayah => l10n.audioRepeatAyah,
      QuranRepeatMode.surah => l10n.audioRepeatSurah,
    };

    final hasActiveTimer = audioState.sleepTimerRemaining != null &&
        audioState.sleepTimerRemaining! > Duration.zero;
    final timerRemainingMins = hasActiveTimer
        ? (audioState.sleepTimerRemaining!.inMinutes +
            (audioState.sleepTimerRemaining!.inSeconds % 60 > 0 ? 1 : 0))
        : null;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Error feedback message if stream loading failed
              if (audioState.isError)
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wifi_off_rounded, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.audioLoadError,
                          style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),

              // Seek Slider Row
              Row(
                children: [
                  Text(
                    _formatDuration(audioState.position),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                    ),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
                        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
                        activeTrackColor: AppColors.gold,
                        inactiveTrackColor: isDark
                            ? AppColors.midnightNavyBorder
                            : AppColors.sandBorder,
                        thumbColor: AppColors.gold,
                        overlayColor: AppColors.gold.withValues(alpha: 0.2),
                      ),
                      child: Slider(
                        value: currentSliderVal,
                        min: 0.0,
                        max: maxMs,
                        onChanged: durMs > 0
                            ? (val) {
                                ref
                                    .read(quranAudioProvider.notifier)
                                    .seek(Duration(milliseconds: val.toInt()));
                              }
                            : null,
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(audioState.duration),
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                    ),
                  ),
                ],
              ),

              // Controls Main Row
              Row(
                children: [
                  // Ayah info & Reciter name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.surah.englishName} · Ayah ${audioState.playingAyahNumber}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppColors.gold,
                          ),
                        ),
                        Text(
                          reciter.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Speed Cycling Button
                  InkWell(
                    onTap: () => ref.read(quranAudioProvider.notifier).cyclePlaybackSpeed(),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCardElevated,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                        ),
                      ),
                      child: Text(
                        '${audioState.playbackSpeed}x',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Repeat Mode Button
                  IconButton(
                    tooltip: repeatLabel,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      repeatIcon,
                      size: 20,
                      color: audioState.repeatMode != QuranRepeatMode.off
                          ? AppColors.gold
                          : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                    ),
                    onPressed: () => ref.read(quranAudioProvider.notifier).cycleRepeatMode(),
                  ),
                  const SizedBox(width: 2),

                  // Sleep Timer Button
                  IconButton(
                    tooltip: l10n.audioSleepTimer,
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                    icon: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Icon(
                          hasActiveTimer ? Icons.timer : Icons.timer_outlined,
                          size: 20,
                          color: hasActiveTimer
                              ? AppColors.gold
                              : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                        ),
                        if (hasActiveTimer)
                          Positioned(
                            right: -6,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: AppColors.gold,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${timerRemainingMins}m',
                                style: const TextStyle(
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.midnightNavyDark,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    onPressed: () => QuranSleepTimerSheet.show(context),
                  ),
                  const SizedBox(width: 4),

                  // Transport controls: Previous, Play/Pause, Next, Stop
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.skip_previous_rounded, size: 22, color: AppColors.goldLight),
                    onPressed: () => ref.read(quranAudioProvider.notifier).playPrevious(),
                  ),
                  const SizedBox(width: 4),

                  // Play/Pause / Loading spinner
                  Container(
                    width: 38,
                    height: 38,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.goldGradient,
                    ),
                    child: audioState.isLoading
                        ? const Padding(
                            padding: EdgeInsets.all(10),
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: AppColors.midnightNavyDark,
                            ),
                          )
                        : IconButton(
                            padding: EdgeInsets.zero,
                            icon: Icon(
                              audioState.isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              size: 22,
                              color: AppColors.midnightNavyDark,
                            ),
                            onPressed: () =>
                                ref.read(quranAudioProvider.notifier).togglePlayPause(),
                          ),
                  ),
                  const SizedBox(width: 4),

                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.skip_next_rounded, size: 22, color: AppColors.goldLight),
                    onPressed: () => ref.read(quranAudioProvider.notifier).playNext(),
                  ),
                  const SizedBox(width: 4),

                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(),
                    icon: const Icon(Icons.stop_circle_outlined, size: 22, color: AppColors.error),
                    onPressed: () => ref.read(quranAudioProvider.notifier).stop(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Quran Sleep Timer Selection Bottom Sheet
class QuranSleepTimerSheet extends ConsumerWidget {
  const QuranSleepTimerSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const QuranSleepTimerSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(quranAudioProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final timerOptions = [
      (minutes: 0, label: l10n.audioSleepTimerOff),
      (minutes: 5, label: '5 Minutes'),
      (minutes: 10, label: '10 Minutes'),
      (minutes: 15, label: '15 Minutes'),
      (minutes: 30, label: '30 Minutes'),
      (minutes: 60, label: '60 Minutes (1 Hour)'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.timer_outlined, color: AppColors.gold, size: 22),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.audioSleepTimer,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...timerOptions.map((opt) {
              final isSelected = opt.minutes == 0
                  ? audioState.sleepTimerMinutes == null
                  : audioState.sleepTimerMinutes == opt.minutes;

              return InkWell(
                onTap: () {
                  ref
                      .read(quranAudioProvider.notifier)
                      .setSleepTimer(opt.minutes > 0 ? opt.minutes : null);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withValues(alpha: 0.18)
                        : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected
                            ? AppColors.gold
                            : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          opt.label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected
                                ? AppColors.gold
                                : (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.sandTextPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Font Size & Appearance Bottom Sheet
class QuranAppearanceSheet extends ConsumerWidget {
  const QuranAppearanceSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fontSizes = ref.watch(fontSizesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.format_size, color: AppColors.gold),
                SizedBox(width: 8),
                Text(
                  'Reading Typography Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Arabic Font Size', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${fontSizes['arabic']?.toInt()} px', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold)),
              ],
            ),
            Slider(
              value: fontSizes['arabic'] ?? 24.0,
              min: 18.0,
              max: 38.0,
              divisions: 10,
              activeColor: AppColors.gold,
              onChanged: (val) {
                ref.read(fontSizesProvider.notifier).setArabicFontSize(val);
              },
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Translation Font Size', style: TextStyle(fontWeight: FontWeight.w600)),
                Text('${fontSizes['translation']?.toInt()} px', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.gold)),
              ],
            ),
            Slider(
              value: fontSizes['translation'] ?? 14.0,
              min: 12.0,
              max: 22.0,
              divisions: 10,
              activeColor: AppColors.gold,
              onChanged: (val) {
                ref.read(fontSizesProvider.notifier).setTranslationFontSize(val);
              },
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

/// Reciter Selection Bottom Sheet
class ReciterSelectionSheet extends ConsumerWidget {
  const ReciterSelectionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentReciter = ref.watch(selectedReciterProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.3) : AppColors.sandBorder,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                Icon(Icons.record_voice_over, color: AppColors.gold),
                SizedBox(width: 8),
                Text(
                  'Select Reciter (EveryAyah CDN)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ...ReciterModel.availableReciters.map((r) {
              final isSelected = currentReciter.id == r.id;
              return InkWell(
                onTap: () {
                  ref.read(selectedReciterProvider.notifier).setReciter(r);
                  Navigator.pop(context);
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.gold.withValues(alpha: 0.18)
                        : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.gold
                          : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? AppColors.gold : (isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary),
                        size: 18,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r.name,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.gold : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                              ),
                            ),
                            Text(
                              '${r.bitrate} · EveryAyah CDN',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
