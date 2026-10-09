import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'package:muslim_ultra/features/situations/data/situations_repository.dart';
import 'package:muslim_ultra/features/situations/domain/models/situation.dart';

final situationsRepositoryProvider = Provider<SituationsRepository>((ref) {
  return SituationsRepository();
});

/// Loads all 8 situations
final allSituationsProvider = FutureProvider<List<SituationModel>>((ref) async {
  final repo = ref.watch(situationsRepositoryProvider);
  return repo.getAllSituations();
});

/// Resolves an authentic Ayah from Quran bundle for a situation's ayat ref
final situationAyahProvider = FutureProvider.family<AyahModel?, SituationAyatRef>((ref, refAyah) async {
  final repo = ref.watch(situationsRepositoryProvider);
  return repo.resolveAyah(refAyah.surah, refAyah.ayah);
});
