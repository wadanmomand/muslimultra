import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/features/deen/presentation/providers/deen_providers.dart';
import 'package:muslim_ultra/features/quiz/data/quiz_repository.dart';
import 'package:muslim_ultra/features/quiz/domain/models/quiz_question.dart';

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository();
});

final todayQuizQuestionProvider = FutureProvider<QuizQuestion>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.getQuestionForDay();
});

final todayQuizAnswerProvider = FutureProvider<QuizAnswerRecord?>((ref) async {
  final repo = ref.watch(quizRepositoryProvider);
  return repo.getAnswerForDay();
});

class QuizController {
  final Ref ref;
  final QuizRepository repo;

  QuizController(this.ref, this.repo);

  Future<QuizAnswerRecord> submitAnswer(QuizQuestion question, int selectedIndex) async {
    final deenRepo = ref.read(deenRepositoryProvider);
    final result = await repo.submitAnswer(
      question: question,
      selectedIndex: selectedIndex,
      deenRepo: deenRepo,
    );
    ref.invalidate(todayQuizAnswerProvider);
    ref.invalidate(dailyDeenStateProvider);
    ref.invalidate(deenXpProvider);
    return result;
  }
}

final quizControllerProvider = Provider<QuizController>((ref) {
  final repo = ref.watch(quizRepositoryProvider);
  return QuizController(ref, repo);
});
