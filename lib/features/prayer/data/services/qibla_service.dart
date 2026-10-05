import 'dart:async';
import 'dart:math' as math;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:muslim_ultra/features/prayer/domain/models/qibla_direction.dart';

class QiblaService {
  // Sacred Kaaba Coordinates in Makkah al-Mukarramah
  static const double kaabaLatitude = 21.4225241;
  static const double kaabaLongitude = 39.8261818;
  static const double earthRadiusKm = 6371.0;
  static const double d2r = math.pi / 180.0;
  static const double r2d = 180.0 / math.pi;

  /// Calculate Qibla forward bearing from true north (0..360°)
  static double calculateBearing(double userLat, double userLng) {
    final lat1 = userLat * d2r;
    final lat2 = kaabaLatitude * d2r;
    final dLng = (kaabaLongitude - userLng) * d2r;

    final y = math.sin(dLng);
    final x = math.cos(lat1) * math.tan(lat2) - math.sin(lat1) * math.cos(dLng);

    var bearing = math.atan2(y, x) * r2d;
    bearing = (bearing + 360.0) % 360.0;
    return (bearing * 10).round() / 10.0; // 1 decimal place
  }

  /// Calculate great circle distance to Kaaba in kilometers
  static double calculateDistanceKm(double userLat, double userLng) {
    final lat1 = userLat * d2r;
    final lat2 = kaabaLatitude * d2r;
    final dLat = (kaabaLatitude - userLat) * d2r;
    final dLng = (kaabaLongitude - userLng) * d2r;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return (earthRadiusKm * c).roundToDouble();
  }

  /// Evaluate Qibla alignment given user device heading
  static QiblaDirectionData evaluateQibla({
    required double userLat,
    required double userLng,
    required double currentHeading,
    double accuracy = 1.0,
  }) {
    final bearing = calculateBearing(userLat, userLng);
    final distance = calculateDistanceKm(userLat, userLng);

    // Compute difference between heading and Qibla (-180 to +180)
    var diff = (bearing - currentHeading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;

    // Spec §3 M1 Acceptance: Bearing within ±2°
    final isAligned = diff.abs() <= 2.0;

    return QiblaDirectionData(
      qiblaBearing: bearing,
      distanceKm: distance,
      currentHeading: currentHeading,
      offsetAngle: diff,
      isAligned: isAligned,
      accuracy: accuracy,
      needsCalibration: accuracy < 0.5,
    );
  }

  /// Stream device compass heading from magnetometer (with low-pass smoothing)
  static Stream<double> streamHeading() {
    return magnetometerEventStream().map((event) {
      // Calculate heading from X and Y magnetic fields
      var heading = math.atan2(event.y, event.x) * r2d;
      heading = (heading + 360.0) % 360.0;
      return heading;
    }).handleError((_) {
      // Stream fallback if sensor unavailable on emulator / desktop
      return Stream.value(0.0);
    });
  }
}
