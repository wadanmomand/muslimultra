import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/tasbih/data/tasbih_storage_service.dart';
import 'package:muslim_ultra/features/tasbih/domain/models/dhikr_preset.dart';

class TasbihState {
  final DhikrPreset selectedPreset;
  final int currentCount;
  final int target;
  final int todayTotal;
  final bool isCompleted;
  final List<DhikrPreset> presets;

  const TasbihState({
    required this.selectedPreset,
    required this.currentCount,
    required this.target,
    required this.todayTotal,
    required this.isCompleted,
    required this.presets,
  });

  TasbihState copyWith({
    DhikrPreset? selectedPreset,
    int? currentCount,
    int? target,
    int? todayTotal,
    bool? isCompleted,
    List<DhikrPreset>? presets,
  }) {
    return TasbihState(
      selectedPreset: selectedPreset ?? this.selectedPreset,
      currentCount: currentCount ?? this.currentCount,
      target: target ?? this.target,
      todayTotal: todayTotal ?? this.todayTotal,
      isCompleted: isCompleted ?? this.isCompleted,
      presets: presets ?? this.presets,
    );
  }

  double get progress => target > 0 ? (currentCount / target).clamp(0.0, 1.0) : 0.0;
}

class TasbihNotifier extends StateNotifier<TasbihState> {
  bool _isInitialized = false;

  TasbihNotifier()
      : super(
          TasbihState(
            selectedPreset: DhikrPreset.defaultPresets.first,
            currentCount: 0,
            target: DhikrPreset.defaultPresets.first.defaultTarget,
            todayTotal: 0,
            isCompleted: false,
            presets: DhikrPreset.defaultPresets,
          ),
        ) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    final selectedId = await TasbihStorageService.loadSelectedDhikrId();
    final preset = DhikrPreset.defaultPresets.firstWhere(
      (p) => p.id == selectedId,
      orElse: () => DhikrPreset.defaultPresets.first,
    );
    final count = await TasbihStorageService.loadCurrentCount(preset.id);
    final target = await TasbihStorageService.loadTarget(preset.id, preset.defaultTarget);
    final today = await TasbihStorageService.getTodayCount(preset.id);

    if (!_isInitialized) {
      _isInitialized = true;
      state = state.copyWith(
        selectedPreset: preset,
        currentCount: count,
        target: target,
        todayTotal: today,
        isCompleted: count >= target && target > 0,
      );
    }
  }

  /// Increment count by 1 with haptic feedback
  void increment() {
    _isInitialized = true;
    final newCount = state.currentCount + 1;
    final reached = newCount == state.target;

    // Haptic feedback (Task 3)
    try {
      if (reached) {
        HapticFeedback.heavyImpact();
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
      // Gracefully handled in headless test environments
    }

    final updatedToday = state.todayTotal + 1;
    state = state.copyWith(
      currentCount: newCount,
      todayTotal: updatedToday,
      isCompleted: newCount >= state.target,
    );

    // Persist in background (Task 4)
    TasbihStorageService.incrementTodayCount(state.selectedPreset.id);
    TasbihStorageService.saveCurrentCount(state.selectedPreset.id, newCount);
  }

  /// Reset count to 0 (Task 1)
  void reset() {
    _isInitialized = true;
    state = state.copyWith(
      currentCount: 0,
      isCompleted: false,
    );
    TasbihStorageService.saveCurrentCount(state.selectedPreset.id, 0);
  }

  /// Select a new Dhikr preset (Task 2)
  Future<void> selectPreset(DhikrPreset preset) async {
    _isInitialized = true;
    final count = await TasbihStorageService.loadCurrentCount(preset.id);
    final target = await TasbihStorageService.loadTarget(preset.id, preset.defaultTarget);
    final today = await TasbihStorageService.getTodayCount(preset.id);

    state = state.copyWith(
      selectedPreset: preset,
      currentCount: count,
      target: target,
      todayTotal: today,
      isCompleted: count >= target && target > 0,
    );
    await TasbihStorageService.saveSelectedDhikrId(preset.id);
  }

  /// Set custom target (Task 2)
  void setCustomTarget(int newTarget) {
    if (newTarget <= 0) return;
    _isInitialized = true;
    state = state.copyWith(
      target: newTarget,
      isCompleted: state.currentCount >= newTarget,
    );
    TasbihStorageService.saveTarget(state.selectedPreset.id, newTarget);
  }
}

final tasbihProvider = StateNotifierProvider<TasbihNotifier, TasbihState>((ref) {
  return TasbihNotifier();
});
