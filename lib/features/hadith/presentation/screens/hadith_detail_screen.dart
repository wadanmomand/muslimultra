import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hadith/domain/models/hadith_entry.dart';

class HadithDetailScreen extends StatefulWidget {
  final HadithEntry hadith;
  final List<HadithEntry>? allHadiths;

  const HadithDetailScreen({
    super.key,
    required this.hadith,
    this.allHadiths,
  });

  @override
  State<HadithDetailScreen> createState() => _HadithDetailScreenState();
}

class _HadithDetailScreenState extends State<HadithDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;
  late List<HadithEntry> _hadithList;

  @override
  void initState() {
    super.initState();
    _hadithList = widget.allHadiths != null && widget.allHadiths!.isNotEmpty
        ? widget.allHadiths!
        : [widget.hadith];

    final foundIdx = _hadithList.indexWhere((h) => h.number == widget.hadith.number);
    _currentIndex = foundIdx >= 0 ? foundIdx : 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _copyHadith(HadithEntry entry, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final buffer = StringBuffer();
    buffer.writeln('【${entry.titleEn} - Hadith #${entry.number}】');
    buffer.writeln();
    buffer.writeln(entry.arabic);
    buffer.writeln();
    buffer.writeln('English:');
    buffer.writeln(entry.english);
    buffer.writeln();
    buffer.writeln('Urdu:');
    buffer.writeln(entry.urdu);
    buffer.writeln();
    buffer.writeln('Narrator: ${entry.narrator}');
    buffer.writeln('Source: ${entry.source}');
    buffer.writeln('— Muslim Ultra');

    Clipboard.setData(ClipboardData(text: buffer.toString()));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          l10n?.hadithCopiedToast ?? 'Hadith copied to clipboard',
          style: const TextStyle(color: AppColors.midnightNavyDark, fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.gold,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('hadith_detail_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n?.hadithNumberPrefix(_hadithList[_currentIndex].number) ??
              'Hadith #${_hadithList[_currentIndex].number}',
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            key: const ValueKey('hadith_detail_copy_action'),
            icon: const Icon(Icons.copy_rounded, color: AppColors.gold),
            tooltip: l10n?.copyHadith ?? 'Copy Hadith',
            onPressed: () => _copyHadith(_hadithList[_currentIndex], context),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _hadithList.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          final hadith = _hadithList[index];
          return _buildHadithContent(hadith, isDark, l10n);
        },
      ),
      bottomNavigationBar: _hadithList.length > 1
          ? _buildBottomNavigationBar(isDark)
          : null,
    );
  }

  Widget _buildHadithContent(
    HadithEntry hadith,
    bool isDark,
    AppLocalizations? l10n,
  ) {
    final cardBg = isDark ? AppColors.midnightNavyCard : AppColors.sandCard;
    final borderColor = isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder;
    final primaryTextColor = isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Card: Title + Category Tags
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cardGradientDark : null,
              color: isDark ? null : AppColors.sandCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor.withAlpha((0.8 * 255).round()),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? (0.3 * 255).round() : (0.05 * 255).round()),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '#${hadith.number}',
                        style: const TextStyle(
                          color: AppColors.midnightNavyDark,
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        hadith.titleEn,
                        style: TextStyle(
                          color: primaryTextColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hadith.categories.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: hadith.categories.map((cat) {
                      final localizedCat = l10n != null ? l10n.getHadithCategoryName(cat) : cat;
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha((0.15 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.gold.withAlpha((0.35 * 255).round()),
                            width: 0.8,
                          ),
                        ),
                        child: Text(
                          localizedCat,
                          style: const TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Arabic Text Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor.withAlpha((0.7 * 255).round()),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(isDark ? (0.25 * 255).round() : (0.04 * 255).round()),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n?.arabicTextLabel ?? 'Arabic Text',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.menu_book_rounded,
                      size: 16,
                      color: AppColors.gold,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SelectableText(
                  hadith.arabic,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 22,
                    height: 2.1,
                    fontWeight: FontWeight.w600,
                    color: primaryTextColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // English Translation Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor.withAlpha((0.7 * 255).round()),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withAlpha((0.15 * 255).round()),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    l10n?.englishTextLabel ?? 'English Translation',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SelectableText(
                  hadith.english,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.6,
                    color: primaryTextColor.withAlpha((0.95 * 255).round()),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Urdu Translation Section
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: borderColor.withAlpha((0.7 * 255).round()),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withAlpha((0.15 * 255).round()),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        l10n?.urduTextLabel ?? 'Urdu Translation',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  hadith.urdu,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  style: GoogleFonts.amiri(
                    fontSize: 18,
                    height: 2.0,
                    color: primaryTextColor.withAlpha((0.95 * 255).round()),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Reference & Narrator Footer Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.midnightNavyCardElevated
                  : AppColors.sandCardElevated,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: borderColor.withAlpha((0.6 * 255).round()),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hadith.narrator.isNotEmpty) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 16,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${l10n?.narratorLabel ?? 'Narrator'}: ',
                        style: const TextStyle(
                          color: AppColors.gold,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          hadith.narrator,
                          style: TextStyle(
                            color: primaryTextColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.bookmark_outline_rounded,
                      size: 16,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${l10n?.sourceLabel ?? 'Source'}: ',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        hadith.source,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons: Copy & Share
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  key: const ValueKey('btn_hadith_copy'),
                  onPressed: () => _copyHadith(hadith, context),
                  icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.midnightNavyDark),
                  label: Text(
                    l10n?.copyHadith ?? 'Copy Hadith',
                    style: const TextStyle(
                      color: AppColors.midnightNavyDark,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.gold,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  key: const ValueKey('btn_hadith_share'),
                  onPressed: () => _copyHadith(hadith, context),
                  icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.gold),
                  label: Text(
                    l10n?.shareHadith ?? 'Share',
                    style: const TextStyle(
                      color: AppColors.gold,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.gold, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.midnightNavyDark : AppColors.sandCard,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              key: const ValueKey('btn_prev_hadith'),
              onPressed: _currentIndex > 0
                  ? () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.gold),
            ),
            Text(
              '${_currentIndex + 1} / ${_hadithList.length}',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            IconButton(
              key: const ValueKey('btn_next_hadith'),
              onPressed: _currentIndex < _hadithList.length - 1
                  ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.gold),
            ),
          ],
        ),
      ),
    );
  }
}
