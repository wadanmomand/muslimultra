import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/hadith/data/hadith_repository.dart';
import 'package:muslim_ultra/features/hadith/domain/models/hadith_entry.dart';

/// Provider for HadithRepository instance
final hadithRepositoryProvider = Provider<HadithRepository>((ref) {
  return HadithRepository();
});

/// Loads all 42 authentic Hadith entries
final hadithListProvider = FutureProvider<List<HadithEntry>>((ref) async {
  return HadithRepository.getAll();
});

/// Loads all unique categories from the dataset
final hadithCategoriesProvider = FutureProvider<List<String>>((ref) async {
  return HadithRepository.getCategories();
});

/// State provider for hadith search query in the search bar
final hadithSearchQueryProvider = StateProvider<String>((ref) => '');

/// State provider for the currently selected category filter (null means "All")
final hadithCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Filtered Hadith provider that applies both search query and category filtering
final filteredHadithProvider = FutureProvider<List<HadithEntry>>((ref) async {
  final query = ref.watch(hadithSearchQueryProvider);
  final category = ref.watch(hadithCategoryFilterProvider);

  return HadithRepository.search(query, category: category);
});

/// Provider to get a single Hadith by its number (1–42)
final hadithByNumberProvider = FutureProvider.family<HadithEntry?, int>((ref, number) async {
  return HadithRepository.byNumber(number);
});
