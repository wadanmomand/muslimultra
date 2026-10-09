import 'dart:math';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/data/prayer_tracking_repository.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';
import 'package:muslim_ultra/features/qaza/domain/models/qaza_debt.dart';

class QazaRepository {
  final PrayerTrackingRepository _prayerTrackingRepo;
  final DeenRepository _deenRepo;

  QazaRepository({
    PrayerTrackingRepository? prayerTrackingRepo,
    DeenRepository? deenRepo,
  })  : _prayerTrackingRepo = prayerTrackingRepo ?? PrayerTrackingRepository(),
        _deenRepo = deenRepo ?? DeenRepository();

  /// Calculates the current Qaza debt balance and weekly repayments from prayer logs
  Future<QazaDebt> getDebt([DateTime? asOfDate]) async {
    final entries = await _prayerTrackingRepo.getAllEntries();
    final now = asOfDate ?? DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));

    int getDebtFor(TrackedPrayer p) {
      final key = p.keyName.toLowerCase();
      final missed = entries
          .where((e) => e.prayer.toLowerCase() == key && e.status == PrayerLogStatus.missed)
          .length;
      final qada = entries
          .where((e) => e.prayer.toLowerCase() == key && e.status == PrayerLogStatus.qada)
          .length;
      return max(0, missed - qada);
    }

    final fajr = getDebtFor(TrackedPrayer.fajr);
    final dhuhr = getDebtFor(TrackedPrayer.dhuhr);
    final asr = getDebtFor(TrackedPrayer.asr);
    final maghrib = getDebtFor(TrackedPrayer.maghrib);
    final isha = getDebtFor(TrackedPrayer.isha);
    final total = fajr + dhuhr + asr + maghrib + isha;

    // Count Qada prayers repaid within the last 7 days
    final repaidThisWeek = entries.where((e) {
      if (e.status != PrayerLogStatus.qada) return false;
      return e.timestamp.isAfter(sevenDaysAgo) && e.timestamp.isBefore(now.add(const Duration(days: 1)));
    }).length;

    return QazaDebt(
      fajr: fajr,
      dhuhr: dhuhr,
      asr: asr,
      maghrib: maghrib,
      isha: isha,
      total: total,
      repaidThisWeek: repaidThisWeek,
    );
  }

  /// Logs one Qada prayer repaid today (writes through v1.5 prayer tracking storage)
  Future<void> repayQaza(TrackedPrayer prayer, [DateTime? date]) async {
    final targetDate = date ?? DateTime.now();
    await _prayerTrackingRepo.logQadaPrayer(prayer.keyName, targetDate);

    // Award XP
    try {
      final dateStr = PrayerTrackingRepository.formatDate(targetDate);
      await _deenRepo.awardXp(5, 'qaza_${prayer.keyName}_${dateStr}_${targetDate.millisecondsSinceEpoch}');
    } catch (_) {}
  }

  /// Reverts the most recent Qada prayer logged for that prayer
  Future<bool> undoRepayQaza(TrackedPrayer prayer) async {
    return _prayerTrackingRepo.undoLatestQada(prayer.keyName);
  }
}
