import 'package:flutter/foundation.dart';

@immutable
class MoodItem {
  final String moodEn;
  final String moodUr;
  final String moodAr;
  final String emoji;
  final String duaAr;
  final String duaEn;
  final String duaUr;
  final String source;

  const MoodItem({
    required this.moodEn,
    required this.moodUr,
    required this.moodAr,
    required this.emoji,
    required this.duaAr,
    required this.duaEn,
    required this.duaUr,
    required this.source,
  });

  /// Localized name of the mood ('en', 'ar', 'ur')
  String localizedMood(String languageCode) {
    if (languageCode == 'ar' && moodAr.isNotEmpty) return moodAr;
    if (languageCode == 'ur' && moodUr.isNotEmpty) return moodUr;
    return moodEn;
  }

  /// Localized dua translation
  String localizedDua(String languageCode) {
    if (languageCode == 'ur' && duaUr.isNotEmpty) return duaUr;
    if (languageCode == 'ar') return duaAr;
    return duaEn;
  }

  factory MoodItem.fromJson(Map<String, dynamic> json) {
    return MoodItem(
      moodEn: (json['mood_en'] as String?) ?? '',
      moodUr: (json['mood_ur'] as String?) ?? '',
      moodAr: (json['mood_ar'] as String?) ?? '',
      emoji: (json['emoji'] as String?) ?? '🤲',
      duaAr: (json['dua_ar'] as String?) ?? '',
      duaEn: (json['dua_en'] as String?) ?? '',
      duaUr: (json['dua_ur'] as String?) ?? '',
      source: (json['source'] as String?) ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mood_en': moodEn,
      'mood_ur': moodUr,
      'mood_ar': moodAr,
      'emoji': emoji,
      'dua_ar': duaAr,
      'dua_en': duaEn,
      'dua_ur': duaUr,
      'source': source,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodItem &&
          runtimeType == other.runtimeType &&
          moodEn.toLowerCase() == other.moodEn.toLowerCase();

  @override
  int get hashCode => moodEn.toLowerCase().hashCode;
}
