import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muslim_ultra/features/ai/data/corpus/starter_corpus.dart';

class AiGatewayResponse {
  final String answer;
  final List<String> citations;
  final bool isCached;
  final bool isShortAnswer;
  final int remainingTurns;
  final String? scholarFooter;
  final bool isLimitReached;
  final String? errorMessage;

  const AiGatewayResponse({
    required this.answer,
    this.citations = const [],
    this.isCached = false,
    this.isShortAnswer = true,
    this.remainingTurns = 20,
    this.scholarFooter,
    this.isLimitReached = false,
    this.errorMessage,
  });
}

class AiGatewayService {
  final String? supabaseUrl;
  final String? anonKey;
  final http.Client _client;

  static const String defaultScholarFooter =
      'Note: Deen Companion is an educational tool. For formal legal rulings (Fatawa) on personal situations, please consult a qualified Islamic scholar.';

  AiGatewayService({
    this.supabaseUrl,
    this.anonKey,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Send query to Supabase Edge Function Gateway with cost guard & RAG
  Future<AiGatewayResponse> sendQuery({
    required String query,
    String language = 'en',
    bool explainMore = false,
    String? userId,
  }) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      return const AiGatewayResponse(
        answer: 'Please enter a question.',
        errorMessage: 'Empty query',
      );
    }

    // 1. If Supabase credentials are valid, query the Edge Function
    if (supabaseUrl != null &&
        supabaseUrl!.isNotEmpty &&
        !supabaseUrl!.contains('YOUR_') &&
        anonKey != null &&
        anonKey!.isNotEmpty &&
        !anonKey!.contains('YOUR_')) {
      try {
        final uri = Uri.parse('$supabaseUrl/functions/v1/ai-gateway');
        final response = await _client.post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'apikey': anonKey!,
            'Authorization': 'Bearer $anonKey',
          },
          body: jsonEncode({
            'query': cleanQuery,
            'language': language,
            'explain_more': explainMore,
            'user_id': userId ?? 'local_user',
          }),
        ).timeout(const Duration(seconds: 12));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final answer = data['answer'] as String? ?? 'No response generated.';
          final citations = (data['citations'] as List<dynamic>?)
                  ?.map((c) => c.toString())
                  .toList() ??
              _extractCitations(answer);

          return AiGatewayResponse(
            answer: answer,
            citations: citations,
            isCached: data['cached'] as bool? ?? false,
            isShortAnswer: !explainMore,
            remainingTurns: data['remaining_turns'] as int? ?? 20,
            scholarFooter: _requiresScholarFooter(cleanQuery, answer)
                ? (data['footer'] as String? ?? defaultScholarFooter)
                : null,
          );
        } else if (response.statusCode == 429) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return AiGatewayResponse(
            answer: data['error'] as String? ??
                'Daily free cap reached (20 messages/day). Resets at midnight.',
            isLimitReached: true,
            remainingTurns: 0,
          );
        }
      } catch (_) {
        // Fallback to local starter corpus if edge function is unreachable
      }
    }

    // 2. Grounded Local Corpus Retrieval Fallback (Guaranteed 0 Hallucinations)
    return _generateFromLocalCorpus(
      query: cleanQuery,
      language: language,
      explainMore: explainMore,
    );
  }

  /// Grounded retrieval from local starter corpus
  AiGatewayResponse _generateFromLocalCorpus({
    required String query,
    required String language,
    required bool explainMore,
  }) {
    final matches = StarterCorpus.search(query);

    if (matches.isNotEmpty) {
      final best = matches.first;
      final buffer = StringBuffer();

      if (language == 'ur') {
        buffer.writeln(best.urdu);
        if (explainMore && best.arabic.isNotEmpty) {
          buffer.writeln('\nعربی متن:\n${best.arabic}');
        }
      } else if (language == 'ar') {
        buffer.writeln(best.arabic.isNotEmpty ? best.arabic : best.english);
        if (explainMore && best.english.isNotEmpty) {
          buffer.writeln('\nالترجمة الإنجليزية:\n${best.english}');
        }
      } else {
        buffer.writeln(best.english);
        if (explainMore && best.arabic.isNotEmpty) {
          buffer.writeln('\nOriginal Arabic:\n${best.arabic}');
        }
      }

      final citations = [best.reference];

      return AiGatewayResponse(
        answer: buffer.toString().trim(),
        citations: citations,
        isCached: true,
        isShortAnswer: !explainMore,
        remainingTurns: 20,
        scholarFooter: _requiresScholarFooter(query, best.english)
            ? defaultScholarFooter
            : null,
      );
    }

    // Polite grounded decline when corpus does not cover unverified queries
    String declineText;
    if (language == 'ur') {
      declineText =
          'معذرت، میں صرف مستند اسلامی مراجع (قرآن و سنت) کی روشنی میں جواب دے سکتا ہوں۔ یہ سوال ہمارے ابتدائی ڈیٹا سیٹ میں موجود نہیں ہے یا اس کی مستند روایت تصدیق طلب ہے۔';
    } else if (language == 'ar') {
      declineText =
          'عذرًا، يمكنني الإجابة فقط بالاستناد إلى المصادر الإسلامية الموثوقة والمسندة (القرآن والسنة). هذا السؤال غير متوفر في البيانات الأولية أو يتطلب تحقيقًا من أهل الاختصاص.';
    } else {
      declineText =
          'I can only provide answers grounded in verified authentic Islamic sources (Quran and established Sunnah). I do not have a verified citation for this specific query in the current starter corpus.';
    }

    return AiGatewayResponse(
      answer: declineText,
      citations: const [],
      isCached: false,
      isShortAnswer: !explainMore,
      remainingTurns: 20,
      scholarFooter: defaultScholarFooter,
    );
  }

  static List<String> _extractCitations(String text) {
    final regex = RegExp(r'\[(Quran|Sahih|Sunan|Hisn|Muwatta|Musnad)[^\]]+\]');
    final matches = regex.allMatches(text);
    return matches.map((m) => m.group(0)!.replaceAll(RegExp(r'[\[\]]'), '')).toSet().toList();
  }

  static bool _requiresScholarFooter(String query, String answer) {
    final lower = '$query $answer'.toLowerCase();
    return lower.contains('wudu') ||
        lower.contains('salah') ||
        lower.contains('prayer') ||
        lower.contains('fiqh') ||
        lower.contains('madhab') ||
        lower.contains('ruling') ||
        lower.contains('halal') ||
        lower.contains('haram') ||
        lower.contains('fatwa') ||
        lower.contains('taraweeh') ||
        lower.contains('وضو') ||
        lower.contains('نماز') ||
        lower.contains('حکم');
  }
}
