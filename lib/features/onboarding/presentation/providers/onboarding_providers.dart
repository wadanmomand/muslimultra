import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/onboarding/data/onboarding_storage_service.dart';

final onboardingCompletedProvider =
    StateNotifierProvider<OnboardingCompletedNotifier, bool?>((ref) {
  return OnboardingCompletedNotifier();
});

class OnboardingCompletedNotifier extends StateNotifier<bool?> {
  OnboardingCompletedNotifier([bool? initial]) : super(initial) {
    if (initial == null) {
      checkStatus();
    }
  }

  Future<void> checkStatus() async {
    final completed = await OnboardingStorageService.isOnboardingCompleted();
    state = completed;
  }

  Future<void> complete({String? learningGoal}) async {
    await OnboardingStorageService.completeOnboarding(learningGoal: learningGoal);
    state = true;
  }
}
