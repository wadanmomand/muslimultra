import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/theme/app_colors.dart';
import 'package:muslim_ultra/features/hadith/presentation/providers/hadith_providers.dart';
import 'package:muslim_ultra/features/hadith/presentation/screens/hadith_detail_screen.dart';
import 'package:muslim_ultra/features/hadith/presentation/widgets/hadith_card.dart';

class HadithLibraryScreen extends ConsumerStatefulWidget {
  const HadithLibraryScreen({super.key});

  @override
  ConsumerState<HadithLibraryScreen> createState() => _HadithLibraryScreenState();
}

class _HadithLibraryScreenState extends ConsumerState<HadithLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final bgColor = isDark ? AppColors.midnightNavyDark : AppColors.sandBackground;

    final categoriesAsync = ref.watch(hadithCategoriesProvider);
    final selectedCategory = ref.watch(hadithCategoryFilterProvider);
    final hadithListAsync = ref.watch(filteredHadithProvider);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.midnightNavyDark : AppColors.sandBackground,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          key: const ValueKey('hadith_library_back_button'),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.gold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          children: [
            Text(
              l10n?.hadithLibraryTitle ?? 'Hadith Library',
              style: const TextStyle(
                color: AppColors.gold,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              l10n?.hadithLibrarySubtitle ?? '40 Hadith of Imam an-Nawawi',
              style: TextStyle(
                color: isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(isDark ? (0.2 * 255).round() : (0.04 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                key: const ValueKey('hadith_search_field'),
                controller: _searchController,
                onChanged: (value) {
                  ref.read(hadithSearchQueryProvider.notifier).state = value;
                },
                style: TextStyle(
                  color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: l10n?.searchHadithHint ?? 'Search Hadith by title, narrator, text...',
                  hintStyle: TextStyle(
                    color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.gold, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 18, color: AppColors.gold),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(hadithSearchQueryProvider.notifier).state = '';
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                ),
              ),
            ),
          ),

          // Horizontal Category Chips
          categoriesAsync.when(
            data: (categories) {
              final allCategories = [null, ...categories];
              return Container(
                height: 44,
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: allCategories.length,
                  itemBuilder: (context, index) {
                    final cat = allCategories[index];
                    final isSelected = (selectedCategory == null && cat == null) ||
                        (selectedCategory != null &&
                            cat != null &&
                            selectedCategory.toLowerCase() == cat.toLowerCase());

                    final label = cat == null
                        ? (l10n?.categoryAll ?? 'All')
                        : (l10n != null ? l10n.getHadithCategoryName(cat) : cat);

                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        key: ValueKey('category_chip_${cat ?? "all"}'),
                        selected: isSelected,
                        showCheckmark: false,
                        label: Text(
                          label,
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.midnightNavyDark
                                : (isDark ? AppColors.darkTextSecondary : AppColors.sandTextSecondary),
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                        backgroundColor: isDark ? AppColors.midnightNavyCard : AppColors.sandCard,
                        selectedColor: AppColors.gold,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.gold
                                : (isDark ? AppColors.midnightNavyBorder : AppColors.sandBorder),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        onSelected: (_) {
                          ref.read(hadithCategoryFilterProvider.notifier).state = cat;
                        },
                      ),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox(height: 44),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 4),

          // Hadith List / Results
          Expanded(
            child: hadithListAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.gold),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline_rounded, size: 48, color: AppColors.gold),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.couldNotLoadHadith ?? 'Could not load hadith library',
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(hadithListProvider);
                          ref.invalidate(filteredHadithProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.midnightNavyDark,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text(
                          'Retry',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              data: (hadiths) {
                if (hadiths.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: AppColors.gold.withAlpha((0.5 * 255).round()),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            l10n?.noHadithFound ?? 'No hadith found',
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextPrimary : AppColors.sandTextPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            l10n?.noHadithFoundDesc ??
                                'Try adjusting your search terms or category filter.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isDark ? AppColors.darkTextMuted : AppColors.sandTextSecondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(top: 4, bottom: 24),
                  itemCount: hadiths.length,
                  itemBuilder: (context, index) {
                    final hadith = hadiths[index];
                    return HadithCard(
                      key: ValueKey('hadith_card_${hadith.number}'),
                      hadith: hadith,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => HadithDetailScreen(
                              hadith: hadith,
                              allHadiths: hadiths,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
