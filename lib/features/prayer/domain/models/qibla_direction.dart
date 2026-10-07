/// Qibla Calculation Result
class QiblaDirectionData {
  final double qiblaBearing; // Degrees from True North (0-360°)
  final double distanceKm; // Distance from current point to Kaaba
  final double currentHeading; // User device heading (0-360°)
  final double offsetAngle; // Difference between heading and Qibla (-180 to +180)
  final bool isAligned; // Within ±2° acceptance (Spec §3 M1)
  final double accuracy; // Sensor accuracy
  final bool needsCalibration;
  final bool isSensorAvailable; // Whether live hardware compass is available

  const QiblaDirectionData({
    required this.qiblaBearing,
    required this.distanceKm,
    this.currentHeading = 0.0,
    this.offsetAngle = 0.0,
    this.isAligned = false,
    this.accuracy = 1.0,
    this.needsCalibration = false,
    this.isSensorAvailable = true,
  });

  QiblaDirectionData copyWith({
    double? qiblaBearing,
    double? distanceKm,
    double? currentHeading,
    double? offsetAngle,
    bool? isAligned,
    double? accuracy,
    bool? needsCalibration,
    bool? isSensorAvailable,
  }) {
    return QiblaDirectionData(
      qiblaBearing: qiblaBearing ?? this.qiblaBearing,
      distanceKm: distanceKm ?? this.distanceKm,
      currentHeading: currentHeading ?? this.currentHeading,
      offsetAngle: offsetAngle ?? this.offsetAngle,
      isAligned: isAligned ?? this.isAligned,
      accuracy: accuracy ?? this.accuracy,
      needsCalibration: needsCalibration ?? this.needsCalibration,
      isSensorAvailable: isSensorAvailable ?? this.isSensorAvailable,
    );
  }
}
