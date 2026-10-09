import 'ramadan_checklist.dart';

/// Status of a logged day's fast
enum FastStatus {
  kept('kept'),
  missed('missed'),
  qada('qada');

  final String value;
  const FastStatus(this.value);

  static FastStatus fromString(String val) {
    switch (val) {
      case 'missed':
        return FastStatus.missed;
      case 'qada':
        return FastStatus.qada;
      case 'kept':
      default:
        return FastStatus.kept;
    }
  }
}

/// A single day's fast record
class FastLogEntry {
  final String dateKey; // 'YYYY-MM-DD'
  final DateTime gregorianDate;
  final String hijriFormatted;
  final int hijriYear;
  final int hijriMonth;
  final int hijriDay;
  final FastStatus status;
  final String? notes;
  final RamadanChecklist? checklist;

  const FastLogEntry({
    required this.dateKey,
    required this.gregorianDate,
    required this.hijriFormatted,
    required this.hijriYear,
    required this.hijriMonth,
    required this.hijriDay,
    required this.status,
    this.notes,
    this.checklist,
  });

  bool get isKept => status == FastStatus.kept;
  bool get isMissed => status == FastStatus.missed;
  bool get isQada => status == FastStatus.qada;

  FastLogEntry copyWith({
    String? dateKey,
    DateTime? gregorianDate,
    String? hijriFormatted,
    int? hijriYear,
    int? hijriMonth,
    int? hijriDay,
    FastStatus? status,
    String? notes,
    RamadanChecklist? checklist,
  }) {
    return FastLogEntry(
      dateKey: dateKey ?? this.dateKey,
      gregorianDate: gregorianDate ?? this.gregorianDate,
      hijriFormatted: hijriFormatted ?? this.hijriFormatted,
      hijriYear: hijriYear ?? this.hijriYear,
      hijriMonth: hijriMonth ?? this.hijriMonth,
      hijriDay: hijriDay ?? this.hijriDay,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      checklist: checklist ?? this.checklist,
    );
  }

  Map<String, dynamic> toJson() => {
        'date_key': dateKey,
        'gregorian_date': gregorianDate.toIso8601String(),
        'hijri_formatted': hijriFormatted,
        'hijri_year': hijriYear,
        'hijri_month': hijriMonth,
        'hijri_day': hijriDay,
        'status': status.value,
        'notes': notes,
        'checklist': checklist?.toJson(),
      };

  factory FastLogEntry.fromJson(Map<String, dynamic> json) {
    return FastLogEntry(
      dateKey: json['date_key'] as String,
      gregorianDate: DateTime.parse(json['gregorian_date'] as String),
      hijriFormatted: json['hijri_formatted'] as String? ?? '',
      hijriYear: json['hijri_year'] as int? ?? 0,
      hijriMonth: json['hijri_month'] as int? ?? 0,
      hijriDay: json['hijri_day'] as int? ?? 0,
      status: FastStatus.fromString(json['status'] as String? ?? 'kept'),
      notes: json['notes'] as String?,
      checklist: json['checklist'] != null
          ? RamadanChecklist.fromJson(json['checklist'] as Map<String, dynamic>)
          : null,
    );
  }
}
