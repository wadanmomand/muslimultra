import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:muslim_ultra/features/hadith/domain/models/hadith_entry.dart';

/// Typed exception thrown when loading or parsing the authentic Hadith dataset fails.
class HadithLoadException implements Exception {
  final String message;
  final dynamic cause;

  const HadithLoadException(this.message, [this.cause]);

  @override
  String toString() => 'HadithLoadException: $message${cause != null ? ' (Cause: $cause)' : ''}';
}

/// Repository responsible for loading and querying Imam an-Nawawi's 40 Hadith collection.
class HadithRepository {
  static const String assetPath = 'assets/hadith/hadith.json';
  static List<HadithEntry>? _cachedHadith;
  static List<String>? _cachedCategories;

  /// Clear in-memory cache for unit testing
  static void clearCacheForTesting() {
    _cachedHadith = null;
    _cachedCategories = null;
  }

  /// Loads all 42 authentic Hadith from the bundled JSON asset.
  /// Caches the parsed list in memory. Throws [HadithLoadException] on any error.
  static Future<List<HadithEntry>> getAll({
    bool forceReload = false,
    AssetBundle? customBundle,
  }) async {
    if (!forceReload && _cachedHadith != null) {
      return _cachedHadith!;
    }

    try {
      final bundle = customBundle ?? rootBundle;
      final jsonString = await bundle.loadString(assetPath);
      return parseHadithJson(jsonString);
    } catch (e) {
      if (e is HadithLoadException) rethrow;
      throw HadithLoadException('Failed to load authentic hadith asset from $assetPath', e);
    }
  }

  /// Parses JSON string into [HadithEntry] list.
  /// Throws [HadithLoadException] if the structure is invalid or missing required entries.
  static List<HadithEntry> parseHadithJson(String jsonString) {
    try {
      final dynamic decoded = json.decode(jsonString);
      if (decoded is! Map<String, dynamic> || !decoded.containsKey('hadith')) {
        throw const HadithLoadException('Invalid Hadith dataset format: root "hadith" array missing.');
      }

      final rawList = decoded['hadith'] as List<dynamic>;
      if (rawList.isEmpty) {
        throw const HadithLoadException('Hadith dataset contains 0 entries.');
      }

      final entries = <HadithEntry>[];
      final categoriesSet = <String>{};

      for (var i = 0; i < rawList.length; i++) {
        final item = rawList[i];
        if (item is! Map<String, dynamic>) {
          throw HadithLoadException('Hadith entry at index $i is not a valid JSON object.');
        }

        final entry = HadithEntry.fromJson(item);
        if (entry.arabic.isEmpty || entry.english.isEmpty || entry.urdu.isEmpty) {
          throw HadithLoadException(
            'Hadith #${entry.number} is missing required language text (Arabic, English, or Urdu).',
          );
        }

        entries.add(entry);
        for (final cat in entry.categories) {
          if (cat.isNotEmpty) {
            categoriesSet.add(cat);
          }
        }
      }

      _cachedHadith = List.unmodifiable(entries);
      _cachedCategories = List.unmodifiable(categoriesSet.toList());
      return _cachedHadith!;
    } catch (e) {
      if (e is HadithLoadException) rethrow;
      throw HadithLoadException('Error parsing hadith JSON content', e);
    }
  }

  /// Returns all unique categories present in the collection.
  static Future<List<String>> getCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }
    await getAll();
    return _cachedCategories ?? const [];
  }

  /// Finds a specific hadith by its sequential number (1–42).
  static Future<HadithEntry?> byNumber(int number) async {
    final all = await getAll();
    for (final h in all) {
      if (h.number == number) return h;
    }
    return null;
  }

  /// Returns hadiths belonging to a specific category.
  static Future<List<HadithEntry>> byCategory(String category) async {
    final all = await getAll();
    final target = category.trim().toLowerCase();
    if (target.isEmpty) return all;
    return all.where((h) => h.categories.any((c) => c.toLowerCase() == target)).toList();
  }

  /// Searches hadiths across Title, Narrator, Source, Arabic (with/without tashkeel), English, and Urdu.
  static Future<List<HadithEntry>> search(String query, {String? category}) async {
    final all = await getAll();
    var filtered = all;

    if (category != null && category.trim().isNotEmpty) {
      final targetCat = category.trim().toLowerCase();
      filtered = filtered.where((h) => h.categories.any((c) => c.toLowerCase() == targetCat)).toList();
    }

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return filtered;
    }

    final normalizedArabicQuery = _normalizeArabic(trimmed);

    return filtered.where((h) {
      // 1. Number match (e.g. "1" or "#1")
      if (h.number.toString() == trimmed || '#${h.number}' == trimmed) {
        return true;
      }

      // 2. Title match
      if (h.titleEn.toLowerCase().contains(trimmed)) {
        return true;
      }

      // 3. Narrator & Source match
      if (h.narrator.toLowerCase().contains(trimmed) || h.source.toLowerCase().contains(trimmed)) {
        return true;
      }

      // 4. English text match
      if (h.english.toLowerCase().contains(trimmed)) {
        return true;
      }

      // 5. Urdu text match
      if (h.urdu.toLowerCase().contains(trimmed)) {
        return true;
      }

      // 6. Arabic direct match
      if (h.arabic.contains(trimmed)) {
        return true;
      }

      // 7. Arabic normalized (tashkeel-stripped) match
      final normalizedArabicText = _normalizeArabic(h.arabic);
      if (normalizedArabicText.contains(normalizedArabicQuery)) {
        return true;
      }

      return false;
    }).toList();
  }

  /// Strips Arabic diacritics/tashkeel and normalizes letter forms for search
  static String _normalizeArabic(String input) {
    if (input.isEmpty) return '';

    // Remove Arabic diacritics/tashkeel (Fathah, Dammah, Kasrah, Sukun, Shaddah, Tanween, etc.)
    final diacritics = RegExp(r'[\u064B-\u0652\u0670\u0640\u06D6-\u06ED]');
    var result = input.replaceAll(diacritics, '');

    // Normalize different forms of Alef (أ, إ, آ, ٱ -> ا)
    result = result.replaceAll(RegExp(r'[أإآٱ]'), 'ا');

    // Normalize Taa Marbuta to Haa (ة -> ه)
    result = result.replaceAll('ة', 'ه');

    // Normalize Alef Maqsura to Yaa (ى -> ي)
    result = result.replaceAll('ى', 'ي');

    return result.toLowerCase().trim();
  }
}
