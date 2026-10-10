import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/wirasa/data/wirasa_engine.dart';
import 'package:muslim_ultra/features/wirasa/domain/heirs.dart';
import 'package:muslim_ultra/features/wirasa/domain/madhhab.dart';

const String _madhhabPrefKey = 'wirasa_madhhab_v1';

class MadhhabNotifier extends StateNotifier<FiqhMadhhab> {
  MadhhabNotifier() : super(FiqhMadhhab.hanafi) {
    _loadMadhhab();
  }

  Future<void> _loadMadhhab() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_madhhabPrefKey);
      if (saved != null) {
        state = FiqhMadhhab.values.firstWhere(
          (m) => m.name == saved,
          orElse: () => FiqhMadhhab.hanafi,
        );
      }
    } catch (_) {}
  }

  Future<void> setMadhhab(FiqhMadhhab madhhab) async {
    state = madhhab;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_madhhabPrefKey, madhhab.name);
    } catch (_) {}
  }
}

final madhhabProvider =
    StateNotifierProvider<MadhhabNotifier, FiqhMadhhab>((ref) {
  return MadhhabNotifier();
});

class HeirsNotifier extends StateNotifier<HeirsInput> {
  HeirsNotifier() : super(const HeirsInput());

  void setHusband(int val) {
    state = state.copyWith(husband: val.clamp(0, 1), wives: 0);
  }

  void setWives(int val) {
    state = state.copyWith(wives: val.clamp(0, 4), husband: 0);
  }

  void setFather(int val) {
    state = state.copyWith(father: val.clamp(0, 1));
  }

  void setMother(int val) {
    state = state.copyWith(mother: val.clamp(0, 1));
  }

  void setSons(int val) {
    state = state.copyWith(sons: val.clamp(0, 50));
  }

  void setDaughters(int val) {
    state = state.copyWith(daughters: val.clamp(0, 50));
  }

  void setPaternalGrandfather(int val) {
    state = state.copyWith(paternalGrandfather: val.clamp(0, 1));
  }

  void setPaternalGrandmother(int val) {
    state = state.copyWith(paternalGrandmother: val.clamp(0, 1));
  }

  void setMaternalGrandmother(int val) {
    state = state.copyWith(maternalGrandmother: val.clamp(0, 1));
  }

  void setFullBrothers(int val) {
    state = state.copyWith(fullBrothers: val.clamp(0, 50));
  }

  void setFullSisters(int val) {
    state = state.copyWith(fullSisters: val.clamp(0, 50));
  }

  void setMaternalSiblings(int val) {
    state = state.copyWith(maternalSiblings: val.clamp(0, 50));
  }

  void reset() {
    state = const HeirsInput();
  }
}

final heirsInputProvider =
    StateNotifierProvider<HeirsNotifier, HeirsInput>((ref) {
  return HeirsNotifier();
});

final wirasaCalculationProvider = Provider<CalculationResult>((ref) {
  final input = ref.watch(heirsInputProvider);
  final madhhab = ref.watch(madhhabProvider);
  return WirasaEngine.calculate(input: input, madhhab: madhhab);
});
