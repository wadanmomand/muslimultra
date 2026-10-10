import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/core/config/app_config.dart';
import 'package:muslim_ultra/features/ai/domain/models/chat_message.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_feedback_service.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_gateway_service.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_storage_service.dart';
import 'package:muslim_ultra/features/ai/data/services/on_device_intent_service.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

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

final remainingDailyTurnsProvider = StateNotifierProvider<DailyTurnsNotifier, int>((ref) {
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

class AiChatNotifier extends StateNotifier<List<ChatMessage>> {
  final Ref ref;

  AiChatNotifier(this.ref) : super([]) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await AiStorageService.loadChatHistory();
    if (history.isNotEmpty) {
      state = history;
    }
  }

  Future<void> clearHistory() async {
    await AiStorageService.clearChatHistory();
    state = [];
  }

  Future<void> sendMessage(String text, {String language = 'en'}) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    final userMsg = ChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    state = [...state, userMsg];
    ref.read(aiIsLoadingProvider.notifier).state = true;

    try {
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
        );

        state = [...state, assistantMsg];
        await AiStorageService.saveChatHistory(state);
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
      );

      state = [...state, assistantMsg];
      await AiStorageService.saveChatHistory(state);

      if (response.remainingTurns < 20) {
        ref.read(remainingDailyTurnsProvider.notifier).setRemaining(response.remainingTurns);
      }
    } finally {
      ref.read(aiIsLoadingProvider.notifier).state = false;
    }
  }
}

final aiChatMessagesProvider =
    StateNotifierProvider<AiChatNotifier, List<ChatMessage>>((ref) {
  return AiChatNotifier(ref);
});
