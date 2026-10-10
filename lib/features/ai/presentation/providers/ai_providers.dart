import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/config/app_config.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_feedback_service.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_gateway_service.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_storage_service.dart';
import 'package:muslim_ultra/features/ai/data/services/on_device_intent_service.dart';
import 'package:muslim_ultra/features/ai/domain/models/ai_chat_session.dart';
import 'package:muslim_ultra/features/ai/domain/models/chat_message.dart';
import 'package:muslim_ultra/features/ai/domain/models/scholar_keywords.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:share_plus/share_plus.dart';

final aiGatewayServiceProvider = Provider<AiGatewayService>((ref) {
  return AiGatewayService(
    supabaseUrl: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
});

final aiFeedbackServiceProvider = Provider<AiFeedbackService>((ref) {
  return AiFeedbackService(
    supabaseUrl: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );
});

final aiIsLoadingProvider = StateProvider<bool>((ref) => false);

final aiExplainMoreProvider = StateProvider<bool>((ref) => false);

final remainingDailyTurnsProvider =
    StateNotifierProvider<DailyTurnsNotifier, int>((ref) {
  return DailyTurnsNotifier();
});

class DailyTurnsNotifier extends StateNotifier<int> {
  DailyTurnsNotifier() : super(20) {
    _init();
  }

  Future<void> _init() async {
    final remaining = await AiStorageService.getRemainingTurns();
    state = remaining;
  }

  Future<void> decrement() async {
    final remaining = await AiStorageService.incrementTurnCount();
    state = remaining;
  }

  void setRemaining(int count) {
    state = count;
  }
}

/// Manages all local chat sessions
final aiChatSessionsProvider =
    StateNotifierProvider<AiChatSessionsNotifier, List<AiChatSession>>((ref) {
  return AiChatSessionsNotifier(ref);
});

final activeSessionIdProvider = StateProvider<String?>((ref) => null);

class AiChatSessionsNotifier extends StateNotifier<List<AiChatSession>> {
  final Ref ref;

  AiChatSessionsNotifier(this.ref, [List<AiChatSession>? initial])
      : super(initial ?? []) {
    if (initial == null) {
      loadSessions();
    }
  }

  Future<void> loadSessions() async {
    final loaded = await AiStorageService.loadChatSessions();
    if (loaded.isEmpty) {
      final initial = _createEmptySession();
      state = [initial];
      ref.read(activeSessionIdProvider.notifier).state = initial.id;
      await AiStorageService.saveChatSessions(state);
    } else {
      state = loaded;
      ref.read(activeSessionIdProvider.notifier).state = loaded.first.id;
    }
  }

  AiChatSession _createEmptySession({bool isPrivate = false}) {
    final now = DateTime.now();
    return AiChatSession(
      id: 'session_${now.millisecondsSinceEpoch}',
      title: 'New Chat',
      createdAt: now,
      updatedAt: now,
      isPrivate: isPrivate,
      messages: [],
    );
  }

  AiChatSession? get activeSession {
    final activeId = ref.read(activeSessionIdProvider);
    if (state.isEmpty) return null;
    return state.firstWhere(
      (s) => s.id == activeId,
      orElse: () => state.first,
    );
  }

  Future<String> startNewChat({bool isPrivate = false}) async {
    final newSession = _createEmptySession(isPrivate: isPrivate);
    state = [newSession, ...state];
    ref.read(activeSessionIdProvider.notifier).state = newSession.id;
    await AiStorageService.saveChatSessions(state);
    return newSession.id;
  }

  void selectSession(String sessionId) {
    ref.read(activeSessionIdProvider.notifier).state = sessionId;
  }

  Future<void> renameSession(String sessionId, String newTitle) async {
    final trimmed = newTitle.trim();
    if (trimmed.isEmpty) return;

    state = state.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(title: trimmed, updatedAt: DateTime.now());
      }
      return s;
    }).toList();

    await AiStorageService.saveChatSessions(state);
  }

  Future<void> togglePrivateMode(String sessionId) async {
    state = state.map((s) {
      if (s.id == sessionId) {
        return s.copyWith(
          isPrivate: !s.isPrivate,
          updatedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    await AiStorageService.saveChatSessions(state);
  }

  Future<void> deleteSession(String sessionId) async {
    final remaining = state.where((s) => s.id != sessionId).toList();
    if (remaining.isEmpty) {
      final fresh = _createEmptySession();
      state = [fresh];
      ref.read(activeSessionIdProvider.notifier).state = fresh.id;
    } else {
      state = remaining;
      if (ref.read(activeSessionIdProvider) == sessionId) {
        ref.read(activeSessionIdProvider.notifier).state = remaining.first.id;
      }
    }
    await AiStorageService.saveChatSessions(state);
  }

  Future<void> clearAll() async {
    await AiStorageService.clearChatHistory();
    final fresh = _createEmptySession();
    state = [fresh];
    ref.read(activeSessionIdProvider.notifier).state = fresh.id;
  }

  Future<void> exportSession(String sessionId) async {
    final session = state.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => state.first,
    );

    final buffer = StringBuffer();
    buffer.writeln('Muslim AI Chat: ${session.title}');
    buffer.writeln('Date: ${session.createdAt.toLocal().toString().split('.')[0]}');
    buffer.writeln('----------------------------------------\n');

    for (final msg in session.messages) {
      final senderName = msg.sender == ChatSender.user ? 'You' : 'Muslim AI';
      buffer.writeln('[$senderName]');
      buffer.writeln(msg.text);
      if (msg.sources.isNotEmpty) {
        buffer.writeln('Sources: ${msg.sources.join(', ')}');
      }
      buffer.writeln();
    }

    await Share.share(
      buffer.toString().trim(),
      subject: 'Muslim AI Chat - ${session.title}',
    );
  }

  Future<void> updateActiveSessionMessages(List<ChatMessage> messages) async {
    final activeId = ref.read(activeSessionIdProvider);
    if (activeId == null) return;

    state = state.map((s) {
      if (s.id == activeId) {
        String title = s.title;
        if (title == 'New Chat' && messages.isNotEmpty) {
          final firstUser = messages.firstWhere(
            (m) => m.sender == ChatSender.user,
            orElse: () => messages.first,
          );
          title = firstUser.text.length > 35
              ? '${firstUser.text.substring(0, 35)}...'
              : firstUser.text;
        }
        return s.copyWith(
          title: title,
          messages: messages,
          updatedAt: DateTime.now(),
        );
      }
      return s;
    }).toList();

    await AiStorageService.saveChatSessions(state);
    await AiStorageService.saveChatHistory(messages);
  }
}

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;

  AiChatNotifier(this.ref, [List<ChatMessage>? initial])
      : super(initial ?? []) {
    if (initial == null) {
      _init();
    }
  }

  void _init() {
    final sessionsNotifier = ref.read(aiChatSessionsProvider.notifier);
    final active = sessionsNotifier.activeSession;
    if (active != null) {
      state = active.messages;
    }
  }

  Future<void> clearHistory() async {
    final sessionsNotifier = ref.read(aiChatSessionsProvider.notifier);
    final activeId = ref.read(activeSessionIdProvider);
    if (activeId != null) {
      await sessionsNotifier.deleteSession(activeId);
      final active = sessionsNotifier.activeSession;
      state = active?.messages ?? [];
    } else {
      await sessionsNotifier.clearAll();
      state = [];
    }
  }

  void reloadFromSession() {
    final sessionsNotifier = ref.read(aiChatSessionsProvider.notifier);
    final active = sessionsNotifier.activeSession;
    state = active?.messages ?? [];
  }

  Future<void> sendMessage(String text, {String language = 'en'}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final isScholarTopic = ScholarKeywords.matches(trimmed);

    final userMsg = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg];
    ref.read(aiIsLoadingProvider.notifier).state = true;

    try {
      final sessionsNotifier = ref.read(aiChatSessionsProvider.notifier);
      final activeSession = sessionsNotifier.activeSession;
      final isPrivate = activeSession?.isPrivate ?? false;

      // 1. Check On-Device Intent First (Prayer, Qibla, Hijri Date)
      final prayerSchedule = ref.read(prayerScheduleProvider);
      final hijriDate = ref.read(hijriDateProvider);
      final qiblaData = ref.read(qiblaDataProvider);

      final intentResult = OnDeviceIntentService.evaluateQuery(
        query: trimmed,
        prayerSchedule: prayerSchedule,
        hijriDate: hijriDate,
        qiblaData: qiblaData,
        language: language,
      );

      if (intentResult.matched) {
        // Zero LLM cost, answered directly on-device
        final assistantMsg = ChatMessage(
          id: 'ast_${DateTime.now().millisecondsSinceEpoch}',
          text: intentResult.answer,
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
          sources: intentResult.sources,
          isFromDeviceIntent: true,
          isCached: false,
          isShortAnswer: true,
          matchedScholarReferral: isScholarTopic,
          referralQuestionText: isScholarTopic ? trimmed : null,
        );

        state = [...state, assistantMsg];
        await sessionsNotifier.updateActiveSessionMessages(state);
        return;
      }

      // 2. Query AI Gateway with Grounded RAG & Rate Limits
      final explainMore = ref.read(aiExplainMoreProvider);
      final gateway = ref.read(aiGatewayServiceProvider);

      // Decrement daily turn count for cloud/RAG inquiries
      await ref.read(remainingDailyTurnsProvider.notifier).decrement();

      final response = await gateway.sendQuery(
        query: trimmed,
        language: language,
        explainMore: explainMore,
        noCache: isPrivate,
      );

      final assistantMsg = ChatMessage(
        id: 'ast_${DateTime.now().millisecondsSinceEpoch}',
        text: response.answer,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
        sources: response.citations,
        isFromDeviceIntent: false,
        isCached: response.isCached,
        isShortAnswer: response.isShortAnswer,
        scholarFooter: response.scholarFooter,
        matchedScholarReferral: isScholarTopic,
        referralQuestionText: isScholarTopic ? trimmed : null,
      );

      state = [...state, assistantMsg];
      await sessionsNotifier.updateActiveSessionMessages(state);

      if (response.remainingTurns < 20) {
        ref
            .read(remainingDailyTurnsProvider.notifier)
            .setRemaining(response.remainingTurns);
      }
    } finally {
      ref.read(aiIsLoadingProvider.notifier).state = false;
    }
  }
}

final aiChatMessagesProvider =
    StateNotifierProvider<AiChatNotifier, List<ChatMessage>>((ref) {
  // Listen to session changes and reload
  ref.listen(activeSessionIdProvider, (prev, next) {
    // If active session ID changes, refresh messages
  });
  return AiChatNotifier(ref);
});
