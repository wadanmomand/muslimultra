import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/muhasaba/data/muhasaba_reminder_service.dart';
import 'package:muslim_ultra/features/muhasaba/data/muhasaba_repository.dart';
import 'package:muslim_ultra/features/muhasaba/domain/models/muhasaba_questions.dart';

final muhasabaRepositoryProvider = Provider<MuhasabaRepository>((ref) {
  return MuhasabaRepository();
});

/// Currently selected date in the 14-day pager (default: today's date formatted yyyy-MM-dd)
final muhasabaSelectedDateProvider = StateProvider<String>((ref) {
  return MuhasabaRepository.formatDate(DateTime.now());
});

/// Entry for a specific date
final muhasabaEntryProvider = FutureProvider.family<MuhasabaEntry?, String>((ref, date) async {
  final repo = ref.watch(muhasabaRepositoryProvider);
  return repo.getEntry(date);
});

/// Week entries (7 days) for the summary card
final muhasabaWeekProvider = FutureProvider<List<MuhasabaEntry?>>((ref) async {
  final repo = ref.watch(muhasabaRepositoryProvider);
  return repo.getWeekEntries();
});

/// 14-day history for the date pager
final muhasaba14DaysProvider = FutureProvider<List<MapEntry<DateTime, MuhasabaEntry?>>>((ref) async {
  final repo = ref.watch(muhasabaRepositoryProvider);
  return repo.getLast14Days();
});

/// Completion streak
final muhasabaStreakProvider = FutureProvider<int>((ref) async {
  final repo = ref.watch(muhasabaRepositoryProvider);
  return repo.completionStreak();
});

/// Reminder enabled status
final muhasabaReminderEnabledProvider = FutureProvider<bool>((ref) async {
  return MuhasabaReminderService.isReminderEnabled();
});

/// State for the active reflection form
class MuhasabaFormState {
  final String date;
  final Map<String, int?> answers;
  final bool isSaved;
  final bool isSaving;

  const MuhasabaFormState({
    required this.date,
    required this.answers,
    this.isSaved = false,
    this.isSaving = false,
  });

  int get answeredCount =>
      MuhasabaQuestions.list.where((q) => answers[q.id] != null).length;

  bool get isCompleted =>
      MuhasabaQuestions.list.every((q) => answers.containsKey(q.id) && answers[q.id] != null);

  MuhasabaFormState copyWith({
    String? date,
    Map<String, int?>? answers,
    bool? isSaved,
    bool? isSaving,
  }) {
    return MuhasabaFormState(
      date: date ?? this.date,
      answers: answers ?? Map<String, int?>.from(this.answers),
      isSaved: isSaved ?? this.isSaved,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

class MuhasabaFormNotifier extends StateNotifier<MuhasabaFormState> {
  final MuhasabaRepository repo;
  final DeenRepository deenRepo;
  final Ref ref;

  MuhasabaFormNotifier({
    required this.repo,
    required this.deenRepo,
    required this.ref,
    required String initialDate,
  }) : super(MuhasabaFormState(date: initialDate, answers: {})) {
    loadDate(initialDate);
  }

  Future<void> loadDate(String date) async {
    final existing = await repo.getEntry(date);
    if (state.answers.isEmpty && existing != null) {
      state = MuhasabaFormState(
        date: date,
        answers: Map<String, int?>.from(existing.answers),
        isSaved: true,
      );
    }
  }

  void setAnswer(String questionId, int? value) {
    final updated = Map<String, int?>.from(state.answers);
    if (value == null) {
      updated.remove(questionId);
    } else {
      updated[questionId] = value;
    }
    state = state.copyWith(answers: updated, isSaved: false);
  }

  Future<bool> save() async {
    state = state.copyWith(isSaving: true);
    try {
      await repo.saveEntry(state.date, state.answers);

      // Check if all 6 answered -> Award 5 XP via DeenRepository (Step 4)
      if (state.isCompleted) {
        try {
          await deenRepo.awardXp(5, 'muhasaba_${state.date}');
        } catch (_) {}
      }

      state = state.copyWith(isSaved: true, isSaving: false);

      // Invalidate queries so UI updates
      ref.invalidate(muhasabaEntryProvider(state.date));
      ref.invalidate(muhasabaWeekProvider);
      ref.invalidate(muhasaba14DaysProvider);
      ref.invalidate(muhasabaStreakProvider);
      return true;
    } catch (_) {
      state = state.copyWith(isSaving: false);
      return false;
    }
  }
}

final muhasabaFormNotifierProvider = StateNotifierProvider.family<MuhasabaFormNotifier, MuhasabaFormState, String>((ref, date) {
  final repo = ref.watch(muhasabaRepositoryProvider);
  final deenRepo = DeenRepository();
  return MuhasabaFormNotifier(
    repo: repo,
    deenRepo: deenRepo,
    ref: ref,
    initialDate: date,
  );
});
