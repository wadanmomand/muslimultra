import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/asma_name.dart';
import '../providers/asma_providers.dart';

class AsmaDetailScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  final List<AsmaName> names;

  const AsmaDetailScreen({
    super.key,
    required this.initialIndex,
    required this.names,
  });

  @override
  ConsumerState<AsmaDetailScreen> createState() => _AsmaDetailScreenState();
}

class _AsmaDetailScreenState extends ConsumerState<AsmaDetailScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex.clamp(0, widget.names.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
    ref.read(asmaRepositoryProvider).saveLastViewedIndex(index);
    ref.read(lastViewedAsmaIndexProvider.notifier).state = index;
  }

  void _goToPrevious() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToNext() {
    if (_currentIndex < widget.names.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _copyToClipboard(AsmaName name) {
    Clipboard.setData(ClipboardData(
      text: '${name.n}. ${name.ar} (${name.tr})\nEN: ${name.en}\nUR: ${name.ur}',
    ));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${name.tr} copied to clipboard'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.midnightNavyCardElevated,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.asmaUlHusna,
          style: const TextStyle(
            color: AppColors.gold,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: AppColors.gold),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_rounded, color: AppColors.gold, size: 20),
            tooltip: 'Copy Name',
            onPressed: () {
              if (_currentIndex < widget.names.length) {
                _copyToClipboard(widget.names[_currentIndex]);
              }
            },
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(l10n, isDark),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemCount: widget.names.length,
        itemBuilder: (context, index) {
          final item = widget.names[index];
          return _buildNameCard(context, item, l10n, isDark);
        },
      ),
    );
  }

  Widget _buildNameCard(
    BuildContext context,
    AsmaName item,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      child: Column(
        children: [
          // Indicator badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.gold.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
            ),
            child: Text(
              '${item.n} ${l10n.nameOf99}',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Main Calligraphy Display Hero
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFFAF7F0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: isDark ? 0.12 : 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                // Arabic Calligraphy Name
                Text(
                  item.ar,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Scheherazade',
                    fontSize: 54,
                    height: 1.4,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
                const SizedBox(height: 12),

                // Transliteration
                Text(
                  item.tr,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // English Meaning Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
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
                      child: const Icon(Icons.language_rounded, color: AppColors.gold, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.meaningEnglish,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.en,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Urdu Meaning Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
              ),
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
                      child: const Icon(Icons.translate_rounded, color: AppColors.gold, size: 16),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.meaningUrdu,
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  item.ur,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(AppLocalizations l10n, bool isDark) {
    final bool hasPrev = _currentIndex > 0;
    final bool hasNext = _currentIndex < widget.names.length - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFF0D1B2A),
        border: const Border(
          top: BorderSide(color: Color(0x33D4AF37), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton.icon(
              onPressed: hasPrev ? _goToPrevious : null,
              icon: const Icon(Icons.arrow_back_ios_rounded, size: 16),
              label: Text(l10n.previousName),
              style: ElevatedButton.styleFrom(
                backgroundColor: hasPrev ? AppColors.gold : Colors.grey.withValues(alpha: 0.2),
                foregroundColor: hasPrev ? AppColors.midnightNavy : Colors.grey,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                disabledForegroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
            Text(
              '${_currentIndex + 1} / ${widget.names.length}',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            ElevatedButton(
              onPressed: hasNext ? _goToNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: hasNext ? AppColors.gold : Colors.grey.withValues(alpha: 0.2),
                foregroundColor: hasNext ? AppColors.midnightNavy : Colors.grey,
                disabledBackgroundColor: Colors.grey.withValues(alpha: 0.1),
                disabledForegroundColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.nextName),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
