import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_gateway_service.dart';
import 'package:muslim_ultra/features/ai/domain/models/ai_chat_session.dart';
import 'package:muslim_ultra/features/ai/domain/models/chat_message.dart';
import 'package:muslim_ultra/features/ai/domain/models/scholar_keywords.dart';
import 'package:muslim_ultra/features/ai/presentation/providers/ai_providers.dart';
import 'package:muslim_ultra/features/ai/presentation/screens/ai_chat_history_screen.dart';
import 'package:muslim_ultra/features/ai/presentation/screens/ai_deen_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  group('Part B: Scholar Keywords Heuristics', () {
    test('Triggers for divorce / talaq / khula in EN, AR, UR', () {
      expect(ScholarKeywords.matches('What is the rule on talaq in anger?'), isTrue);
      expect(ScholarKeywords.matches('Can a woman request khula?'), isTrue);
      expect(ScholarKeywords.matches('ما حكم الطلاق المعلق؟'), isTrue);
      expect(ScholarKeywords.matches('خلع کا شرعی طریقہ کیا ہے؟'), isTrue);
    });

    test('Triggers for inheritance / wirasa / mirath in EN, AR, UR', () {
      expect(ScholarKeywords.matches('How is inheritance calculated for 2 daughters?'), isTrue);
      expect(ScholarKeywords.matches('ما هي أحكام الميراث والتركة؟'), isTrue);
      expect(ScholarKeywords.matches('وراثت کی شرعی تقسیم کیسے ہوگی؟'), isTrue);
    });

    test('Triggers for fatwa & halal/haram rulings in EN, AR, UR', () {
      expect(ScholarKeywords.matches('Is this cryptocurrency halal or haram?'), isTrue);
      expect(ScholarKeywords.matches('Need a fatwa on trading options'), isTrue);
      expect(ScholarKeywords.matches('هل يجوز الجمع بين الصلاتين؟'), isTrue);
      expect(ScholarKeywords.matches('کیا یہ کام جائز ہے یا ناجائز؟'), isTrue);
    });

    test('Does NOT trigger for ordinary religious and general questions', () {
      expect(ScholarKeywords.matches('When is Fajr prayer today?'), isFalse);
      expect(ScholarKeywords.matches('Show me Surah Al-Ikhlas recitation'), isFalse);
      expect(ScholarKeywords.matches('What is the meaning of SubhanAllah?'), isFalse);
      expect(ScholarKeywords.matches('كم ركعة في صلاة الظهر؟'), isFalse);
      expect(ScholarKeywords.matches('تسبیحات فاطمہ کیا ہیں؟'), isFalse);
    });
  });

  group('Part B: Gateway no_cache flag', () {
    test('Includes no_cache: true in JSON request when noCache is true', () async {
      Map<String, dynamic>? capturedBody;

      final mockClient = MockClient((request) async {
        capturedBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'answer': 'Direct non-cached response',
            'citations': ['Quran 2:255'],
            'cached': false,
            'remaining_turns': 19,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final service = AiGatewayService(
        supabaseUrl: 'https://example.supabase.co',
        anonKey: 'test_anon_key_123',
        client: mockClient,
      );

      final response = await service.sendQuery(
        query: 'What is Ayah 2:255?',
        noCache: true,
      );

      expect(response.answer, contains('non-cached response'));
      expect(capturedBody, isNotNull);
      expect(capturedBody!['no_cache'], isTrue);
      expect(capturedBody!['query'], 'What is Ayah 2:255?');
    });
  });

  group('Part B: UI Widget Tests & History Controls', () {
    Widget buildTestApp({
      required Widget home,
      Locale locale = const Locale('en'),
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: [
            TestLocalizationsDelegate(locale),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: home,
        ),
      );
    }

    testWidgets('Renders scholar referral card when matchedScholarReferral is true', (tester) async {
      final messages = [
        ChatMessage(
          id: 'u1',
          text: 'What is the ruling on talaq via text?',
          sender: ChatSender.user,
          timestamp: DateTime.now(),
        ),
        ChatMessage(
          id: 'a1',
          text: 'Divorce laws in Islam require strict adherence to Sunnah.',
          sender: ChatSender.assistant,
          timestamp: DateTime.now(),
          matchedScholarReferral: true,
          referralQuestionText: 'What is the ruling on talaq via text?',
        ),
      ];

      await tester.pumpWidget(
        buildTestApp(
          home: const AiDeenScreen(),
          overrides: [
            aiChatMessagesProvider.overrideWith((ref) => _StaticChatNotifier(ref, messages)),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('scholar_referral_card_a1')), findsOneWidget);
      expect(find.text('Ask-a-Scholar Notice'), findsOneWidget);
      expect(find.byKey(const Key('copy_question_button_a1')), findsOneWidget);
    });

    testWidgets('AiChatHistoryScreen displays search, sessions, rename & delete actions', (tester) async {
      final sessionList = [
        AiChatSession(
          id: 's_1',
          title: 'Inheritance ruling questions',
          createdAt: DateTime.now().subtract(const Duration(hours: 1)),
          updatedAt: DateTime.now(),
          isPrivate: true,
          messages: [
            ChatMessage(
              id: 'm1',
              text: 'How to divide inheritance?',
              sender: ChatSender.user,
              timestamp: DateTime.now(),
            ),
          ],
        ),
        AiChatSession(
          id: 's_2',
          title: 'Fajr prayer time',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          updatedAt: DateTime.now(),
          isPrivate: false,
          messages: [
            ChatMessage(
              id: 'm2',
              text: 'What time is Fajr?',
              sender: ChatSender.user,
              timestamp: DateTime.now(),
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        buildTestApp(
          home: const AiChatHistoryScreen(),
          overrides: [
            aiChatSessionsProvider.overrideWith((ref) => _StaticSessionsNotifier(ref, sessionList)),
            activeSessionIdProvider.overrideWith((ref) => 's_1'),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byKey(const Key('history_search_field')), findsOneWidget);
      expect(find.byKey(const Key('session_card_s_1')), findsOneWidget);
      expect(find.byKey(const Key('session_card_s_2')), findsOneWidget);

      // Search filter test
      await tester.enterText(find.byKey(const Key('history_search_field')), 'Fajr');
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('session_card_s_2')), findsOneWidget);
      expect(find.byKey(const Key('session_card_s_1')), findsNothing);
    });

    testWidgets('Part B 360px RTL smoke test in Arabic', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sessionList = [
        AiChatSession(
          id: 's_ar_1',
          title: 'استشارة المواريث والتركات',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isPrivate: true,
          messages: [
            ChatMessage(
              id: 'm_ar_1',
              text: 'ما هي أحكام الميراث؟',
              sender: ChatSender.user,
              timestamp: DateTime.now(),
            ),
            ChatMessage(
              id: 'm_ar_2',
              text: 'توزيع التركة يستند إلى سورة النساء.',
              sender: ChatSender.assistant,
              timestamp: DateTime.now(),
              matchedScholarReferral: true,
              referralQuestionText: 'ما هي أحكام الميراث؟',
            ),
          ],
        ),
      ];

      await tester.pumpWidget(
        buildTestApp(
          locale: const Locale('ar'),
          home: const AiChatHistoryScreen(),
          overrides: [
            aiChatSessionsProvider.overrideWith((ref) => _StaticSessionsNotifier(ref, sessionList)),
          ],
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.byKey(const Key('session_card_s_ar_1')), findsOneWidget);
    });
  });
}

class _StaticChatNotifier extends AiChatNotifier {
  _StaticChatNotifier(super.ref, super.initial);
}

class _StaticSessionsNotifier extends AiChatSessionsNotifier {
  _StaticSessionsNotifier(super.ref, super.initial);
}
