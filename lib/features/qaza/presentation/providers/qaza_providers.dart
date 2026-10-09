import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/prayer_tracking/presentation/providers/prayer_tracking_providers.dart';
import 'package:muslim_ultra/features/qaza/data/qaza_repository.dart';
import 'package:muslim_ultra/features/qaza/domain/models/qaza_debt.dart';

final qazaRepositoryProvider = Provider<QazaRepository>((ref) {
  final prayerRepo = ref.watch(prayerTrackingRepositoryProvider);
  return QazaRepository(prayerTrackingRepo: prayerRepo);
});

/// Future provider for current Qaza debt balance
final qazaDebtProvider = FutureProvider<QazaDebt>((ref) async {
  final repo = ref.watch(qazaRepositoryProvider);
  return repo.getDebt();
});

class QazaController {
  final QazaRepository _repo;
  final Ref _ref;

  QazaController(this._repo, this._ref);

  Future<void> repay(TrackedPrayer prayer) async {
    await _repo.repayQaza(prayer);
    _ref.invalidate(qazaDebtProvider);
    _ref.invalidate(weeklyPrayerStatsProvider);
    _ref.invalidate(prayerLogsForSelectedDateProvider);
  }

  Future<bool> undo(TrackedPrayer prayer) async {
    final success = await _repo.undoRepayQaza(prayer);
    if (success) {
      _ref.invalidate(qazaDebtProvider);
      _ref.invalidate(weeklyPrayerStatsProvider);
      _ref.invalidate(prayerLogsForSelectedDateProvider);
    }
    return success;
  }
}

final qazaControllerProvider = Provider<QazaController>((ref) {
  final repo = ref.watch(qazaRepositoryProvider);
  return QazaController(repo, ref);
});
