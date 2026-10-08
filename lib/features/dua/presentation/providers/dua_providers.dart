import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/dua/data/dua_repository.dart';
import 'package:muslim_ultra/features/dua/domain/models/dua_item.dart';

/// Provider for all loaded Hisn-ul-Muslim Duas
final allDuasProvider = FutureProvider<List<DuaItemModel>>((ref) async {
  return DuaRepository.loadAllDuas();
});

/// Provider for unique categories
final duaCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return DuaRepository.getCategories();
});

/// Currently selected category filter (null means 'All')
final selectedDuaCategoryProvider = StateProvider<String?>((ref) => null);

/// Active search query in the Dua screen
final duaSearchQueryProvider = StateProvider<String>((ref) => '');

/// Computed provider for filtered Duas based on search query and category
final filteredDuasProvider = Provider<AsyncValue<List<DuaItemModel>>>((ref) {
  final allDuasAsync = ref.watch(allDuasProvider);
  final selectedCategory = ref.watch(selectedDuaCategoryProvider);
  final query = ref.watch(duaSearchQueryProvider);

  return allDuasAsync.whenData((duas) {
    final trimmedQuery = query.trim().toLowerCase();
    final normalizedArabicQuery = _normalizeArabic(trimmedQuery);

    return duas.where((dua) {
      // Category filter
      if (selectedCategory != null && selectedCategory.isNotEmpty && selectedCategory != 'All') {
        if (dua.category.toLowerCase() != selectedCategory.toLowerCase()) {
          return false;
        }
      }

      // Query filter
      if (trimmedQuery.isEmpty) return true;

      final matchesEnglish = dua.translationEnglish.toLowerCase().contains(trimmedQuery);
      final matchesUrdu = dua.translationUrdu.contains(trimmedQuery);
      final matchesRef = dua.reference.toLowerCase().contains(trimmedQuery);
      final matchesCategory = dua.category.toLowerCase().contains(trimmedQuery);
      final matchesArabic = _normalizeArabic(dua.arabic).contains(normalizedArabicQuery) ||
          dua.arabic.contains(trimmedQuery);

      return matchesEnglish || matchesUrdu || matchesRef || matchesCategory || matchesArabic;
    }).toList();
  });
});

String _normalizeArabic(String text) {
  return text
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll('\u0623', '\u0627')
      .replaceAll('\u0625', '\u0627')
      .replaceAll('\u0622', '\u0627')
      .replaceAll('\u0649', '\u064A')
      .replaceAll('\u0629', '\u0647');
}
