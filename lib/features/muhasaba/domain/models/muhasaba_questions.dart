import 'package:flutter/foundation.dart';

@immutable
class MuhasabaQuestion {
  final String id;
  final String en;
  final String ar;
  final String ur;

  const MuhasabaQuestion({
    required this.id,
    required this.en,
    required this.ar,
    required this.ur,
  });

  String getText(String languageCode) {
    if (languageCode == 'ar') return ar;
    if (languageCode == 'ur') return ur;
    return en;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'en': en,
        'ar': ar,
        'ur': ur,
      };

  factory MuhasabaQuestion.fromJson(Map<String, dynamic> json) => MuhasabaQuestion(
        id: json['id'] as String,
        en: json['en'] as String,
        ar: json['ar'] as String,
        ur: json['ur'] as String,
      );
}

class MuhasabaQuestions {
  static const List<MuhasabaQuestion> list = [
    MuhasabaQuestion(
      id: 'q1',
      en: 'Did I pray all five prayers on time today?',
      ar: 'هل صليت الصلوات الخمس في وقتها اليوم؟',
      ur: 'کیا میں نے آج پانچوں نمازیں وقت پر ادا کیں؟',
    ),
    MuhasabaQuestion(
      id: 'q2',
      en: 'Did I guard my tongue from hurtful or backbiting words?',
      ar: 'هل حفظت لساني من الأذى والغيبة اليوم؟',
      ur: 'کیا میں نے اپنی زبان کو تکلیف دہ باتوں اور غیبت سے محفوظ رکھا؟',
    ),
    MuhasabaQuestion(
      id: 'q3',
      en: 'Did I recite or read some of the Quran today?',
      ar: 'هل تلوت أو قرأت شيئاً من القرآن الكريم اليوم؟',
      ur: 'کیا میں نے آج قرآن کریم کی کچھ تلاوت یا مطالعہ کیا؟',
    ),
    MuhasabaQuestion(
      id: 'q4',
      en: 'Was I kind and respectful to my parents and family?',
      ar: 'هل كنت باراً ومحترماً لوالديّ وأهلي؟',
      ur: 'کیا میں اپنے والدین اور اہل خانہ کے ساتھ حسن سلوک اور احترام سے پیش آیا؟',
    ),
    MuhasabaQuestion(
      id: 'q5',
      en: 'Did I earn honestly and avoid what Allah dislikes?',
      ar: 'هل كان كسبي حلالاً واجتنبت ما يكرهه الله؟',
      ur: 'کیا میری کمائی حلال تھی اور میں نے اللہ کی ناپسندیدہ چیزوں سے اجتناب کیا؟',
    ),
    MuhasabaQuestion(
      id: 'q6',
      en: 'Did I remember Allah with dhikr or istighfar today?',
      ar: 'هل ذكرت الله بالذكر أو الاستغفار اليوم؟',
      ur: 'کیا میں نے آج ذکر یا استغفار کے ذریعے اللہ کو یاد کیا؟',
    ),
  ];

  static MuhasabaQuestion? byId(String id) {
    try {
      return list.firstWhere((q) => q.id == id);
    } catch (_) {
      return null;
    }
  }
}

@immutable
class MuhasabaEntry {
  final String date; // yyyy-MM-dd
  final Map<String, int?> answers; // 2: yes, 1: partly, 0: no, null: skipped

  const MuhasabaEntry({
    required this.date,
    required this.answers,
  });

  /// True if all 6 questions have been answered with non-null values
  bool get isCompleted =>
      MuhasabaQuestions.list.every((q) => answers.containsKey(q.id) && answers[q.id] != null);

  /// Number of answered questions
  int get answeredCount =>
      MuhasabaQuestions.list.where((q) => answers[q.id] != null).length;

  int? getAnswer(String questionId) => answers[questionId];

  MuhasabaEntry copyWith({
    String? date,
    Map<String, int?>? answers,
  }) {
    return MuhasabaEntry(
      date: date ?? this.date,
      answers: answers ?? Map<String, int?>.from(this.answers),
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'answers': answers,
      };

  factory MuhasabaEntry.fromJson(Map<String, dynamic> json) {
    if (!json.containsKey('date')) {
      throw const FormatException('Missing date in MuhasabaEntry');
    }
    final rawAnswers = json['answers'];
    final parsedAnswers = <String, int?>{};
    if (rawAnswers is Map) {
      for (final entry in rawAnswers.entries) {
        final key = entry.key.toString();
        final dynamic val = entry.value;
        if (val == null) {
          parsedAnswers[key] = null;
        } else if (val is int && (val == 0 || val == 1 || val == 2)) {
          parsedAnswers[key] = val;
        } else if (val is num && (val.toInt() == 0 || val.toInt() == 1 || val.toInt() == 2)) {
          parsedAnswers[key] = val.toInt();
        } else {
          parsedAnswers[key] = null;
        }
      }
    }
    return MuhasabaEntry(
      date: json['date'] as String,
      answers: parsedAnswers,
    );
  }
}
