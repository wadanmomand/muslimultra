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

/// Offline Repository for Classical Tafsir (al-Jalalayn and al-Muyassar)
class TafsirRepository {
  static const String _assetPath = 'assets/tafsir/tafsir.json';
  static const String _muyassarAssetPath = 'assets/tafsir/tafsir_muyassar.json';

  static Map<String, TafsirEntry>? _cachedEntries;
  static Map<String, TafsirEntry>? _cachedMuyassarEntries;

  /// Loads all Jalalayn / Bayan-ul-Quran tafsir entries from the bundled JSON asset.
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

  /// Loads all Tafsir al-Muyassar entries from the bundled JSON asset.
  Future<Map<String, TafsirEntry>> loadMuyassar({AssetBundle? bundle}) async {
    if (_cachedMuyassarEntries != null) {
      return _cachedMuyassarEntries!;
    }

    try {
      final jsonString = await (bundle ?? rootBundle).loadString(_muyassarAssetPath);
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
          throw const TafsirLoadException('Invalid item entry in muyassar tafsir array');
        }
        final entry = TafsirEntry.fromMuyassarJson(item);
        map['${entry.surah}:${entry.ayah}'] = entry;
      }

      _cachedMuyassarEntries = map;
      return map;
    } on TafsirLoadException {
      rethrow;
    } catch (e) {
      throw TafsirLoadException('Failed to load muyassar tafsir bundle from $_muyassarAssetPath', e);
    }
  }

  /// Returns TafsirEntry for specific surah and ayah and chosen source, or null if not covered.
  Future<TafsirEntry?> getTafsir(
    int surah,
    int ayah, {
    TafsirSource source = TafsirSource.jalalayn,
    AssetBundle? bundle,
  }) async {
    final entries = source == TafsirSource.muyassar
        ? await loadMuyassar(bundle: bundle)
        : await loadAll(bundle: bundle);
    return entries['$surah:$ayah'];
  }

  /// Whether tafsir exists for specific surah, ayah and chosen source.
  Future<bool> hasTafsir(
    int surah,
    int ayah, {
    TafsirSource source = TafsirSource.jalalayn,
    AssetBundle? bundle,
  }) async {
    final entries = source == TafsirSource.muyassar
        ? await loadMuyassar(bundle: bundle)
        : await loadAll(bundle: bundle);
    return entries.containsKey('$surah:$ayah');
  }

  /// Synchronous check if already cached for given source.
  bool hasTafsirSync(int surah, int ayah, {TafsirSource source = TafsirSource.jalalayn}) {
    final cache = source == TafsirSource.muyassar ? _cachedMuyassarEntries : _cachedEntries;
    if (cache == null) return false;
    return cache.containsKey('$surah:$ayah');
  }

  /// Synchronous retrieval if already cached for given source.
  TafsirEntry? getTafsirSync(int surah, int ayah, {TafsirSource source = TafsirSource.jalalayn}) {
    final cache = source == TafsirSource.muyassar ? _cachedMuyassarEntries : _cachedEntries;
    if (cache == null) return null;
    return cache['$surah:$ayah'];
  }

  /// Clears in-memory caches (for testing)
  static void clearCacheForTesting() {
    _cachedEntries = null;
    _cachedMuyassarEntries = null;
  }
}
