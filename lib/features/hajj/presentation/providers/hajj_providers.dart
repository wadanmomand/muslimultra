import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/hajj/data/hajj_repository.dart';
import 'package:muslim_ultra/features/hajj/domain/models/hajj_step.dart';

final hajjRepositoryProvider = Provider<HajjRepository>((ref) {
  return HajjRepository();
});

final hajjStepsProvider = FutureProvider<List<HajjStep>>((ref) async {
  final repo = ref.watch(hajjRepositoryProvider);
  return repo.getSteps();
});

final hajjPhasesProvider = FutureProvider<List<String>>((ref) async {
  final repo = ref.watch(hajjRepositoryProvider);
  return repo.getPhases();
});

final selectedPhaseIndexProvider = StateProvider<int>((ref) {
  return 0;
});

final completedHajjStepsProvider = FutureProvider<Set<int>>((ref) async {
  final repo = ref.watch(hajjRepositoryProvider);
  return repo.getCompletedSteps();
});

class HajjController {
  final Ref ref;
  final HajjRepository repo;

  HajjController(this.ref, this.repo);

  Future<bool> toggleStep(int stepNumber) async {
    final result = await repo.toggleStepCompleted(stepNumber);
    ref.invalidate(completedHajjStepsProvider);
    return result;
  }
}

final hajjControllerProvider = Provider<HajjController>((ref) {
  final repo = ref.watch(hajjRepositoryProvider);
  return HajjController(ref, repo);
});
