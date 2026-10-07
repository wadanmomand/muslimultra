import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/theme/app_typography.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/quran/domain/models/surah.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/quran/domain/models/reciter.dart';
import 'package:muslim_ultra/features/quran/presentation/providers/quran_providers.dart';

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ayahsAsync = ref.watch(activeSurahAyahsProvider);
    final fontSizes = ref.watch(fontSizesProvider);
    final audioState = ref.watch(quranAudioProvider);
    final currentLocale = ref.watch(localeProvider);
    final isUrdu = currentLocale.languageCode == 'ur';

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
          Expanded(
            child: ayahsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (err, _) => Center(
                child: Text('Error loading surah: $err'),
              ),
              data: (ayahs) {
                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: ayahs.length + 1, // +1 for Bismillah Header
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Bismillah Header (except for Surah At-Tawbah 9)
                      if (widget.surah.number == 9) return const SizedBox(height: 8);
                      return _buildBismillahHeader(isDark);
                    }

                    final ayahIndex = index - 1;
                    final ayah = ayahs[ayahIndex];
                    final isPlaying = audioState.playingSurahNumber == widget.surah.number &&
                        audioState.playingAyahNumber == ayah.numberInSurah;

                    return _buildAyahCard(
                      context: context,
                      ayah: ayah,
                      isPlaying: isPlaying,
                      isDark: isDark,
                      fontSizes: fontSizes,
                      isUrdu: isUrdu,
                      l10n: l10n,
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
    required bool isPlaying,
    required bool isDark,
    required Map<String, double> fontSizes,
    required bool isUrdu,
    required AppLocalizations l10n,
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
                  // Play Audio Button
                  IconButton(
                    tooltip: 'Play Ayah Audio',
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                      color: AppColors.gold,
                      size: 22,
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
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.goldLight,
                      size: 20,
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
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, size: 14, color: AppColors.gold),
                          SizedBox(width: 4),
                          Text(
                            'Ask AI',
                            style: TextStyle(
                              fontSize: 11,
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

          // Uthmani Arabic Text
          Text(
            ayah.textUthmani,
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTypography.quranAyahText(
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              fontSize: fontSizes['arabic'] ?? 24.0,
            ),
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

  Widget _buildAudioPlayerBar(BuildContext context, bool isDark, QuranAudioState audioState) {
    final reciter = ref.watch(selectedReciterProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ayah ${audioState.playingAyahNumber}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.gold),
                ),
                Text(
                  reciter.name,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.skip_previous, color: AppColors.goldLight),
              onPressed: () => ref.read(quranAudioProvider.notifier).playPrevious(),
            ),
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.goldGradient,
              ),
              child: IconButton(
                icon: Icon(
                  audioState.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: AppColors.midnightNavyDark,
                ),
                onPressed: () => ref.read(quranAudioProvider.notifier).togglePlayPause(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.skip_next, color: AppColors.goldLight),
              onPressed: () => ref.read(quranAudioProvider.notifier).playNext(),
            ),
            IconButton(
              icon: const Icon(Icons.stop, color: AppColors.error),
              onPressed: () => ref.read(quranAudioProvider.notifier).stop(),
            ),
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
