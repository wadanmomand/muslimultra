import 'dart:async';
import 'dart:math' as math;
import 'package:flutter_compass/flutter_compass.dart';
import 'package:muslim_ultra/features/prayer/domain/models/qibla_direction.dart';

/// Structured heading event from platform sensor fusion
class CompassHeadingEvent {
  final double heading;
  final double accuracy;
  final bool isAvailable;

  const CompassHeadingEvent({
    required this.heading,
    this.accuracy = 1.0,
    this.isAvailable = true,
  });
}

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
    bool isSensorAvailable = true,
  }) {
    final bearing = calculateBearing(userLat, userLng);
    final distance = calculateDistanceKm(userLat, userLng);

    // Compute difference between heading and Qibla (-180 to +180)
    var diff = (bearing - currentHeading) % 360.0;
    if (diff > 180.0) diff -= 360.0;
    if (diff < -180.0) diff += 360.0;

    // Spec §3 M1 Acceptance: Bearing within ±2° (requires valid sensor)
    final isAligned = isSensorAvailable && diff.abs() <= 2.0;

    return QiblaDirectionData(
      qiblaBearing: bearing,
      distanceKm: distance,
      currentHeading: currentHeading,
      offsetAngle: diff,
      isAligned: isAligned,
      accuracy: accuracy,
      needsCalibration: !isSensorAvailable || accuracy < 0.5,
      isSensorAvailable: isSensorAvailable,
    );
  }

  /// Stream device compass heading with platform sensor fusion & tilt compensation
  static Stream<CompassHeadingEvent> streamHeading() {
    final compassStream = FlutterCompass.events;
    if (compassStream == null) {
      return Stream.value(
        const CompassHeadingEvent(
          heading: 0.0,
          accuracy: 0.0,
          isAvailable: false,
        ),
      );
    }

    return compassStream.map((event) {
      if (event.heading == null) {
        return const CompassHeadingEvent(
          heading: 0.0,
          accuracy: 0.0,
          isAvailable: false,
        );
      }
      var heading = event.heading!;
      heading = (heading + 360.0) % 360.0;
      return CompassHeadingEvent(
        heading: heading,
        accuracy: event.accuracy ?? 1.0,
        isAvailable: true,
      );
    }).handleError((_) {
      return const CompassHeadingEvent(
        heading: 0.0,
        accuracy: 0.0,
        isAvailable: false,
      );
    });
  }
}
