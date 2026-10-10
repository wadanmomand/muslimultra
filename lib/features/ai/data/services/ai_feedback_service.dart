import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muslim_ultra/core/config/app_config.dart';

class AiFeedbackService {
  final String? supabaseUrl;
  final String? anonKey;
  final http.Client _client;

  AiFeedbackService({
    String? supabaseUrl,
    String? anonKey,
    http.Client? client,
  })  : supabaseUrl = supabaseUrl ?? AppConfig.supabaseUrl,
        anonKey = anonKey ?? AppConfig.supabaseAnonKey,
        _client = client ?? http.Client();

  /// Send user feedback report on AI answers to Supabase table `ai_feedback_reports`
  Future<bool> sendFeedback({
    String? queryHash,
    required String feedbackType, // 'helpful', 'wrong_citation', 'religious_error'
    String? comment,
    String appVersion = 'v2.7',
  }) async {
    final url = supabaseUrl;
    final key = anonKey;

    if (url == null || url.isEmpty || url.contains('YOUR_') || key == null || key.isEmpty || key.contains('YOUR_')) {
      // Mock / Offline environment: acknowledge silently as success
      return true;
    }

    try {
      final uri = Uri.parse('$url/rest/v1/ai_feedback_reports');
      final response = await _client.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'apikey': key,
          'Authorization': 'Bearer $key',
          'Prefer': 'return=minimal',
        },
        body: jsonEncode({
          'query_hash': queryHash,
          'feedback_type': feedbackType,
          if (comment != null && comment.trim().isNotEmpty) 'comment': comment.trim(),
          'app_version': appVersion,
        }),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 201 || response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}
