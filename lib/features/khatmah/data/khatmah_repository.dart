import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class KhatmahState {
  final Set<int> completedParas;
  final int completedKhatmahs;

  const KhatmahState({
    required this.completedParas,
    required this.completedKhatmahs,
  });

  int get completedCount => completedParas.length;
  double get progressFraction => (completedCount / 30.0).clamp(0.0, 1.0);
  int get progressPercentage => ((completedCount / 30.0) * 100).round();
  bool isParaCompleted(int para) => completedParas.contains(para);

  factory KhatmahState.fromJson(Map<String, dynamic> json) {
    final list = (json['completedParas'] as List<dynamic>?)
            ?.map((e) => (e as num).toInt())
            .toSet() ??
        <int>{};
    final khatmahs = (json['completedKhatmahs'] as num?)?.toInt() ?? 0;
    return KhatmahState(
      completedParas: list,
      completedKhatmahs: khatmahs,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedParas': completedParas.toList(),
        'completedKhatmahs': completedKhatmahs,
      };
}

class KhatmahRepository {
  static const String storageKey = 'khatmah_v1';

  /// Loads the user's current Khatmah progress
  Future<KhatmahState> getKhatmahState() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) {
      return const KhatmahState(completedParas: {}, completedKhatmahs: 0);
    }
    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return KhatmahState.fromJson(map);
    } catch (_) {
      return const KhatmahState(completedParas: {}, completedKhatmahs: 0);
    }
  }

  /// Toggles completion of a specific Para (1 through 30).
  /// If completing the 30th para (reaching 30/30), increments completedKhatmahs and resets the 30 paras.
  Future<KhatmahState> togglePara(int paraNumber) async {
    if (paraNumber < 1 || paraNumber > 30) return getKhatmahState();

    final current = await getKhatmahState();
    final updatedParas = Set<int>.from(current.completedParas);
    var updatedKhatmahs = current.completedKhatmahs;

    if (updatedParas.contains(paraNumber)) {
      updatedParas.remove(paraNumber);
    } else {
      updatedParas.add(paraNumber);
      // Check if this completes the full Quran (all 30 paras)
      if (updatedParas.length == 30) {
        updatedKhatmahs++;
        updatedParas.clear();
      }
    }

    final newState = KhatmahState(
      completedParas: updatedParas,
      completedKhatmahs: updatedKhatmahs,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, json.encode(newState.toJson()));
    return newState;
  }

  /// Resets current progress
  Future<void> resetCurrentKhatmah() async {
    final current = await getKhatmahState();
    final newState = KhatmahState(
      completedParas: {},
      completedKhatmahs: current.completedKhatmahs,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(storageKey, json.encode(newState.toJson()));
  }
}
