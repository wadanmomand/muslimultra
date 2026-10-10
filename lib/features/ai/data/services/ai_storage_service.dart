import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/features/ai/domain/models/ai_chat_session.dart';
import 'package:muslim_ultra/features/ai/domain/models/chat_message.dart';

class AiStorageService {
  static const String _keyChatHistory = 'mu_ai_chat_history_v1';
  static const String _keyChatSessions = 'mu_ai_chat_sessions_v2';
  static const String _keyActiveSessionId = 'mu_ai_active_session_id_v2';
  static const String _keyDailyTurns = 'mu_ai_daily_turns_count_v1';
  static const String _keyTurnDate = 'mu_ai_turn_date_v1';
  static const int dailyFreeLimit = 20;

  /// Loads all chat sessions from storage with legacy migration
  static Future<List<AiChatSession>> loadChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawSessions = prefs.getString(_keyChatSessions);
      if (rawSessions != null && rawSessions.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(rawSessions) as List<dynamic>;
        return decoded
            .map((item) => AiChatSession.fromJson(item as Map<String, dynamic>))
            .toList();
      }

      // Check legacy history and migrate
      final legacy = await loadChatHistory();
      if (legacy.isNotEmpty) {
        final initialSession = AiChatSession(
          id: 'session_legacy_${DateTime.now().millisecondsSinceEpoch}',
          title: legacy.first.text.length > 30
              ? '${legacy.first.text.substring(0, 30)}...'
              : legacy.first.text,
          createdAt: legacy.first.timestamp,
          updatedAt: legacy.last.timestamp,
          messages: legacy,
        );
        final sessions = [initialSession];
        await saveChatSessions(sessions);
        return sessions;
      }

      return [];
    } catch (_) {
      return [];
    }
  }

  /// Saves chat sessions to storage
  static Future<void> saveChatSessions(List<AiChatSession> sessions) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded = jsonEncode(sessions.map((s) => s.toJson()).toList());
      await prefs.setString(_keyChatSessions, encoded);
    } catch (_) {}
  }

  /// Loads saved chat messages from local storage
  static Future<List<ChatMessage>> loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_keyChatHistory);
      if (rawJson == null || rawJson.isEmpty) return [];

      final List<dynamic> decoded = jsonDecode(rawJson) as List<dynamic>;
      return decoded
          .map((item) => ChatMessage.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Saves chat messages to local storage
  static Future<void> saveChatHistory(List<ChatMessage> messages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep last 50 messages to maintain light local footprint
      final capped =
          messages.length > 50 ? messages.sublist(messages.length - 50) : messages;
      final encoded = jsonEncode(capped.map((m) => m.toJson()).toList());
      await prefs.setString(_keyChatHistory, encoded);
    } catch (_) {}
  }

  /// Clears local chat history
  static Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyChatHistory);
    await prefs.remove(_keyChatSessions);
    await prefs.remove(_keyActiveSessionId);
  }

  /// Gets remaining turns for today (20 max)
  static Future<int> getRemainingTurns() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString(_keyTurnDate);

    if (savedDate != todayStr) {
      // New day, reset counter
      await prefs.setString(_keyTurnDate, todayStr);
      await prefs.setInt(_keyDailyTurns, 0);
      return dailyFreeLimit;
    }

    final used = prefs.getInt(_keyDailyTurns) ?? 0;
    return (dailyFreeLimit - used).clamp(0, dailyFreeLimit);
  }

  /// Increments today's turn count
  static Future<int> incrementTurnCount() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = DateTime.now().toIso8601String().split('T')[0];
    final savedDate = prefs.getString(_keyTurnDate);

    int current = 0;
    if (savedDate == todayStr) {
      current = prefs.getInt(_keyDailyTurns) ?? 0;
    } else {
      await prefs.setString(_keyTurnDate, todayStr);
    }

    final updated = current + 1;
    await prefs.setInt(_keyDailyTurns, updated);
    return (dailyFreeLimit - updated).clamp(0, dailyFreeLimit);
  }
}
