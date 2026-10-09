import 'package:flutter/foundation.dart';

/// Exception thrown when quiz dataset is invalid or missing
class QuizLoadException implements Exception {
  final String message;
  const QuizLoadException(this.message);

  @override
  String toString() => 'QuizLoadException: $message';
}

/// Represents a single Daily Islamic Quiz question
@immutable
class QuizQuestion {
  final int id;
  final String category;
  final String qEn;
  final String qUr;
  final String qAr;
  final List<String> optsEn;
  final List<String> optsUr;
  final List<String> optsAr;
  final int correctIndex;
  final String explainEn;
  final String source;

  const QuizQuestion({
    required this.id,
    required this.category,
    required this.qEn,
    required this.qUr,
    required this.qAr,
    required this.optsEn,
    required this.optsUr,
    required this.optsAr,
    required this.correctIndex,
    required this.explainEn,
    required this.source,
  });

  /// Resolves question text for the current language code ('en', 'ar', 'ur')
  String localizedQuestion(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return qAr.isNotEmpty ? qAr : qEn;
      case 'ur':
        return qUr.isNotEmpty ? qUr : qEn;
      default:
        return qEn;
    }
  }

  /// Resolves options list for the current language code
  List<String> localizedOptions(String languageCode) {
    switch (languageCode) {
      case 'ar':
        return optsAr.isNotEmpty && optsAr.length == 4 ? optsAr : optsEn;
      case 'ur':
        return optsUr.isNotEmpty && optsUr.length == 4 ? optsUr : optsEn;
      default:
        return optsEn;
    }
  }

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    final optsEnRaw = (json['opts_en'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final optsUrRaw = (json['opts_ur'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];
    final optsArRaw = (json['opts_ar'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return QuizQuestion(
      id: (json['id'] as num?)?.toInt() ?? 0,
      category: (json['category'] as String?) ?? 'general',
      qEn: (json['q_en'] as String?) ?? '',
      qUr: (json['q_ur'] as String?) ?? '',
      qAr: (json['q_ar'] as String?) ?? '',
      optsEn: optsEnRaw,
      optsUr: optsUrRaw,
      optsAr: optsArRaw,
      correctIndex: (json['correct'] as num?)?.toInt() ?? 0,
      explainEn: (json['explain_en'] as String?) ?? '',
      source: (json['source'] as String?) ?? '',
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizQuestion && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
