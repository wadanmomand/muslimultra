import 'package:flutter/foundation.dart';

/// Represents an authentic Hadith entry from Imam an-Nawawi's 40 Hadith collection.
@immutable
class HadithEntry {
  final int number;
  final String titleEn;
  final String narrator;
  final String source;
  final List<String> categories;
  final String arabic;
  final String english;
  final String urdu;

  const HadithEntry({
    required this.number,
    required this.titleEn,
    required this.narrator,
    required this.source,
    required this.categories,
    required this.arabic,
    required this.english,
    required this.urdu,
  });

  factory HadithEntry.fromJson(Map<String, dynamic> json) {
    final rawCats = json['categories'];
    final List<String> cats = rawCats is List
        ? rawCats.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : const [];

    return HadithEntry(
      number: (json['number'] as num?)?.toInt() ?? 0,
      titleEn: (json['title_en'] as String?)?.trim() ?? '',
      narrator: (json['narrator'] as String?)?.trim() ?? '',
      source: (json['source'] as String?)?.trim() ?? '',
      categories: List.unmodifiable(cats),
      arabic: (json['arabic'] as String?)?.trim() ?? '',
      english: (json['english'] as String?)?.trim() ?? '',
      urdu: (json['urdu'] as String?)?.trim() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'title_en': titleEn,
        'narrator': narrator,
        'source': source,
        'categories': categories,
        'arabic': arabic,
        'english': english,
        'urdu': urdu,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithEntry &&
          runtimeType == other.runtimeType &&
          number == other.number &&
          titleEn == other.titleEn &&
          narrator == other.narrator &&
          source == other.source &&
          listEquals(categories, other.categories) &&
          arabic == other.arabic &&
          english == other.english &&
          urdu == other.urdu;

  @override
  int get hashCode => Object.hash(
        number,
        titleEn,
        narrator,
        source,
        Object.hashAll(categories),
        arabic,
        english,
        urdu,
      );

  @override
  String toString() => 'HadithEntry(#$number: $titleEn, narrator: $narrator, source: $source)';
}
