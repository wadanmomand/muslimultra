import 'package:geolocator/geolocator.dart';

class LocationModel {
  final String cityName;
  final String countryName;
  final double latitude;
  final double longitude;
  final double timezoneOffsetHours;
  final bool isGps;

  const LocationModel({
    required this.cityName,
    required this.countryName,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffsetHours,
    this.isGps = false,
  });

  String get displayName => '$cityName, $countryName';
}

class LocationService {
  // Preset Benchmark & Common Cities
  static const List<LocationModel> presetLocations = [
    LocationModel(
      cityName: 'Karachi',
      countryName: 'Pakistan',
      latitude: 24.8607,
      longitude: 67.0011,
      timezoneOffsetHours: 5.0,
    ),
    LocationModel(
      cityName: 'Makkah',
      countryName: 'Saudi Arabia',
      latitude: 21.4225,
      longitude: 39.8262,
      timezoneOffsetHours: 3.0,
    ),
    LocationModel(
      cityName: 'London',
      countryName: 'United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
      timezoneOffsetHours: 1.0, // British Summer Time / UTC+1
    ),
    LocationModel(
      cityName: 'New York',
      countryName: 'United States',
      latitude: 40.7128,
      longitude: -74.0060,
      timezoneOffsetHours: -4.0, // EDT
    ),
    LocationModel(
      cityName: 'Cairo',
      countryName: 'Egypt',
      latitude: 30.0444,
      longitude: 31.2357,
      timezoneOffsetHours: 3.0,
    ),
    LocationModel(
      cityName: 'Dubai',
      countryName: 'United Arab Emirates',
      latitude: 25.2048,
      longitude: 55.2708,
      timezoneOffsetHours: 4.0,
    ),
    LocationModel(
      cityName: 'Istanbul',
      countryName: 'Turkey',
      latitude: 41.0082,
      longitude: 28.9784,
      timezoneOffsetHours: 3.0,
    ),
    LocationModel(
      cityName: 'Kuala Lumpur',
      countryName: 'Malaysia',
      latitude: 3.1390,
      longitude: 101.6869,
      timezoneOffsetHours: 8.0,
    ),
  ];

  static LocationModel get defaultLocation => presetLocations[0]; // Karachi (default)

  /// Attempt to fetch device GPS position on-device
  static Future<LocationModel?> getCurrentGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium),
      );

      final now = DateTime.now();
      final timezoneOffsetHours = now.timeZoneOffset.inMinutes / 60.0;

      return LocationModel(
        cityName: 'Current Location',
        countryName: 'GPS',
        latitude: position.latitude,
        longitude: position.longitude,
        timezoneOffsetHours: timezoneOffsetHours,
        isGps: true,
      );
    } catch (_) {
      return null;
    }
  }
}
