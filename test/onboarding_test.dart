import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/onboarding/data/onboarding_storage_service.dart';
import 'package:muslim_ultra/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

late AppLocalizations testEnL10n;
late AppLocalizations testArL10n;
late AppLocalizations testUrL10n;

class TestLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const TestLocalizationsDelegate();

  @override
  bool isSupported(Locale l) => true;

  @override
  Future<AppLocalizations> load(Locale l) {
    if (l.languageCode == 'ar') return SynchronousFuture(testArL10n);
    if (l.languageCode == 'ur') return SynchronousFuture(testUrL10n);
    return SynchronousFuture(testEnL10n);
  }

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => true;
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

  group('Part C: Onboarding Storage & Legacy Skip Logic', () {
    test('Fresh install with empty prefs returns false', () async {
      SharedPreferences.setMockInitialValues({});
      final completed = await OnboardingStorageService.isOnboardingCompleted();
      expect(completed, isFalse);
    });

    test('Existing user with legacy data silently marks onboarding as done and returns true', () async {
      SharedPreferences.setMockInitialValues({
        'mu_tasbih_selected_dhikr': 'alhamdulillah',
        'mu_prayer_fajr_completed': true,
      });

      final completed = await OnboardingStorageService.isOnboardingCompleted();
      expect(completed, isTrue);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingStorageService.keyOnboardingDone), isTrue);
    });

    test('Completed onboarding persists flag and learning goal', () async {
      SharedPreferences.setMockInitialValues({});
      await OnboardingStorageService.completeOnboarding(learningGoal: 'memorize');

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingStorageService.keyOnboardingDone), isTrue);
      expect(prefs.getString(OnboardingStorageService.keyLearningGoal), 'memorize');

      final goal = await OnboardingStorageService.getLearningGoal();
      expect(goal, 'memorize');
    });
  });

  group('Part C: Onboarding Flow Widget Tests', () {
    Widget buildTestApp({
      Locale locale = const Locale('en'),
      List<Override> overrides = const [],
    }) {
      return ProviderScope(
        overrides: overrides,
        child: Consumer(
          builder: (context, ref, _) {
            final activeLocale = ref.watch(localeProvider);
            return MaterialApp(
              locale: activeLocale,
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: const [
                TestLocalizationsDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: const OnboardingScreen(),
            );
          },
        ),
      );
    }

    testWidgets('3-step onboarding flow navigation and goal selection', (tester) async {
      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(buildTestApp());
      await tester.pumpAndSettle();

      // Step 1: Language screen
      expect(find.text('Choose Language'), findsOneWidget);
      expect(find.byKey(const Key('lang_option_en')), findsOneWidget);
      expect(find.byKey(const Key('lang_option_ar')), findsOneWidget);
      expect(find.byKey(const Key('lang_option_ur')), findsOneWidget);

      // Select Arabic
      await tester.tap(find.byKey(const Key('lang_option_ar')));
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.byKey(const Key('language_continue_button')));
      await tester.pumpAndSettle();

      // Step 2: Location screen (in Arabic)
      expect(find.text('أوقات الصلاة الدقيقة'), findsOneWidget);
      expect(find.byKey(const Key('location_enable_button')), findsOneWidget);
      expect(find.byKey(const Key('location_skip_button')), findsOneWidget);

      // Tap Skip for Now
      await tester.tap(find.byKey(const Key('location_skip_button')));
      await tester.pumpAndSettle();

      // Step 3: Goal selection
      expect(find.text('ما هو هدفك الأساسي؟'), findsOneWidget);
      expect(find.byKey(const Key('goal_option_understand_quran')), findsOneWidget);
      expect(find.byKey(const Key('goal_option_build_habits')), findsOneWidget);
      expect(find.byKey(const Key('goal_option_memorize')), findsOneWidget);

      // Select Memorize
      await tester.tap(find.byKey(const Key('goal_option_memorize')));
      await tester.pumpAndSettle();

      // Tap Finish (Get Started / ابدأ الآن)
      await tester.tap(find.byKey(const Key('onboarding_finish_button')));
      await tester.pumpAndSettle();

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool(OnboardingStorageService.keyOnboardingDone), isTrue);
      expect(prefs.getString(OnboardingStorageService.keyLearningGoal), 'memorize');
    });

    testWidgets('Part C 360px RTL smoke test in Arabic without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      SharedPreferences.setMockInitialValues({});

      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            localeProvider.overrideWith((ref) => LocaleNotifier()..setLanguage('ar')),
          ],
        ),
      );

      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('اختر اللغة'), findsOneWidget);
    });
  });
}
