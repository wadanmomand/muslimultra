import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/tafsir/data/tafsir_repository.dart';
import 'package:muslim_ultra/features/tafsir/domain/models/tafsir_entry.dart';

final tafsirRepositoryProvider = Provider<TafsirRepository>((ref) {
  return TafsirRepository();
});

final allTafsirProvider = FutureProvider<Map<String, TafsirEntry>>((ref) async {
  final repo = ref.watch(tafsirRepositoryProvider);
  return repo.loadAll();
});

final allMuyassarTafsirProvider = FutureProvider<Map<String, TafsirEntry>>((ref) async {
  final repo = ref.watch(tafsirRepositoryProvider);
  return repo.loadMuyassar();
});

final selectedTafsirSourceProvider = StateProvider<TafsirSource>((ref) {
  return TafsirSource.jalalayn;
});
