import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/hajj/domain/models/hajj_step.dart';

class HajjLoadException implements Exception {
  final String message;
  final dynamic cause;

  const HajjLoadException(this.message, [this.cause]);

  @override
  String toString() => 'HajjLoadException: $message ${cause != null ? '($cause)' : ''}';
}

class HajjRepository {
  static const String assetPath = 'assets/hajj/hajj_guide.json';
  static const String progressKey = 'hajj_progress_v1';

  static List<HajjStep>? _cachedSteps;

  static void clearCacheForTesting() {
    _cachedSteps = null;
  }

  /// Loads all 16 Hajj/Umrah/Checklist steps from bundled asset
  Future<List<HajjStep>> getSteps({AssetBundle? bundle}) async {
    if (_cachedSteps != null) return _cachedSteps!;

    try {
      final b = bundle ?? rootBundle;
      final jsonString = await b.loadString(assetPath);
      final decoded = json.decode(jsonString);

      if (decoded is! Map<String, dynamic> || !decoded.containsKey('steps')) {
        throw const HajjLoadException('Invalid JSON schema: missing "steps" array');
      }

      final list = decoded['steps'] as List<dynamic>;
      final parsed = list
          .map((item) => HajjStep.fromJson(item as Map<String, dynamic>))
          .toList();

      _cachedSteps = parsed;
      return parsed;
    } catch (e) {
      if (e is HajjLoadException) rethrow;
      throw HajjLoadException('Failed to load Hajj guide dataset', e);
    }
  }

  /// Retrieves the distinct list of phase names (e.g. ['Umrah', 'Hajj', 'Checklist'])
  Future<List<String>> getPhases({AssetBundle? bundle}) async {
    final steps = await getSteps(bundle: bundle);
    final seen = <String>{};
    final phases = <String>[];

    for (final s in steps) {
      if (seen.add(s.phaseEn)) {
        phases.add(s.phaseEn);
      }
    }
    return phases;
  }

  /// Retrieves steps for a specific phase (case-insensitive)
  Future<List<HajjStep>> stepsForPhase(String phase, {AssetBundle? bundle}) async {
    final steps = await getSteps(bundle: bundle);
    final normalized = phase.toLowerCase().trim();
    return steps
        .where((s) => s.phaseEn.toLowerCase().trim() == normalized)
        .toList();
  }

  /// Gets set of completed step numbers from SharedPreferences
  Future<Set<int>> getCompletedSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(progressKey);
    if (list != null) {
      return list.map((e) => int.tryParse(e)).whereType<int>().toSet();
    }
    return <int>{};
  }

  /// Checks if a step is marked completed
  Future<bool> isStepCompleted(int stepNumber) async {
    final completed = await getCompletedSteps();
    return completed.contains(stepNumber);
  }

  /// Toggles completion status of a step. Returns new completed state.
  Future<bool> toggleStepCompleted(int stepNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedSteps();
    final isNowDone = !completed.contains(stepNumber);

    if (isNowDone) {
      completed.add(stepNumber);
    } else {
      completed.remove(stepNumber);
    }

    await prefs.setStringList(
      progressKey,
      completed.map((e) => e.toString()).toList(),
    );
    return isNowDone;
  }

  /// Clears progress for testing
  Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(progressKey);
  }
}
