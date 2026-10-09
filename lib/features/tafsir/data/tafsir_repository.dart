import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:muslim_ultra/features/tafsir/domain/models/tafsir_entry.dart';

/// Exception thrown when the Tafsir bundle fails to load or is corrupt.
class TafsirLoadException implements Exception {
  final String message;
  final Object? cause;

  const TafsirLoadException(this.message, [this.cause]);

  @override
  String toString() => 'TafsirLoadException: $message${cause != null ? " ($cause)" : ""}';
}

/// Offline Repository for Classical Tafsir al-Jalalayn
class TafsirRepository {
  static const String _assetPath = 'assets/tafsir/tafsir.json';

  static Map<String, TafsirEntry>? _cachedEntries;

  /// Loads all tafsir entries from the bundled JSON asset.
  Future<Map<String, TafsirEntry>> loadAll({AssetBundle? bundle}) async {
    if (_cachedEntries != null) {
      return _cachedEntries!;
    }

    try {
      final jsonString = await (bundle ?? rootBundle).loadString(_assetPath);
      final decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic> || !decoded.containsKey('tafsir')) {
        throw const TafsirLoadException('Invalid bundle structure: root "tafsir" array missing');
      }

      final rawList = decoded['tafsir'];
      if (rawList is! List) {
        throw const TafsirLoadException('Invalid bundle structure: "tafsir" is not a list');
      }

      final map = <String, TafsirEntry>{};
      for (final item in rawList) {
        if (item is! Map<String, dynamic>) {
          throw const TafsirLoadException('Invalid item entry in tafsir array');
        }
        final entry = TafsirEntry.fromJson(item);
        map['${entry.surah}:${entry.ayah}'] = entry;
      }

      _cachedEntries = map;
      return map;
    } on TafsirLoadException {
      rethrow;
    } catch (e) {
      throw TafsirLoadException('Failed to load tafsir bundle from $_assetPath', e);
    }
  }

  /// Returns TafsirEntry for specific surah and ayah, or null if not covered.
  Future<TafsirEntry?> getTafsir(int surah, int ayah, {AssetBundle? bundle}) async {
    final entries = await loadAll(bundle: bundle);
    return entries['$surah:$ayah'];
  }

  /// Whether tafsir exists for specific surah and ayah.
  Future<bool> hasTafsir(int surah, int ayah, {AssetBundle? bundle}) async {
    final entries = await loadAll(bundle: bundle);
    return entries.containsKey('$surah:$ayah');
  }

  /// Synchronous check if already cached.
  bool hasTafsirSync(int surah, int ayah) {
    if (_cachedEntries == null) return false;
    return _cachedEntries!.containsKey('$surah:$ayah');
  }

  /// Synchronous retrieval if already cached.
  TafsirEntry? getTafsirSync(int surah, int ayah) {
    if (_cachedEntries == null) return null;
    return _cachedEntries!['$surah:$ayah'];
  }

  /// Clears in-memory cache (for testing)
  static void clearCacheForTesting() {
    _cachedEntries = null;
  }
}
