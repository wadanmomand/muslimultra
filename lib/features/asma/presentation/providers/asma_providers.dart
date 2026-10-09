import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/asma_repository.dart';
import '../../domain/models/asma_name.dart';

final asmaRepositoryProvider = Provider<AsmaRepository>((ref) {
  return AsmaRepository();
});

final asmaNamesProvider = FutureProvider<List<AsmaName>>((ref) async {
  final repo = ref.watch(asmaRepositoryProvider);
  return repo.loadNames();
});

final asmaMetaProvider = FutureProvider<AsmaMeta>((ref) async {
  final repo = ref.watch(asmaRepositoryProvider);
  return repo.getMetadata();
});

final asmaSearchQueryProvider = StateProvider<String>((ref) => '');

final filteredAsmaNamesProvider = Provider<List<AsmaName>>((ref) {
  final namesAsync = ref.watch(asmaNamesProvider);
  final query = ref.watch(asmaSearchQueryProvider);
  final repo = ref.watch(asmaRepositoryProvider);

  final names = namesAsync.valueOrNull ?? [];
  return repo.searchNames(names, query);
});

final lastViewedAsmaIndexProvider = StateProvider<int>((ref) => 0);
