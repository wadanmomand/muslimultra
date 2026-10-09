import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/asma_name.dart';

class AsmaMeta {
  final String source;
  final String note;
  final int count;

  const AsmaMeta({
    required this.source,
    required this.note,
    required this.count,
  });

  factory AsmaMeta.fromJson(Map<String, dynamic> json) {
    return AsmaMeta(
      source: json['source'] as String? ?? "Jami' at-Tirmidhi 3507",
      note: json['note'] as String? ?? '',
      count: json['count'] as int? ?? 99,
    );
  }
}

class AsmaRepository {
  static const String _assetPath = 'assets/asma/asma_ul_husna.json';
  static const String _prefLastViewedKey = 'asma_last_viewed_index_v1';

  static List<AsmaName>? _cachedNames;
  static AsmaMeta? _cachedMeta;

  /// Load 99 names from local asset with in-memory caching
  Future<List<AsmaName>> loadNames() async {
    if (_cachedNames != null && _cachedNames!.isNotEmpty) {
      return _cachedNames!;
    }

    try {
      final jsonString = await rootBundle.loadString(_assetPath);
      final decoded = json.decode(jsonString) as Map<String, dynamic>;

      if (decoded.containsKey('meta')) {
        _cachedMeta = AsmaMeta.fromJson(decoded['meta'] as Map<String, dynamic>);
      }

      final rawList = decoded['names'] as List<dynamic>? ?? [];
      final names = rawList
          .map((item) => AsmaName.fromJson(item as Map<String, dynamic>))
          .toList();

      _cachedNames = List.unmodifiable(names);
      return _cachedNames!;
    } catch (e) {
      return _cachedNames ?? [];
    }
  }

  /// Get bundle metadata
  Future<AsmaMeta> getMetadata() async {
    if (_cachedMeta != null) return _cachedMeta!;
    await loadNames();
    return _cachedMeta ?? const AsmaMeta(
      source: "Asma ul Husna — Jami' at-Tirmidhi 3507",
      note: "Scholars differ on the strength of this specific list's narration; the Names themselves are established from the Quran and Sunnah.",
      count: 99,
    );
  }

  /// Search across Arabic, Transliteration, English, and Urdu
  List<AsmaName> searchNames(List<AsmaName> allNames, String query) {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) return allNames;

    return allNames.where((name) {
      final matchTr = name.tr.toLowerCase().contains(cleanQuery);
      final matchEn = name.en.toLowerCase().contains(cleanQuery);
      final matchUr = name.ur.toLowerCase().contains(cleanQuery);
      final matchAr = name.ar.contains(query.trim());
      final matchNumber = name.n.toString() == cleanQuery;

      return matchTr || matchEn || matchUr || matchAr || matchNumber;
    }).toList();
  }

  /// Save last viewed name index (0-indexed)
  Future<void> saveLastViewedIndex(int index) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefLastViewedKey, index);
    } catch (_) {}
  }

  /// Get last viewed name index
  Future<int> getLastViewedIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_prefLastViewedKey) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  /// Testing helper
  static void setCacheForTesting(List<AsmaName> names, {AsmaMeta? meta}) {
    _cachedNames = List.unmodifiable(names);
    if (meta != null) _cachedMeta = meta;
  }

  /// Clear memory cache
  static void clearCacheForTesting() {
    _cachedNames = null;
    _cachedMeta = null;
  }
}
