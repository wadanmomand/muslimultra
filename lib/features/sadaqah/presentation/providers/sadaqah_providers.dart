import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/sadaqah/data/sadaqah_repository.dart';
import 'package:muslim_ultra/features/sadaqah/domain/models/sadaqah_entry.dart';

final sadaqahRepositoryProvider = Provider<SadaqahRepository>((ref) {
  return SadaqahRepository();
});

final sadaqahRevisionProvider = StateProvider<int>((ref) => 0);

final sadaqahEntriesProvider = FutureProvider<List<SadaqahEntry>>((ref) async {
  ref.watch(sadaqahRevisionProvider);
  final repo = ref.watch(sadaqahRepositoryProvider);
  return repo.getAllEntries();
});

final monthlySadaqahTotalProvider = FutureProvider<double>((ref) async {
  ref.watch(sadaqahRevisionProvider);
  final repo = ref.watch(sadaqahRepositoryProvider);
  return repo.monthlyTotal();
});

final allTimeSadaqahTotalProvider = FutureProvider<double>((ref) async {
  ref.watch(sadaqahRevisionProvider);
  final repo = ref.watch(sadaqahRepositoryProvider);
  return repo.totalAllTime();
});

class SadaqahController {
  final Ref ref;
  final SadaqahRepository repo;

  SadaqahController(this.ref, this.repo);

  Future<void> logSadaqah(double amount, {String? note, DateTime? date}) async {
    await repo.logSadaqah(amount, note: note, date: date);
    ref.read(sadaqahRevisionProvider.notifier).state++;
  }

  Future<void> deleteEntry(String id) async {
    await repo.deleteEntry(id);
    ref.read(sadaqahRevisionProvider.notifier).state++;
  }
}

final sadaqahControllerProvider = Provider<SadaqahController>((ref) {
  final repo = ref.watch(sadaqahRepositoryProvider);
  return SadaqahController(ref, repo);
});
