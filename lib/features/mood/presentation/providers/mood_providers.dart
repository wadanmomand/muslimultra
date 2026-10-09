import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/mood/data/mood_repository.dart';
import 'package:muslim_ultra/features/mood/domain/models/mood_item.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) {
  return MoodRepository();
});

final moodListProvider = FutureProvider<List<MoodItem>>((ref) async {
  final repo = ref.watch(moodRepositoryProvider);
  return repo.getAllMoods();
});

final todayMoodProvider = FutureProvider<MoodItem?>((ref) async {
  final repo = ref.watch(moodRepositoryProvider);
  return repo.getTodayMood();
});

final selectedMoodKeyProvider = StateProvider<String?>((ref) {
  return null;
});

final activeMoodItemProvider = FutureProvider<MoodItem?>((ref) async {
  final selectedKey = ref.watch(selectedMoodKeyProvider);
  final repo = ref.watch(moodRepositoryProvider);
  if (selectedKey != null) {
    return repo.moodFor(selectedKey);
  }
  return repo.getTodayMood();
});

class MoodController {
  final Ref ref;
  final MoodRepository repo;

  MoodController(this.ref, this.repo);

  Future<void> selectAndLogMood(String moodKey) async {
    ref.read(selectedMoodKeyProvider.notifier).state = moodKey;
    await repo.logMood(moodKey);
    ref.invalidate(todayMoodProvider);
    ref.invalidate(activeMoodItemProvider);
  }
}

final moodControllerProvider = Provider<MoodController>((ref) {
  final repo = ref.watch(moodRepositoryProvider);
  return MoodController(ref, repo);
});
