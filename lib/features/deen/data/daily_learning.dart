import 'dart:convert';
import 'package:flutter/services.dart';

class DailyFact {
  final String titleEn;
  final String titleUr;
  final String titleAr;
  final String textEn;
  final String textUr;
  final String textAr;
  final String source;

  const DailyFact({
    required this.titleEn,
    required this.titleUr,
    required this.titleAr,
    required this.textEn,
    required this.textUr,
    required this.textAr,
    required this.source,
  });

  String localizedTitle(String languageCode) {
    if (languageCode == 'ar' && titleAr.isNotEmpty) return titleAr;
    if (languageCode == 'ur' && titleUr.isNotEmpty) return titleUr;
    return titleEn;
  }

  String localizedText(String languageCode) {
    if (languageCode == 'ar' && textAr.isNotEmpty) return textAr;
    if (languageCode == 'ur' && textUr.isNotEmpty) return textUr;
    return textEn;
  }

  factory DailyFact.fromJson(Map<String, dynamic> json) {
    return DailyFact(
      titleEn: (json['title_en'] as String?) ?? '',
      titleUr: (json['title_ur'] as String?) ?? '',
      titleAr: (json['title_ar'] as String?) ?? '',
      textEn: (json['text_en'] as String?) ?? '',
      textUr: (json['text_ur'] as String?) ?? '',
      textAr: (json['text_ar'] as String?) ?? '',
      source: (json['source'] as String?) ?? '',
    );
  }
}

class DailyLearningService {
  static const String assetPath = 'assets/learn/daily_facts.json';
  static List<DailyFact>? _cachedFacts;

  /// Loads all 30 facts from bundled asset
  static Future<List<DailyFact>> getAllFacts({AssetBundle? bundle}) async {
    if (_cachedFacts != null) return _cachedFacts!;

    final b = bundle ?? rootBundle;
    final jsonString = await b.loadString(assetPath);
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final list = map['facts'] as List<dynamic>;

    final parsed = list
        .map((item) => DailyFact.fromJson(item as Map<String, dynamic>))
        .toList();

    _cachedFacts = parsed;
    return parsed;
  }

  /// Pure deterministic selector for a given date (cycles through 30 facts)
  static DailyFact factFor(DateTime date, List<DailyFact> facts) {
    if (facts.isEmpty) {
      return const DailyFact(
        titleEn: 'Today\'s Learning',
        titleUr: 'آج کا سبق',
        titleAr: 'فائدة اليوم',
        textEn: 'Remember Allah in times of ease, and He will remember you in times of difficulty.',
        textUr: 'خوشحالی کے وقت اللہ کو یاد رکھو، وہ تنگی میں تمہیں یاد رکھے گا۔',
        textAr: 'تعرف إلى الله في الرخاء يعرفك في الشدة.',
        source: 'Jami` at-Tirmidhi 2516',
      );
    }
    final dateOnly = DateTime.utc(date.year, date.month, date.day);
    final baseDate = DateTime.utc(2026, 1, 1);
    final days = dateOnly.difference(baseDate).inDays;
    final index = (days % facts.length + facts.length) % facts.length;
    return facts[index];
  }

  /// Helper to get today's learning fact
  static Future<DailyFact> getTodayFact([DateTime? date, AssetBundle? bundle]) async {
    final facts = await getAllFacts(bundle: bundle);
    return factFor(date ?? DateTime.now(), facts);
  }

  /// Clears cache for tests
  static void clearCacheForTesting() {
    _cachedFacts = null;
  }
}
