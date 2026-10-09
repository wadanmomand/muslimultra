import 'package:flutter/foundation.dart';

@immutable
class HajjStep {
  final int step;
  final String phaseEn;
  final String phaseUr;
  final String titleEn;
  final String titleUr;
  final String titleAr;
  final String descEn;
  final String descUr;
  final String descAr;
  final String? duaAr;
  final String? duaEn;
  final String? duaUr;
  final String? source;

  const HajjStep({
    required this.step,
    required this.phaseEn,
    required this.phaseUr,
    required this.titleEn,
    required this.titleUr,
    required this.titleAr,
    required this.descEn,
    required this.descUr,
    required this.descAr,
    this.duaAr,
    this.duaEn,
    this.duaUr,
    this.source,
  });

  bool get hasDua => duaAr != null && duaAr!.trim().isNotEmpty;

  /// Localized phase name
  String localizedPhase(String languageCode) {
    if (languageCode == 'ur' && phaseUr.isNotEmpty) return phaseUr;
    if (languageCode == 'ar') {
      if (phaseEn.toLowerCase() == 'umrah') return 'العمرة';
      if (phaseEn.toLowerCase() == 'hajj') return 'الحج';
      if (phaseEn.toLowerCase() == 'checklist') return 'قائمة التجهيز';
    }
    return phaseEn;
  }

  /// Localized title
  String localizedTitle(String languageCode) {
    if (languageCode == 'ar' && titleAr.isNotEmpty) return titleAr;
    if (languageCode == 'ur' && titleUr.isNotEmpty) return titleUr;
    return titleEn;
  }

  /// Localized description
  String localizedDesc(String languageCode) {
    if (languageCode == 'ar' && descAr.isNotEmpty) return descAr;
    if (languageCode == 'ur' && descUr.isNotEmpty) return descUr;
    return descEn;
  }

  /// Localized dua translation
  String? localizedDuaTranslation(String languageCode) {
    if (languageCode == 'ur' && duaUr != null && duaUr!.isNotEmpty) return duaUr;
    if (languageCode == 'ar') return null; // Arabic reader already has duaAr
    return duaEn;
  }

  factory HajjStep.fromJson(Map<String, dynamic> json) {
    return HajjStep(
      step: (json['step'] as num?)?.toInt() ?? 0,
      phaseEn: (json['phase_en'] as String?) ?? '',
      phaseUr: (json['phase_ur'] as String?) ?? '',
      titleEn: (json['title_en'] as String?) ?? '',
      titleUr: (json['title_ur'] as String?) ?? '',
      titleAr: (json['title_ar'] as String?) ?? '',
      descEn: (json['desc_en'] as String?) ?? '',
      descUr: (json['desc_ur'] as String?) ?? '',
      descAr: (json['desc_ar'] as String?) ?? '',
      duaAr: json['dua_ar'] as String?,
      duaEn: json['dua_en'] as String?,
      duaUr: json['dua_ur'] as String?,
      source: json['source'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'step': step,
      'phase_en': phaseEn,
      'phase_ur': phaseUr,
      'title_en': titleEn,
      'title_ur': titleUr,
      'title_ar': titleAr,
      'desc_en': descEn,
      'desc_ur': descUr,
      'desc_ar': descAr,
      'dua_ar': duaAr,
      'dua_en': duaEn,
      'dua_ur': duaUr,
      'source': source,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HajjStep && runtimeType == other.runtimeType && step == other.step;

  @override
  int get hashCode => step.hashCode;
}
