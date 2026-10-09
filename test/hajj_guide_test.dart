import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/hajj/data/hajj_repository.dart';
import 'package:muslim_ultra/features/hajj/domain/models/hajj_step.dart';
import 'package:muslim_ultra/features/hajj/presentation/screens/hajj_guide_screen.dart';
import 'package:muslim_ultra/features/hajj/presentation/providers/hajj_providers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    HajjRepository.clearCacheForTesting();
  });


  late List<HajjStep> testSteps;

  setUpAll(() async {
    testSteps = await HajjRepository().getSteps();
  });

  group('Hajj & Umrah Dataset & Phase Tests', () {
    test('Bundle loads 16 steps with correct phase breakdown', () async {
      final repo = HajjRepository();
      final steps = await repo.getSteps();

      expect(steps.length, 16);

      final phases = await repo.getPhases();
      expect(phases, containsAll(['Umrah', 'Hajj', 'Checklist']));

      final umrahSteps = await repo.stepsForPhase('Umrah');
      final hajjSteps = await repo.stepsForPhase('Hajj');
      final checklistSteps = await repo.stepsForPhase('Checklist');

      expect(umrahSteps.length, 6);
      expect(hajjSteps.length, 6);
      expect(checklistSteps.length, 4);

      // Verify sequential step numbering
      for (var i = 0; i < steps.length; i++) {
        expect(steps[i].step, i + 1);
      }
    });

    test('Every Umrah and Hajj step has non-empty desc and title in EN, AR, UR', () async {
      final repo = HajjRepository();
      final steps = await repo.getSteps();

      final ritesSteps = steps.where((s) => s.phaseEn == 'Umrah' || s.phaseEn == 'Hajj');
      expect(ritesSteps.length, 12);

      for (final s in ritesSteps) {
        // Descriptions
        expect(s.descEn.trim(), isNotEmpty, reason: 'Step ${s.step} missing descEn');
        expect(s.descAr.trim(), isNotEmpty, reason: 'Step ${s.step} missing descAr');
        expect(s.descUr.trim(), isNotEmpty, reason: 'Step ${s.step} missing descUr');

        // Titles
        expect(s.titleEn.trim(), isNotEmpty, reason: 'Step ${s.step} missing titleEn');
        expect(s.titleAr.trim(), isNotEmpty, reason: 'Step ${s.step} missing titleAr');
        expect(s.titleUr.trim(), isNotEmpty, reason: 'Step ${s.step} missing titleUr');

        // If step has Arabic dua, translations or source should be well structured
        if (s.hasDua) {
          expect(s.duaAr!.trim(), isNotEmpty);
          expect(s.source, isNotNull);
        }
      }
    });

    test('Corrupt JSON throws typed HajjLoadException', () async {
      final repo = HajjRepository();
      final mockBundle = _MockAssetBundle({'assets/hajj/hajj_guide.json': '{ "invalid": 123 }'});

      expect(
        () async => repo.getSteps(bundle: mockBundle),
        throwsA(isA<HajjLoadException>()),
      );
    });

    test('Progress persistence round-trip (hajj_progress_v1)', () async {
      final repo = HajjRepository();

      expect(await repo.getCompletedSteps(), isEmpty);
      expect(await repo.isStepCompleted(1), isFalse);

      // Mark step 1 completed
      final isNowDone = await repo.toggleStepCompleted(1);
      expect(isNowDone, isTrue);
      expect(await repo.isStepCompleted(1), isTrue);

      // Mark step 7 completed
      await repo.toggleStepCompleted(7);
      var completed = await repo.getCompletedSteps();
      expect(completed, containsAll([1, 7]));

      // Toggle step 1 back to pending
      final isDoneAfterSecondToggle = await repo.toggleStepCompleted(1);
      expect(isDoneAfterSecondToggle, isFalse);
      expect(await repo.isStepCompleted(1), isFalse);

      completed = await repo.getCompletedSteps();
      expect(completed, containsAll([7]));
      expect(completed, isNot(contains(1)));
    });
  });

  group('Hajj Guide UI & Widget Flow Tests', () {
    testWidgets('Phase tabs switch steps properly', (tester) async {
      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              hajjStepsProvider.overrideWith((ref) async => testSteps),
              completedHajjStepsProvider.overrideWith((ref) async => <int>{}),
            ],
            child: const MaterialApp(
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en')],
              home: HajjGuideScreen(),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Initially Umrah phase is selected (first 6 steps)
        expect(find.byType(HajjGuideScreen), findsOneWidget);
        expect(find.byKey(const ValueKey('hajj_tab_0')), findsOneWidget);
        expect(find.byKey(const ValueKey('hajj_tab_1')), findsOneWidget);
        expect(find.byKey(const ValueKey('hajj_tab_2')), findsOneWidget);

        // Step 1 card should be visible
        expect(find.byKey(const ValueKey('hajj_step_card_1')), findsOneWidget);

        // Tap Hajj tab (index 1)
        await tester.tap(find.byKey(const ValueKey('hajj_tab_1')));
        await tester.pumpAndSettle();

        // Step 7 card (first step of Hajj) should be visible
        expect(find.byKey(const ValueKey('hajj_step_card_7')), findsOneWidget);

        // Tap Checklist tab (index 2)
        await tester.tap(find.byKey(const ValueKey('hajj_tab_2')));
        await tester.pumpAndSettle();

        // Step 13 card (first step of Checklist) should be visible
        expect(find.byKey(const ValueKey('hajj_step_card_13')), findsOneWidget);
      });
    });

    testWidgets('360px RTL smoke test', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.runAsync(() async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              hajjStepsProvider.overrideWith((ref) async => testSteps),
              completedHajjStepsProvider.overrideWith((ref) async => <int>{}),
            ],
            child: const MaterialApp(
              locale: Locale('ar'),
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [Locale('en'), Locale('ar'), Locale('ur')],
              home: Directionality(
                textDirection: TextDirection.rtl,
                child: HajjGuideScreen(),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.byType(HajjGuideScreen), findsOneWidget);
      });
    });
  });
}

class _MockAssetBundle extends Fake implements AssetBundle {
  final Map<String, String> assets;
  _MockAssetBundle(this.assets);

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (assets.containsKey(key)) {
      return assets[key]!;
    }
    throw FlutterError('Unable to load asset: $key');
  }
}
