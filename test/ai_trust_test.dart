import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/ai/domain/models/chat_message.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_feedback_service.dart';
import 'package:muslim_ultra/features/ai/presentation/providers/ai_providers.dart';
import 'package:muslim_ultra/features/ai/presentation/screens/ai_deen_screen.dart';

late AppLocalizations testEnL10n;
late AppLocalizations testArL10n;
late AppLocalizations testUrL10n;

class TestLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  final Locale locale;
  const TestLocalizationsDelegate(this.locale);

  @override
  bool isSupported(Locale l) => true;

  @override
  Future<AppLocalizations> load(Locale l) {
    if (locale.languageCode == 'ar') return SynchronousFuture(testArL10n);
    if (locale.languageCode == 'ur') return SynchronousFuture(testUrL10n);
    return SynchronousFuture(testEnL10n);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    testEnL10n = AppLocalizations(const Locale('en'));
    await testEnL10n.load();
    testArL10n = AppLocalizations(const Locale('ar'));
    await testArL10n.load();
    testUrL10n = AppLocalizations(const Locale('ur'));
    await testUrL10n.load();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Part A: Muslim AI Trust Upgrades Unit Tests', () {
    test('AiFeedbackService sends feedback report to Supabase', () async {
      var requestMade = false;
      String? sentBody;

      final mockClient = MockClient((request) async {
        if (request.url.path.contains('ai_feedback_reports')) {
          requestMade = true;
          sentBody = request.body;
          return http.Response('', 201);
        }
        return http.Response('Not found', 404);
      });

      final service = AiFeedbackService(
        supabaseUrl: 'https://mock.supabase.co',
        anonKey: 'mock_anon_key_123',
        client: mockClient,
      );

      final success = await service.sendFeedback(
        queryHash: 'test_hash_1',
        feedbackType: 'religious_error',
        comment: 'Incorrect verse citation for prayer timings.',
        appVersion: 'v2.7',
      );

      expect(success, isTrue);
      expect(requestMade, isTrue);
      final json = jsonDecode(sentBody!) as Map<String, dynamic>;
      expect(json['feedback_type'], 'religious_error');
      expect(json['comment'], 'Incorrect verse citation for prayer timings.');
      expect(json['app_version'], 'v2.7');
    });

    test('AiFeedbackService handles network failure gracefully without crashing', () async {
      final mockClient = MockClient((request) async {
        throw Exception('Connection failed');
      });

      final service = AiFeedbackService(
        supabaseUrl: 'https://mock.supabase.co',
        anonKey: 'mock_anon_key_123',
        client: mockClient,
      );

      final success = await service.sendFeedback(
        feedbackType: 'helpful',
      );

      expect(success, isFalse);
    });
  });

  group('Part A: Muslim AI Trust UI Widget Tests', () {
    testWidgets('Displays source-support indicator (cited vs uncited) and feedback chips',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 800));

      final citedMsg = ChatMessage(
        id: 'msg_cited',
        text: 'Prayer is the second pillar of Islam.',
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
        sources: const ['Sahih al-Bukhari 8', 'Sahih Muslim 16'],
      );

      final uncitedMsg = ChatMessage(
        id: 'msg_uncited',
        text: 'General reflection on patience.',
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
        sources: const [],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatMessagesProvider.overrideWith((ref) => _StaticChatNotifier(ref, [citedMsg, uncitedMsg])),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('en')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AiDeenScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check cited message indicator: "Supported by 2 verified source(s)"
      expect(find.text('Supported by 2 verified source(s)'), findsOneWidget);

      // Check uncited message indicator: "No verified source found — consider asking a scholar"
      expect(find.text('No verified source found — consider asking a scholar'), findsOneWidget);

      // Check feedback chips
      expect(find.byKey(const Key('feedback_helpful_msg_cited')), findsOneWidget);
      expect(find.byKey(const Key('feedback_wrong_citation_msg_cited')), findsOneWidget);
      expect(find.byKey(const Key('feedback_report_error_msg_cited')), findsOneWidget);

      // Tap "Report religious error" chip
      await tester.tap(find.byKey(const Key('feedback_report_error_msg_cited')));
      await tester.pumpAndSettle();

      // Dialog must open
      expect(find.byKey(const Key('report_comment_field')), findsOneWidget);
      expect(find.byKey(const Key('submit_report_button')), findsOneWidget);

      // Enter comment and submit
      await tester.enterText(find.byKey(const Key('report_comment_field')), 'Needs verification from mufti');
      await tester.tap(find.byKey(const Key('submit_report_button')));
      await tester.pumpAndSettle();

      // Dialog closes
      expect(find.byKey(const Key('report_comment_field')), findsNothing);
    });

    testWidgets('360px RTL smoke test in Arabic without overflow', (tester) async {
      await tester.binding.setSurfaceSize(const Size(360, 640));

      final msg = ChatMessage(
        id: 'msg_ar',
        text: 'الصلاة هي الركن الثاني من أركان الإسلام.',
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
        sources: const ['صحيح البخاري 8'],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            aiChatMessagesProvider.overrideWith((ref) => _StaticChatNotifier(ref, [msg])),
          ],
          child: MaterialApp(
            locale: const Locale('ar'),
            localizationsDelegates: const [
              TestLocalizationsDelegate(Locale('ar')),
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: const AiDeenScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('source_support_indicator')), findsOneWidget);
    });
  });
}

class _StaticChatNotifier extends AiChatNotifier {
  _StaticChatNotifier(super.ref, List<ChatMessage> initial) {
    state = initial;
  }
}
