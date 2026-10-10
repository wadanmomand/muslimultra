import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/mosques/domain/models/mosque.dart';

class MosquesException implements Exception {
  final String message;
  final dynamic cause;

  const MosquesException(this.message, [this.cause]);

  @override
  String toString() => 'MosquesException: $message ${cause != null ? "($cause)" : ""}';
}

class MosquesQueryResult {
  final List<Mosque> mosques;
  final bool isFromCache;
  final DateTime? cachedAt;

  const MosquesQueryResult({
    required this.mosques,
    this.isFromCache = false,
    this.cachedAt,
  });
}

class MosquesRepository {
  static const String cacheKey = 'mosques_cache_v1';
  static const Duration cacheTtl = Duration(hours: 24);
  static const String overpassEndpoint = 'https://overpass-api.de/api/interpreter';

  final http.Client _client;
  final SharedPreferences? prefs;

  MosquesRepository({
    http.Client? client,
    this.prefs,
  }) : _client = client ?? http.Client();

  Future<SharedPreferences> _getPrefs() async {
    if (prefs != null) return prefs!;
    return await SharedPreferences.getInstance();
  }

  /// Fetches nearby mosques from Overpass API with local cache fallback
  Future<MosquesQueryResult> fetchNearbyMosques({
    required double latitude,
    required double longitude,
    int radiusMeters = 5000,
    bool forceRefresh = false,
  }) async {
    // 1. Check cache if not forcing refresh
    if (!forceRefresh) {
      final cached = await getCachedMosques(
        userLat: latitude,
        userLon: longitude,
        radiusMeters: radiusMeters,
      );
      if (cached != null) {
        return cached;
      }
    }

    // 2. Fetch from Overpass API
    final query =
        '[out:json][timeout:25];node(around:$radiusMeters,$latitude,$longitude)[amenity=place_of_worship][religion=muslim];out;';

    try {
      final response = await _client.post(
        Uri.parse(overpassEndpoint),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8',
          'User-Agent': 'MuslimUltra/2.4 (https://github.com/wadanmomand/muslimultra)',
        },
        body: 'data=${Uri.encodeQueryComponent(query)}',
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw MosquesException(
          'Overpass server returned HTTP ${response.statusCode}',
        );
      }

      final dynamic decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['elements'] is! List) {
        throw const MosquesException('Invalid Overpass response format');
      }

      final elements = decoded['elements'] as List;
      final mosques = elements
          .whereType<Map<String, dynamic>>()
          .map((e) => Mosque.fromOverpassJson(e, userLat: latitude, userLon: longitude))
          .toList();

      // Sort by distance ascending
      mosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      // Save to cache
      await _saveToCache(
        mosques: mosques,
        userLat: latitude,
        userLon: longitude,
        radiusMeters: radiusMeters,
      );

      return MosquesQueryResult(
        mosques: mosques,
        isFromCache: false,
      );
    } catch (e) {
      // If network fails, try returning cached result even if old, or throw typed exception
      final cached = await getCachedMosques(
        userLat: latitude,
        userLon: longitude,
        radiusMeters: radiusMeters,
        allowExpired: true,
      );

      if (cached != null && cached.mosques.isNotEmpty) {
        return cached;
      }

      if (e is MosquesException) {
        rethrow;
      }
      throw MosquesException('Network error connecting to Overpass API', e);
    }
  }

  /// Retrieves cached mosques if available and within TTL
  Future<MosquesQueryResult?> getCachedMosques({
    required double userLat,
    required double userLon,
    required int radiusMeters,
    bool allowExpired = false,
  }) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(cacheKey);
      if (raw == null || raw.isEmpty) return null;

      final dynamic decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return null;

      final timestampMs = (decoded['timestamp'] as num?)?.toInt() ?? 0;
      final cachedTime = DateTime.fromMillisecondsSinceEpoch(timestampMs);
      final isExpired = DateTime.now().difference(cachedTime) > cacheTtl;

      if (isExpired && !allowExpired) {
        return null;
      }

      final rawList = decoded['mosques'] as List?;
      if (rawList == null) return null;

      final mosques = rawList
          .whereType<Map<String, dynamic>>()
          .map((m) => Mosque.fromJson(m))
          .toList();

      // Recalculate distance and bearing against current user coordinates
      final updatedMosques = mosques.map((m) {
        final dist = Mosque.calculateDistance(userLat, userLon, m.latitude, m.longitude);
        final bear = Mosque.calculateBearing(userLat, userLon, m.latitude, m.longitude);
        return Mosque(
          id: m.id,
          name: m.name,
          latitude: m.latitude,
          longitude: m.longitude,
          distanceMeters: dist,
          bearingDegrees: bear,
          street: m.street,
          city: m.city,
          rawTags: m.rawTags,
        );
      }).toList();

      updatedMosques.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      return MosquesQueryResult(
        mosques: updatedMosques,
        isFromCache: true,
        cachedAt: cachedTime,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToCache({
    required List<Mosque> mosques,
    required double userLat,
    required double userLon,
    required int radiusMeters,
  }) async {
    try {
      final prefs = await _getPrefs();
      final cacheData = {
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'userLat': userLat,
        'userLon': userLon,
        'radiusMeters': radiusMeters,
        'mosques': mosques.map((m) => m.toJson()).toList(),
      };
      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (_) {
      // Ignore cache write errors
    }
  }

  Future<void> clearCache() async {
    final prefs = await _getPrefs();
    await prefs.remove(cacheKey);
  }
}
