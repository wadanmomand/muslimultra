import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/tafsir/domain/models/tafsir_entry.dart';
import 'package:muslim_ultra/features/tafsir/presentation/providers/tafsir_providers.dart';

/// Modal Bottom Sheet displaying classical Tafsir (Jalalayn & Al-Muyassar) for an Ayah
class TafsirSheet extends ConsumerStatefulWidget {
  final TafsirEntry tafsir;
  final String surahName;
  final int surahNumber;
  final int ayahNumber;
  final TafsirEntry? muyassarTafsir;

  const TafsirSheet({
    super.key,
    required this.tafsir,
    required this.surahName,
    required this.surahNumber,
    required this.ayahNumber,
    this.muyassarTafsir,
  });

  /// Displays the Tafsir Bottom Sheet
  static Future<void> show(
    BuildContext context, {
    required TafsirEntry tafsir,
    required String surahName,
    required int surahNumber,
    required int ayahNumber,
    TafsirEntry? muyassarTafsir,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TafsirSheet(
        tafsir: tafsir,
        surahName: surahName,
        surahNumber: surahNumber,
        ayahNumber: ayahNumber,
        muyassarTafsir: muyassarTafsir,
      ),
    );
  }

  @override
  ConsumerState<TafsirSheet> createState() => _TafsirSheetState();
}

class _TafsirSheetState extends ConsumerState<TafsirSheet> {
  TafsirSource _selectedSource = TafsirSource.jalalayn;

  // For Jalalayn: 0: English (Jalalayn), 1: Arabic (Jalalayn), 2: Urdu (Bayan-ul-Quran)
  int _selectedTab = 0;
  bool _didInitLocale = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didInitLocale) {
      final locale = Localizations.localeOf(context).languageCode;
      if (locale == 'ar') {
        _selectedTab = 1;
      } else if (locale == 'ur') {
        _selectedTab = 2;
      } else {
        _selectedTab = 0;
      }
      _didInitLocale = true;
    }
  }

  void _copyToClipboard(BuildContext context, String textToCopy, AppLocalizations? l10n) {
    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.tafsirCopiedToast ?? 'Tafsir copied to clipboard',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.midnightNavyDark,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxSheetHeight = MediaQuery.of(context).size.height * 0.85;

    // Resolve Muyassar entry
    final muyassarAsync = ref.watch(allMuyassarTafsirProvider);
    final muyassarMap = muyassarAsync.valueOrNull ?? const <String, TafsirEntry>{};
    final muyassarEntry = widget.muyassarTafsir ??
        muyassarMap['${widget.surahNumber}:${widget.ayahNumber}'];

    // Determine active copy text and attribution footer
    String activeTextForCopy = '';
    String currentSourceFooter = '';

    if (_selectedSource == TafsirSource.muyassar) {
      activeTextForCopy = muyassarEntry?.ar ?? '';
      currentSourceFooter = l10n?.tafsirSourceMuyassarAttribution ??
          'Tafsir al-Muyassar — King Fahd Quran Printing Complex';
    } else {
      final hasArabic = widget.tafsir.hasArabic;
      if (_selectedTab == 1) {
        activeTextForCopy = hasArabic ? widget.tafsir.ar : widget.tafsir.en;
      } else if (_selectedTab == 2) {
        activeTextForCopy = widget.tafsir.ur;
      } else {
        activeTextForCopy = widget.tafsir.en;
      }

      currentSourceFooter = switch (_selectedTab) {
        2 => (l10n?.tafsirSourceBayanUlQuran ?? 'Bayan-ul-Quran — Dr. Israr Ahmed'),
        _ => (l10n?.tafsirSourceJalalayn ?? 'Tafsir al-Jalalayn — al-Mahalli & al-Suyuti'),
      };
    }

    return Container(
      constraints: BoxConstraints(maxHeight: maxSheetHeight),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.gold.withValues(alpha: 0.35) : AppColors.gold.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header: Ayah reference + Copy button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.menu_book_outlined,
                      color: AppColors.gold,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.tafsir ?? 'Tafsir',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.goldLight : AppColors.goldDark,
                          ),
                        ),
                        Text(
                          '${widget.surahName} ${widget.surahNumber}:${widget.ayahNumber}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Copy Button
                  IconButton(
                    key: const ValueKey('tafsir_copy_button'),
                    tooltip: l10n?.tafsirCopyLabel ?? 'Copy',
                    icon: const Icon(Icons.copy_rounded, color: AppColors.gold, size: 20),
                    onPressed: () => _copyToClipboard(context, activeTextForCopy, l10n),
                  ),
                ],
              ),
            ),

            // Source Selector: Jalalayn vs Muyassar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.midnightNavyCard.withValues(alpha: 0.8)
                      : AppColors.sandCard.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
                child: Row(
                  children: [
                    _buildSourceOption(
                      source: TafsirSource.jalalayn,
                      label: l10n?.tafsirSourceSelectorJalalayn ?? 'Jalalayn / Bayan-ul-Quran',
                      isDark: isDark,
                      keyName: 'tafsir_source_toggle_jalalayn',
                    ),
                    _buildSourceOption(
                      source: TafsirSource.muyassar,
                      label: l10n?.tafsirSourceSelectorMuyassar ?? 'Al-Muyassar (Arabic)',
                      isDark: isDark,
                      keyName: 'tafsir_source_toggle_muyassar',
                    ),
                  ],
                ),
              ),
            ),

            // Language Selector Tabs (Only shown when Jalalayn / Trilingual is selected)
            if (_selectedSource == TafsirSource.jalalayn)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      _buildLanguageTab(
                        index: 0,
                        label: l10n?.tafsirTabEnglish ?? 'English',
                        isDark: isDark,
                      ),
                      _buildLanguageTab(
                        index: 1,
                        label: l10n?.tafsirTabArabic ?? 'العربية',
                        isDark: isDark,
                      ),
                      _buildLanguageTab(
                        index: 2,
                        label: l10n?.tafsirTabUrdu ?? 'اردو',
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 4),

            // Main Scrollable Tafsir Content Area
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _selectedSource == TafsirSource.muyassar
                    ? _buildMuyassarBody(context, isDark, l10n, muyassarEntry)
                    : _buildJalalaynBody(context, isDark, l10n),
              ),
            ),

            // Source attribution footer
            Container(
              key: const ValueKey('tafsir_footer_attribution'),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.midnightNavyCard.withValues(alpha: 0.6)
                    : AppColors.sandCard.withValues(alpha: 0.6),
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_outlined,
                    color: AppColors.gold,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      currentSourceFooter,
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required TafsirSource source,
    required String label,
    required bool isDark,
    required String keyName,
  }) {
    final isSelected = _selectedSource == source;
    return Expanded(
      child: InkWell(
        key: ValueKey(keyName),
        onTap: () {
          setState(() {
            _selectedSource = source;
          });
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold.withValues(alpha: isDark ? 0.25 : 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isSelected
                ? Border.all(color: AppColors.gold.withValues(alpha: 0.6), width: 1.2)
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected
                  ? (isDark ? AppColors.goldLight : AppColors.goldDark)
                  : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageTab({
    required int index,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedTab == index;
    return Expanded(
      child: InkWell(
        key: ValueKey('tafsir_tab_$index'),
        onTap: () {
          setState(() {
            _selectedTab = index;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.gold : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? AppColors.midnightNavyDark
                  : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMuyassarBody(
    BuildContext context,
    bool isDark,
    AppLocalizations? l10n,
    TafsirEntry? muyassarEntry,
  ) {
    if (muyassarEntry == null || !muyassarEntry.hasArabic) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          child: Text(
            l10n?.tafsirNotAvailableSurah ?? 'Commentary not available in Al-Muyassar for this Surah',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
            ),
          ),
        ),
      );
    }

    final locale = Localizations.localeOf(context).languageCode;
    final showArabicOnlyNotice = locale != 'ar';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showArabicOnlyNotice)
          Container(
            key: const ValueKey('tafsir_muyassar_arabic_only_note'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.tafsirMuyassarArabicOnlyNote ?? '(Available in Arabic only for this source)',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
        SelectableText(
          muyassarEntry.ar,
          key: const ValueKey('tafsir_muyassar_text'),
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 18.5,
            height: 1.85,
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildJalalaynBody(BuildContext context, bool isDark, AppLocalizations? l10n) {
    // English Tab (Tafsir al-Jalalayn)
    if (_selectedTab == 0) {
      return SelectableText(
        widget.tafsir.en,
        style: TextStyle(
          fontSize: 15,
          height: 1.6,
          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
        ),
      );
    }

    // Arabic Tab (Tafsir al-Jalalayn)
    if (_selectedTab == 1) {
      if (widget.tafsir.hasArabic) {
        return SelectableText(
          widget.tafsir.ar,
          textAlign: TextAlign.right,
          textDirection: TextDirection.rtl,
          style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: 19,
            height: 1.8,
            color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
          ),
        );
      }

      // Arabic text missing fallback
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.gold),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.tafsirArabicUnavailableNote ?? '(Arabic text unavailable for this verse)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontStyle: FontStyle.italic,
                      color: isDark ? AppColors.goldLight : AppColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SelectableText(
            widget.tafsir.en,
            style: TextStyle(
              fontSize: 15,
              height: 1.6,
              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
            ),
          ),
        ],
      );
    }

    // Urdu Tab (Bayan-ul-Quran by Dr. Israr Ahmed)
    return SelectableText(
      widget.tafsir.ur,
      textAlign: TextAlign.right,
      textDirection: TextDirection.rtl,
      style: TextStyle(
        fontFamily: 'NotoNastaliqUrdu',
        fontSize: 15.5,
        height: 2.0,
        color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
      ),
    );
  }
}
