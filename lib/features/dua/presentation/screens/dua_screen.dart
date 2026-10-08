import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/core/theme/app_typography.dart';
import 'package:muslim_ultra/features/dua/domain/models/dua_item.dart';
import 'package:muslim_ultra/features/dua/presentation/providers/dua_providers.dart';

class DuaScreen extends ConsumerStatefulWidget {
  const DuaScreen({super.key});

  @override
  ConsumerState<DuaScreen> createState() => _DuaScreenState();
}

class _DuaScreenState extends ConsumerState<DuaScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _copyDua(BuildContext context, DuaItemModel dua, AppLocalizations l10n) {
    Clipboard.setData(ClipboardData(text: dua.toShareableString()));
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: AppColors.gold, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.duaCopied,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.midnightNavyCard,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.midnightNavyBorder),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showDuaDetail(BuildContext context, DuaItemModel dua, bool isDark, AppLocalizations l10n) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    children: [
                      // Header Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.gold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              dua.category,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                              ),
                            ),
                          ),
                          if (dua.reference.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.menu_book_rounded, size: 12, color: AppColors.gold),
                                  const SizedBox(width: 5),
                                  Text(
                                    dua.reference,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Large Arabic Text
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                          ),
                        ),
                        child: Text(
                          dua.arabic,
                          textAlign: TextAlign.right,
                          textDirection: TextDirection.rtl,
                          style: AppTypography.quranAyahText(
                            color: AppColors.gold,
                            fontSize: 24,
                          ).copyWith(height: 1.8),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // English Translation Section
                      if (dua.translationEnglish.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.english,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                            ),
                          ),
                          child: Text(
                            dua.translationEnglish,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                              height: 1.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Urdu Translation Section
                      if (dua.translationUrdu.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              width: 3,
                              height: 14,
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.urdu,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.gold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                            ),
                          ),
                          child: Text(
                            dua.translationUrdu,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                              height: 1.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Actions Row
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                _copyDua(context, dua, l10n);
                              },
                              icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.gold),
                              label: Text(
                                l10n.copyDua,
                                style: const TextStyle(
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.gold),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                _copyDua(context, dua, l10n);
                              },
                              icon: const Icon(Icons.share_rounded, size: 16, color: AppColors.midnightNavy),
                              label: Text(
                                l10n.shareDua,
                                style: const TextStyle(
                                  color: AppColors.midnightNavy,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final categoriesAsync = ref.watch(duaCategoriesProvider);
    final selectedCategory = ref.watch(selectedDuaCategoryProvider);
    final filteredDuasAsync = ref.watch(filteredDuasProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavy : AppColors.sandBackground,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.navDua,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
              ),
            ),
            Text(
              l10n.hisnUlMuslim,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.gold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                ),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  ref.read(duaSearchQueryProvider.notifier).state = value;
                },
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                ),
                decoration: InputDecoration(
                  hintText: l10n.searchDuasPlaceholder,
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.gold,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18),
                          color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                          onPressed: () {
                            _searchController.clear();
                            ref.read(duaSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
            ),
          ),

          // Horizontal Category Filter Chips
          categoriesAsync.when(
            data: (categories) {
              final allCategories = ['All', ...categories];
              return SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final category = allCategories[index];
                    final isAll = category == 'All';
                    final isSelected = isAll
                        ? (selectedCategory == null || selectedCategory == 'All')
                        : (selectedCategory == category);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () {
                          ref.read(selectedDuaCategoryProvider.notifier).state =
                              isAll ? null : category;
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.gold
                                : (isDark ? AppColors.midnightNavyCard : AppColors.sandCard),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.gold
                                  : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            isAll ? l10n.allDuas : category,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.midnightNavy
                                  : (isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 38),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // Duas List
          Expanded(
            child: filteredDuasAsync.when(
              data: (duas) {
                if (duas.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 48,
                            color: AppColors.gold.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.noDuasFound,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n.noDuasFoundDesc,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () {
                              _searchController.clear();
                              ref.read(duaSearchQueryProvider.notifier).state = '';
                              ref.read(selectedDuaCategoryProvider.notifier).state = null;
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.gold),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              l10n.allDuas,
                              style: const TextStyle(color: AppColors.gold, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  itemCount: duas.length,
                  itemBuilder: (context, index) {
                    final dua = duas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => _showDuaDetail(context, dua, isDark, l10n),
                        borderRadius: BorderRadius.circular(18),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Category and Reference Pills Row
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Wrap(
                                      spacing: 6,
                                      runSpacing: 6,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: AppColors.gold.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            dua.category,
                                            style: const TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.gold,
                                            ),
                                          ),
                                        ),
                                        if (dua.reference.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.bookmark_border_rounded, size: 10, color: AppColors.gold),
                                                const SizedBox(width: 4),
                                                Text(
                                                  dua.reference,
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.copy_rounded, size: 16, color: AppColors.gold),
                                    tooltip: l10n.copyDua,
                                    visualDensity: VisualDensity.compact,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () => _copyDua(context, dua, l10n),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Full Arabic Text (never truncated)
                              Text(
                                dua.arabic,
                                textAlign: TextAlign.right,
                                textDirection: TextDirection.rtl,
                                style: AppTypography.quranAyahText(
                                  color: AppColors.gold,
                                  fontSize: 18,
                                ).copyWith(height: 1.7),
                              ),
                              const SizedBox(height: 10),

                              // English Translation
                              if (dua.translationEnglish.isNotEmpty) ...[
                                Text(
                                  dua.translationEnglish,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                                    height: 1.45,
                                  ),
                                ),
                                const SizedBox(height: 6),
                              ],

                              // Urdu Translation
                              if (dua.translationUrdu.isNotEmpty) ...[
                                Text(
                                  dua.translationUrdu,
                                  textAlign: TextAlign.right,
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (err, _) => Center(
                child: Text(
                  err.toString(),
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
