import 'package:flutter/foundation.dart';

@immutable
class SadaqahEntry {
  final String id;
  final double amount;
  final String? note;
  final String date; // yyyy-MM-dd
  final DateTime timestamp;

  const SadaqahEntry({
    required this.id,
    required this.amount,
    this.note,
    required this.date,
    required this.timestamp,
  });

  factory SadaqahEntry.fromJson(Map<String, dynamic> json) {
    return SadaqahEntry(
      id: (json['id'] as String?) ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String?,
      date: (json['date'] as String?) ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'amount': amount,
        'note': note,
        'date': date,
        'timestamp': timestamp.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SadaqahEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
