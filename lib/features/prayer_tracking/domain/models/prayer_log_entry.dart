import 'package:flutter/foundation.dart';

/// Status of a logged prayer
enum PrayerLogStatus {
  prayed('prayed'),
  missed('missed'),
  qada('qada');

  final String value;
  const PrayerLogStatus(this.value);

  static PrayerLogStatus fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'prayed':
        return PrayerLogStatus.prayed;
      case 'missed':
        return PrayerLogStatus.missed;
      case 'qada':
        return PrayerLogStatus.qada;
      default:
        return PrayerLogStatus.prayed;
    }
  }
}

/// The 5 obligatory daily prayers tracked in Muslim Ultra
enum TrackedPrayer {
  fajr('fajr'),
  dhuhr('dhuhr'),
  asr('asr'),
  maghrib('maghrib'),
  isha('isha');

  final String keyName;
  const TrackedPrayer(this.keyName);

  static TrackedPrayer fromString(String val) {
    switch (val.toLowerCase().trim()) {
      case 'fajr':
        return TrackedPrayer.fajr;
      case 'dhuhr':
        return TrackedPrayer.dhuhr;
      case 'asr':
        return TrackedPrayer.asr;
      case 'maghrib':
        return TrackedPrayer.maghrib;
      case 'isha':
        return TrackedPrayer.isha;
      default:
        return TrackedPrayer.fajr;
    }
  }

  static const List<TrackedPrayer> all = [
    TrackedPrayer.fajr,
    TrackedPrayer.dhuhr,
    TrackedPrayer.asr,
    TrackedPrayer.maghrib,
    TrackedPrayer.isha,
  ];
}

/// Represents a single prayer log record for a given day and prayer
@immutable
class PrayerLogEntry {
  final String date; // Format: yyyy-MM-dd
  final String prayer; // fajr, dhuhr, asr, maghrib, isha
  final PrayerLogStatus status;
  final DateTime timestamp;

  const PrayerLogEntry({
    required this.date,
    required this.prayer,
    required this.status,
    required this.timestamp,
  });

  TrackedPrayer get trackedPrayer => TrackedPrayer.fromString(prayer);

  factory PrayerLogEntry.fromJson(Map<String, dynamic> json) {
    return PrayerLogEntry(
      date: (json['date'] as String?) ?? '',
      prayer: (json['prayer'] as String?) ?? 'fajr',
      status: PrayerLogStatus.fromString((json['status'] as String?) ?? 'prayed'),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'prayer': prayer,
        'status': status.value,
        'timestamp': timestamp.toIso8601String(),
      };

  PrayerLogEntry copyWith({
    String? date,
    String? prayer,
    PrayerLogStatus? status,
    DateTime? timestamp,
  }) {
    return PrayerLogEntry(
      date: date ?? this.date,
      prayer: prayer ?? this.prayer,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrayerLogEntry &&
          runtimeType == other.runtimeType &&
          date == other.date &&
          prayer == other.prayer &&
          status == other.status &&
          timestamp.isAtSameMomentAs(other.timestamp);

  @override
  int get hashCode => Object.hash(date, prayer, status, timestamp.millisecondsSinceEpoch);

  @override
  String toString() =>
      'PrayerLogEntry(date: $date, prayer: $prayer, status: ${status.value}, time: $timestamp)';
}
