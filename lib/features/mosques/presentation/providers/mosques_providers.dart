import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/mosques/data/mosques_repository.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

final mosquesRepositoryProvider = Provider<MosquesRepository>((ref) {
  return MosquesRepository();
});

final mosquesRadiusProvider = StateProvider<int>((ref) {
  return 5000; // 5 km default
});

final nearbyMosquesProvider =
    FutureProvider.autoDispose<MosquesQueryResult>((ref) async {
  final location = ref.watch(locationProvider);
  final radius = ref.watch(mosquesRadiusProvider);
  final repository = ref.watch(mosquesRepositoryProvider);

  return repository.fetchNearbyMosques(
    latitude: location.latitude,
    longitude: location.longitude,
    radiusMeters: radius,
  );
});
