import 'dart:math' as math;

class Mosque {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double distanceMeters;
  final double bearingDegrees;
  final String? street;
  final String? city;
  final Map<String, dynamic> rawTags;

  const Mosque({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distanceMeters,
    required this.bearingDegrees,
    this.street,
    this.city,
    this.rawTags = const {},
  });

  factory Mosque.fromOverpassJson(
    Map<String, dynamic> json, {
    required double userLat,
    required double userLon,
  }) {
    final id = json['id']?.toString() ?? '';
    final lat = (json['lat'] as num?)?.toDouble() ?? 0.0;
    final lon = (json['lon'] as num?)?.toDouble() ?? 0.0;
    final tags = (json['tags'] as Map<String, dynamic>?) ?? {};

    final name = tags['name'] ??
        tags['name:en'] ??
        tags['name:ar'] ??
        tags['name:ur'] ??
        tags['alt_name'] ??
        'Masjid';

    final street = tags['addr:street'] as String?;
    final city = tags['addr:city'] as String?;

    final distance = calculateDistance(userLat, userLon, lat, lon);
    final bearing = calculateBearing(userLat, userLon, lat, lon);

    return Mosque(
      id: id,
      name: name.toString().trim(),
      latitude: lat,
      longitude: lon,
      distanceMeters: distance,
      bearingDegrees: bearing,
      street: street,
      city: city,
      rawTags: tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'distanceMeters': distanceMeters,
      'bearingDegrees': bearingDegrees,
      'street': street,
      'city': city,
      'rawTags': rawTags,
    };
  }

  factory Mosque.fromJson(Map<String, dynamic> json) {
    return Mosque(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Masjid',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      distanceMeters: (json['distanceMeters'] as num?)?.toDouble() ?? 0.0,
      bearingDegrees: (json['bearingDegrees'] as num?)?.toDouble() ?? 0.0,
      street: json['street'] as String?,
      city: json['city'] as String?,
      rawTags: (json['rawTags'] as Map<String, dynamic>?) ?? {},
    );
  }

  /// Calculates Haversine distance in meters between two coordinates
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371000; // meters
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) *
            math.cos(_degToRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  /// Calculates bearing from user (lat1, lon1) to target (lat2, lon2) in degrees (0..360)
  static double calculateBearing(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    final double dLon = _degToRad(lon2 - lon1);
    final double y = math.sin(dLon) * math.cos(_degToRad(lat2));
    final double x = math.cos(_degToRad(lat1)) * math.sin(_degToRad(lat2)) -
        math.sin(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.cos(dLon);
    final double radians = math.atan2(y, x);
    return (_radToDeg(radians) + 360) % 360;
  }

  static double _degToRad(double deg) => deg * (math.pi / 180.0);
  static double _radToDeg(double rad) => rad * (180.0 / math.pi);
}
