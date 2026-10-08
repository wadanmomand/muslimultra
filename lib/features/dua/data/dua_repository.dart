import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:muslim_ultra/features/dua/domain/models/dua_item.dart';

class DuaRepository {
  static const String assetPath = 'assets/duas/duas.json';
  static List<DuaItemModel>? _cachedDuas;
  static List<String>? _cachedCategories;

  /// Loads all authentic Hisn-ul-Muslim Duas from bundled JSON, caching in memory
  static Future<List<DuaItemModel>> loadAllDuas({bool forceReload = false}) async {
    if (!forceReload && _cachedDuas != null) {
      return _cachedDuas!;
    }

    try {
      final jsonString = await rootBundle.loadString(assetPath);
      final dynamic decoded = json.decode(jsonString);

      if (decoded is Map<String, dynamic> && decoded.containsKey('duas')) {
        final rawList = decoded['duas'] as List<dynamic>;
        final duas = <DuaItemModel>[];
        final categories = <String>{};

        for (var i = 0; i < rawList.length; i++) {
          final item = rawList[i] as Map<String, dynamic>;
          final dua = DuaItemModel.fromJson(item, i);
          duas.add(dua);
          if (dua.category.isNotEmpty) {
            categories.add(dua.category);
          }
        }

        _cachedDuas = List.unmodifiable(duas);
        _cachedCategories = List.unmodifiable(categories.toList());
        return _cachedDuas!;
      }
      return [];
    } catch (_) {
      return _cachedDuas ?? [];
    }
  }

  /// Returns all unique Dua categories
  static Future<List<String>> getCategories() async {
    if (_cachedCategories != null) {
      return _cachedCategories!;
    }
    await loadAllDuas();
    return _cachedCategories ?? [];
  }

  /// Filter Duas by category and optional query across Arabic, English, Urdu & Hadith Reference
  static Future<List<DuaItemModel>> filterDuas({
    String? category,
    String? query,
  }) async {
    final all = await loadAllDuas();
    final trimmedQuery = query?.trim().toLowerCase() ?? '';
    final normalizedArabicQuery = _normalizeArabic(trimmedQuery);

    return all.where((dua) {
      // Category filter
      if (category != null && category.isNotEmpty && category != 'All') {
        if (dua.category.toLowerCase() != category.toLowerCase()) {
          return false;
        }
      }

      // Query search across all fields
      if (trimmedQuery.isEmpty) return true;

      final matchesEnglish = dua.translationEnglish.toLowerCase().contains(trimmedQuery);
      final matchesUrdu = dua.translationUrdu.contains(trimmedQuery);
      final matchesRef = dua.reference.toLowerCase().contains(trimmedQuery);
      final matchesCategory = dua.category.toLowerCase().contains(trimmedQuery);
      final matchesArabic = _normalizeArabic(dua.arabic).contains(normalizedArabicQuery) ||
          dua.arabic.contains(trimmedQuery);

      return matchesEnglish || matchesUrdu || matchesRef || matchesCategory || matchesArabic;
    }).toList();
  }

  /// Remove Arabic diacritics / harakat for flexible search
  static String _normalizeArabic(String text) {
    return text
        .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '') // Harakat & Quranic marks
        .replaceAll('\u0623', '\u0627') // Alef with Hamza Above -> Alef
        .replaceAll('\u0625', '\u0627') // Alef with Hamza Below -> Alef
        .replaceAll('\u0622', '\u0627') // Alef with Madda -> Alef
        .replaceAll('\u0649', '\u064A') // Alef Maksura -> Ya
        .replaceAll('\u0629', '\u0647'); // Ta Marbuta -> Ha
  }

  /// Set memory cache for testing without loading rootBundle
  static void setCacheForTesting(List<DuaItemModel> duas) {
    _cachedDuas = List.unmodifiable(duas);
    final categories = <String>{};
    for (final dua in duas) {
      if (dua.category.isNotEmpty) categories.add(dua.category);
    }
    _cachedCategories = List.unmodifiable(categories.toList());
  }

  /// Reset memory cache for unit testing
  static void clearCacheForTesting() {
    _cachedDuas = null;
    _cachedCategories = null;
  }
}
