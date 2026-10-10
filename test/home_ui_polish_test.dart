import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/main.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/header_bar.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/prayer_card.dart';
import 'package:muslim_ultra/features/home/presentation/widgets/quick_actions.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'onboarding_done_v1': true});
  });

  testWidgets('Test v1.1 Home Screen UI Polish components', (WidgetTester tester) async {
    final container = ProviderContainer(
      overrides: [
        countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MuslimUltraApp(),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Task 1: Compact Header Bar & Hijri Date & Bell
    expect(find.byType(HomeHeaderBar), findsOneWidget);
    final bellButton = find.byIcon(Icons.notifications_outlined);
    expect(bellButton, findsOneWidget);

    // Open notification bottom sheet
    await tester.tap(bellButton);
    await tester.pumpAndSettle();

    expect(find.text('No new notifications'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // Close bottom sheet
    final closeButton = find.byIcon(Icons.close);
    expect(closeButton, findsOneWidget);
    await tester.tap(closeButton);
    await tester.pumpAndSettle();

    // 2. Task 2: Hero Prayer Card
    expect(find.byType(HomePrayerCard), findsOneWidget);
    expect(find.byIcon(Icons.timer_outlined), findsOneWidget);
    expect(find.text('NEXT PRAYER'), findsOneWidget);

    // 3. Task 3: Horizontal Features Strip
    expect(find.byType(HomeQuickActions), findsOneWidget);

    // Tap Qibla shortcut
    final qiblaIcon = find.byIcon(Icons.explore_rounded);
    expect(qiblaIcon, findsOneWidget);
    await tester.tap(qiblaIcon);
    await tester.pumpAndSettle();

    // Verify navigated to Prayer tab in Qibla mode
    expect(container.read(bottomNavIndexProvider), 1);
    expect(container.read(prayerTabModeProvider), PrayerTabMode.qibla);

    // Switch back to Home tab
    container.read(bottomNavIndexProvider.notifier).state = 0;
    await tester.pumpAndSettle();

    // Tap Quran shortcut
    final quranIcon = find.byIcon(Icons.menu_book_rounded);
    expect(quranIcon, findsOneWidget);
    await tester.tap(quranIcon);
    await tester.pumpAndSettle();
    expect(container.read(bottomNavIndexProvider), 2);
  });

  testWidgets('Test 360x640 screen width has zero overflow errors in EN, AR, and UR',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    final container = ProviderContainer(
      overrides: [
        countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
      ],
    );
    addTearDown(container.dispose);

    // 1. English
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MuslimUltraApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // 2. Arabic (RTL)
    container.read(localeProvider.notifier).setLanguage('ar');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('مسلم ألترا'), findsOneWidget);

    // 3. Urdu (RTL)
    container.read(localeProvider.notifier).setLanguage('ur');
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('مسلم الٹرا'), findsOneWidget);
  });
}
