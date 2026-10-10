import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/library/data/library_repository.dart';
import 'package:muslim_ultra/features/library/domain/models/book.dart';
import 'package:muslim_ultra/features/library/domain/models/book_progress.dart';

final libraryRepositoryProvider = Provider<LibraryRepository>((ref) {
  return LibraryRepository();
});

final booksCatalogProvider = FutureProvider.autoDispose<List<Book>>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getBooksCatalog();
});

final downloadedBooksProvider =
    FutureProvider.autoDispose<Set<String>>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  final books = await ref.watch(booksCatalogProvider.future);
  final downloaded = <String>{};

  for (final book in books) {
    if (await repo.isBookDownloaded(book.id)) {
      downloaded.add(book.id);
    }
  }
  return downloaded;
});

final libraryProgressMapProvider =
    FutureProvider.autoDispose<Map<String, BookProgress>>((ref) async {
  final repo = ref.watch(libraryRepositoryProvider);
  return repo.getAllProgress();
});

final bookDownloadProgressProvider =
    StateProvider.autoDispose.family<double?, String>((ref, bookId) {
  return null; // null means not currently downloading
});
