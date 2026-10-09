import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/quran/data/tajweed_repository.dart';
import 'package:muslim_ultra/features/quran/domain/models/tajweed_rule.dart';

final tajweedRepositoryProvider = Provider<TajweedRepository>((ref) {
  return TajweedRepository();
});

class TajweedEnabledNotifier extends StateNotifier<bool> {
  static const String _prefKey = 'tajweed_color_mode_enabled';

  TajweedEnabledNotifier() : super(true) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_prefKey) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, state);
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, enabled);
  }
}

final tajweedEnabledProvider =
    StateNotifierProvider<TajweedEnabledNotifier, bool>((ref) {
  return TajweedEnabledNotifier();
});

final surahTajweedAnnotationsProvider =
    FutureProvider.family<Map<int, List<TajweedAnnotation>>, int>(
        (ref, surahNumber) async {
  final repo = ref.watch(tajweedRepositoryProvider);
  return repo.getSurahAnnotations(surahNumber);
});
