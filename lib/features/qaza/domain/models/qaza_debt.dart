import 'package:flutter/foundation.dart';
import 'package:muslim_ultra/features/prayer_tracking/domain/models/prayer_log_entry.dart';

@immutable
class QazaDebt {
  final int fajr;
  final int dhuhr;
  final int asr;
  final int maghrib;
  final int isha;
  final int total;
  final int repaidThisWeek;

  const QazaDebt({
    required this.fajr,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
    required this.total,
    this.repaidThisWeek = 0,
  });

  int countFor(TrackedPrayer prayer) {
    switch (prayer) {
      case TrackedPrayer.fajr:
        return fajr;
      case TrackedPrayer.dhuhr:
        return dhuhr;
      case TrackedPrayer.asr:
        return asr;
      case TrackedPrayer.maghrib:
        return maghrib;
      case TrackedPrayer.isha:
        return isha;
    }
  }

  bool get hasDebt => total > 0;

  Map<String, int> toMap() => {
        'fajr': fajr,
        'dhuhr': dhuhr,
        'asr': asr,
        'maghrib': maghrib,
        'isha': isha,
        'total': total,
        'repaidThisWeek': repaidThisWeek,
      };
}
