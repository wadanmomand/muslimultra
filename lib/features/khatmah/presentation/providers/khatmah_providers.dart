import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/khatmah/data/khatmah_repository.dart';

final khatmahRepositoryProvider = Provider<KhatmahRepository>((ref) {
  return KhatmahRepository();
});

final khatmahStateProvider = FutureProvider<KhatmahState>((ref) async {
  final repo = ref.watch(khatmahRepositoryProvider);
  return repo.getKhatmahState();
});

class KhatmahController {
  final Ref ref;
  final KhatmahRepository repo;

  KhatmahController(this.ref, this.repo);

  Future<KhatmahState> togglePara(int para) async {
    final state = await repo.togglePara(para);
    ref.invalidate(khatmahStateProvider);
    return state;
  }

  Future<void> reset() async {
    await repo.resetCurrentKhatmah();
    ref.invalidate(khatmahStateProvider);
  }
}

final khatmahControllerProvider = Provider<KhatmahController>((ref) {
  final repo = ref.watch(khatmahRepositoryProvider);
  return KhatmahController(ref, repo);
});
