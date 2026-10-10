import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/main.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/tasbih/presentation/screens/tasbih_screen.dart';
import 'package:muslim_ultra/features/tasbih/presentation/providers/tasbih_providers.dart';
import 'package:muslim_ultra/features/tasbih/presentation/widgets/tasbih_progress_ring.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/quick_actions.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'onboarding_done_v1': true});
  });

  testWidgets(
      'Test v1.1 Tasbih Counter: rendering, tap increment, target celebration, preset switching, custom target, reset, navigation, and 360px responsive RTL',
      (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      ],
    );
    addTearDown(container.dispose);

    // 1. Navigation from Home via Quick Actions
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MuslimUltraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(HomeQuickActions), findsOneWidget);
    final tasbihAction = find.text('Tasbih');
    expect(tasbihAction, findsOneWidget);

    await tester.tap(tasbihAction);
    await tester.pumpAndSettle();

    expect(find.byType(TasbihScreen), findsOneWidget);

    // 2. Initial Display and Presets
    expect(find.byType(TasbihProgressRing), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('/ 33'), findsOneWidget);
    expect(find.text('SubhanAllah'), findsWidgets);
    expect(find.text('سُبْحَانَ اللَّهِ'), findsOneWidget);
    expect(find.byIcon(Icons.restart_alt_rounded), findsOneWidget);

    // 3. Tap increments count
    final ring = find.byType(TasbihProgressRing);
    await tester.tap(ring);
    await tester.pumpAndSettle();

    expect(container.read(tasbihProvider).currentCount, 1);
    expect(find.text('1'), findsOneWidget);

    // 4. Tap to complete target (33)
    for (int i = 0; i < 32; i++) {
      await tester.tap(ring);
      await tester.pump();
    }
    await tester.pumpAndSettle();

    expect(container.read(tasbihProvider).currentCount, 33);
    expect(container.read(tasbihProvider).isCompleted, isTrue);
    expect(find.text('33'), findsOneWidget);
    expect(find.text('Target Completed!'), findsOneWidget);

    // 5. Reset button with confirmation dialog
    final resetButton = find.byIcon(Icons.restart_alt_rounded);
    await tester.ensureVisible(resetButton);
    await tester.tap(resetButton);
    await tester.pumpAndSettle();

    expect(find.text('Reset Counter?'), findsOneWidget);
    final confirmResetBtn = find.widgetWithText(ElevatedButton, 'Reset');
    await tester.tap(confirmResetBtn);
    await tester.pumpAndSettle();

    expect(container.read(tasbihProvider).currentCount, 0);
    expect(find.text('0'), findsOneWidget);

    // 6. Preset Switching (Allahu Akbar target 34)
    final allahuAkbarChip = find.text('Allahu Akbar');
    await tester.ensureVisible(allahuAkbarChip);
    await tester.tap(allahuAkbarChip);
    await tester.pumpAndSettle();

    expect(container.read(tasbihProvider).selectedPreset.id, 'allahu_akbar');
    expect(container.read(tasbihProvider).target, 34);
    expect(find.text('اللَّهُ أَكْبَرُ'), findsOneWidget);
    expect(find.text('/ 34'), findsOneWidget);

    // Preset Switching (La ilaha illa Allah target 100)
    final lailahaChip = find.text('La ilaha illa Allah');
    await tester.ensureVisible(lailahaChip);
    await tester.tap(lailahaChip);
    await tester.pumpAndSettle();

    expect(container.read(tasbihProvider).selectedPreset.id, 'la_ilaha_illa_allah');
    expect(container.read(tasbihProvider).target, 100);
    expect(find.text('لَا إِلٰهَ إِلَّا اللَّهُ'), findsOneWidget);
    expect(find.text('/ 100'), findsOneWidget);

    // 7. Custom Target Dialog
    final customTargetBtn = find.text('Custom Target');
    await tester.ensureVisible(customTargetBtn);
    await tester.tap(customTargetBtn);
    await tester.pumpAndSettle();

    expect(find.text('Set Target'), findsOneWidget);
    final chip500 = find.text('500');
    await tester.tap(chip500);
    await tester.pumpAndSettle();

    final setTargetBtn = find.text('Set Target');
    await tester.tap(setTargetBtn);
    await tester.pumpAndSettle();

    expect(container.read(tasbihProvider).target, 500);
    expect(find.text('/ 500'), findsOneWidget);

    // 8. Responsive 360x640 width & RTL verification (EN, AR, UR)
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byType(TasbihScreen), findsOneWidget);

    // Switch to Arabic (RTL)
    container.read(localeProvider.notifier).setLanguage('ar');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('المسبحة'), findsOneWidget);

    // Switch to Urdu (RTL)
    container.read(localeProvider.notifier).setLanguage('ur');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('تسبیح'), findsOneWidget);
  });
}
