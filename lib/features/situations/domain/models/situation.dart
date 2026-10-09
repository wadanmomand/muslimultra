import 'package:flutter/material.dart';

@immutable
class SituationAyatRef {
  final int surah;
  final int ayah;

  const SituationAyatRef({
    required this.surah,
    required this.ayah,
  });

  factory SituationAyatRef.fromJson(Map<String, dynamic> json) {
    return SituationAyatRef(
      surah: (json['surah'] as num).toInt(),
      ayah: (json['ayah'] as num).toInt(),
    );
  }

  Map<String, dynamic> toJson() => {
        'surah': surah,
        'ayah': ayah,
      };
}

@immutable
class SituationModel {
  final String id;
  final String titleEn;
  final String titleAr;
  final String titleUr;
  final String comfortEn;
  final String comfortAr;
  final String comfortUr;
  final String dhikrEn;
  final String dhikrAr;
  final String dhikrUr;
  final List<SituationAyatRef> ayat;

  const SituationModel({
    required this.id,
    required this.titleEn,
    required this.titleAr,
    required this.titleUr,
    required this.comfortEn,
    required this.comfortAr,
    required this.comfortUr,
    required this.dhikrEn,
    required this.dhikrAr,
    required this.dhikrUr,
    required this.ayat,
  });

  String getTitle(String languageCode) {
    if (languageCode == 'ar') return titleAr;
    if (languageCode == 'ur') return titleUr;
    return titleEn;
  }

  String getComfort(String languageCode) {
    if (languageCode == 'ar') return comfortAr;
    if (languageCode == 'ur') return comfortUr;
    return comfortEn;
  }

  String getDhikr(String languageCode) {
    if (languageCode == 'ar') return dhikrAr;
    if (languageCode == 'ur') return dhikrUr;
    return dhikrEn;
  }

  IconData get icon {
    switch (id) {
      case 'grief':
        return Icons.favorite_border_rounded;
      case 'anxiety':
        return Icons.spa_rounded;
      case 'debt':
        return Icons.account_balance_wallet_rounded;
      case 'illness':
        return Icons.healing_rounded;
      case 'travel':
        return Icons.flight_takeoff_rounded;
      case 'marriage':
        return Icons.people_outline_rounded;
      case 'parent':
        return Icons.child_care_rounded;
      case 'exam':
        return Icons.school_rounded;
      default:
        return Icons.auto_stories_rounded;
    }
  }

  factory SituationModel.fromJson(Map<String, dynamic> json) {
    final rawAyat = json['ayat'] as List<dynamic>? ?? [];
    return SituationModel(
      id: (json['id'] as String?) ?? '',
      titleEn: (json['title_en'] as String?) ?? '',
      titleAr: (json['title_ar'] as String?) ?? '',
      titleUr: (json['title_ur'] as String?) ?? '',
      comfortEn: (json['comfort_en'] as String?) ?? '',
      comfortAr: (json['comfort_ar'] as String?) ?? '',
      comfortUr: (json['comfort_ur'] as String?) ?? '',
      dhikrEn: (json['dhikr_en'] as String?) ?? '',
      dhikrAr: (json['dhikr_ar'] as String?) ?? '',
      dhikrUr: (json['dhikr_ur'] as String?) ?? '',
      ayat: rawAyat
          .map((item) => SituationAyatRef.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title_en': titleEn,
        'title_ar': titleAr,
        'title_ur': titleUr,
        'comfort_en': comfortEn,
        'comfort_ar': comfortAr,
        'comfort_ur': comfortUr,
        'dhikr_en': dhikrEn,
        'dhikr_ar': dhikrAr,
        'dhikr_ur': dhikrUr,
        'ayat': ayat.map((a) => a.toJson()).toList(),
      };
}
