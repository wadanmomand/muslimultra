import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/hifz/data/hifz_repository.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_item.dart';
import 'package:muslim_ultra/features/hifz/domain/models/hifz_stats.dart';

final hifzRepositoryProvider = Provider<HifzRepository>((ref) {
  return HifzRepository();
});

final hifzAllItemsProvider =
    FutureProvider.autoDispose<Map<String, HifzItem>>((ref) async {
  final repo = ref.watch(hifzRepositoryProvider);
  return repo.getAllItems();
});

final hifzSabqProvider =
    FutureProvider.autoDispose<List<HifzItem>>((ref) async {
  final repo = ref.watch(hifzRepositoryProvider);
  return repo.getSabqItems();
});

final hifzSabqiProvider =
    FutureProvider.autoDispose<List<HifzItem>>((ref) async {
  final repo = ref.watch(hifzRepositoryProvider);
  return repo.getSabqiItems();
});

final hifzManzilProvider =
    FutureProvider.autoDispose<List<HifzItem>>((ref) async {
  final repo = ref.watch(hifzRepositoryProvider);
  return repo.getManzilItems();
});

final hifzStatsProvider =
    FutureProvider.autoDispose<HifzStats>((ref) async {
  final repo = ref.watch(hifzRepositoryProvider);
  return repo.getStats();
});

final hifzSelectedSurahNumberProvider = StateProvider<int>((ref) => 1);
final hifzFromAyahProvider = StateProvider<int>((ref) => 1);
final hifzToAyahProvider = StateProvider<int>((ref) => 7);
