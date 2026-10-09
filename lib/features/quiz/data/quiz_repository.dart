import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/deen/data/deen_repository.dart';
import 'package:muslim_ultra/features/quiz/domain/models/quiz_question.dart';

class QuizAnswerRecord {
  final String date;
  final int questionId;
  final int selectedIndex;
  final bool isCorrect;

  const QuizAnswerRecord({
    required this.date,
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  factory QuizAnswerRecord.fromJson(Map<String, dynamic> json) {
    return QuizAnswerRecord(
      date: (json['date'] as String?) ?? '',
      questionId: (json['questionId'] as num?)?.toInt() ?? 0,
      selectedIndex: (json['selectedIndex'] as num?)?.toInt() ?? -1,
      isCorrect: (json['isCorrect'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'questionId': questionId,
        'selectedIndex': selectedIndex,
        'isCorrect': isCorrect,
      };
}

class QuizRepository {
  static const String assetPath = 'assets/quiz/quiz.json';
  static const String prefsPrefix = 'quiz_v1_';
  static List<QuizQuestion>? _cachedQuestions;

  static String formatDate(DateTime dt) => DateFormat('yyyy-MM-dd').format(dt);

  /// Loads all 60 questions from bundled asset
  Future<List<QuizQuestion>> getAllQuestions({AssetBundle? bundle}) async {
    if (_cachedQuestions != null) return _cachedQuestions!;

    try {
      final b = bundle ?? rootBundle;
      final raw = await b.loadString(assetPath);
      final map = json.decode(raw) as Map<String, dynamic>;
      final questionsList = map['questions'] as List<dynamic>?;

      if (questionsList == null || questionsList.isEmpty) {
        throw const QuizLoadException('Quiz question bank is empty or corrupt.');
      }

      final parsed = questionsList
          .map((item) => QuizQuestion.fromJson(item as Map<String, dynamic>))
          .toList();

      if (parsed.length != 60) {
        throw QuizLoadException('Expected 60 questions, found ${parsed.length}');
      }

      _cachedQuestions = parsed;
      return parsed;
    } catch (e) {
      if (e is QuizLoadException) rethrow;
      throw QuizLoadException('Failed to load quiz asset: $e');
    }
  }

  /// Returns deterministic question for the day (cycles through 60 questions without repeat in 60-day window)
  Future<QuizQuestion> getQuestionForDay([DateTime? date]) async {
    final questions = await getAllQuestions();
    final target = date ?? DateTime.now();
    // UTC date-only calculation ensures timezone-independent consistency
    final dateOnly = DateTime.utc(target.year, target.month, target.day);
    final baseDate = DateTime.utc(2026, 1, 1);
    final days = dateOnly.difference(baseDate).inDays;
    final index = (days % questions.length + questions.length) % questions.length;
    return questions[index];
  }

  /// Gets the recorded answer for [date] if answered
  Future<QuizAnswerRecord?> getAnswerForDay([DateTime? date]) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$prefsPrefix$dateStr');
    if (raw == null || raw.isEmpty) return null;

    try {
      final map = json.decode(raw) as Map<String, dynamic>;
      return QuizAnswerRecord.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  /// Submits an answer for today's question and awards +20 XP if correct
  Future<QuizAnswerRecord> submitAnswer({
    required QuizQuestion question,
    required int selectedIndex,
    DateTime? date,
    DeenRepository? deenRepo,
  }) async {
    final target = date ?? DateTime.now();
    final dateStr = formatDate(target);
    final isCorrect = selectedIndex == question.correctIndex;

    final record = QuizAnswerRecord(
      date: dateStr,
      questionId: question.id,
      selectedIndex: selectedIndex,
      isCorrect: isCorrect,
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$prefsPrefix$dateStr', json.encode(record.toJson()));

    // Award +20 XP if correct
    if (isCorrect) {
      final dr = deenRepo ?? DeenRepository();
      await dr.awardXp(20, 'quiz_$dateStr');
    }

    return record;
  }

  /// Clears cache for tests
  static void clearCacheForTesting() {
    _cachedQuestions = null;
  }
}
