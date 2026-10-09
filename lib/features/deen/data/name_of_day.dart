import 'dart:convert';
import 'package:flutter/services.dart';

class AsmaOfDay {
  final int number;
  final String arabic;
  final String transliteration;
  final String englishMeaning;
  final String urduMeaning;

  const AsmaOfDay({
    required this.number,
    required this.arabic,
    required this.transliteration,
    required this.englishMeaning,
    required this.urduMeaning,
  });

  /// Localized meaning based on language code ('en', 'ar', 'ur')
  String localizedMeaning(String languageCode) {
    if (languageCode == 'ur') return urduMeaning;
    if (languageCode == 'ar') return arabic;
    return englishMeaning;
  }

  factory AsmaOfDay.fromJson(Map<String, dynamic> json) {
    return AsmaOfDay(
      number: (json['n'] as num?)?.toInt() ?? 1,
      arabic: (json['ar'] as String?) ?? '',
      transliteration: (json['tr'] as String?) ?? '',
      englishMeaning: (json['en'] as String?) ?? '',
      urduMeaning: (json['ur'] as String?) ?? '',
    );
  }
}

class NameOfDayService {
  static const String assetPath = 'assets/asma/asma_ul_husna.json';
  static List<AsmaOfDay>? _cachedNames;

  /// Loads all 99 names of Allah from existing bundle
  static Future<List<AsmaOfDay>> getAllNames({AssetBundle? bundle}) async {
    if (_cachedNames != null) return _cachedNames!;

    final b = bundle ?? rootBundle;
    final jsonString = await b.loadString(assetPath);
    final map = json.decode(jsonString) as Map<String, dynamic>;
    final list = map['names'] as List<dynamic>;

    final parsed = list
        .map((item) => AsmaOfDay.fromJson(item as Map<String, dynamic>))
        .toList();

    _cachedNames = parsed;
    return parsed;
  }

  /// Pure deterministic selector for a given date
  static AsmaOfDay nameFor(DateTime date, List<AsmaOfDay> names) {
    if (names.isEmpty) {
      return const AsmaOfDay(
        number: 1,
        arabic: 'الله',
        transliteration: 'Allah',
        englishMeaning: 'The One God',
        urduMeaning: 'معبودِ برحق، واحد خدا',
      );
    }
    final dateOnly = DateTime.utc(date.year, date.month, date.day);
    final baseDate = DateTime.utc(2026, 1, 1);
    final days = dateOnly.difference(baseDate).inDays;
    final index = (days % names.length + names.length) % names.length;
    return names[index];
  }

  /// Helper to get today's Name of Allah
  static Future<AsmaOfDay> getTodayName([DateTime? date, AssetBundle? bundle]) async {
    final names = await getAllNames(bundle: bundle);
    return nameFor(date ?? DateTime.now(), names);
  }

  /// Clears cache for testing
  static void clearCacheForTesting() {
    _cachedNames = null;
  }
}
