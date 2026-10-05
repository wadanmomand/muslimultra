import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:muslim_ultra/main.dart';
import 'package:muslim_ultra/core/providers/app_state_providers.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

void main() {
  testWidgets('Test localization and RTL switching', (WidgetTester tester) async {
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

    // Default locale is English
    expect(container.read(localeProvider), const Locale('en'));

    // Switch to Arabic (RTL)
    container.read(localeProvider.notifier).setLanguage('ar');
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('ar'));

    // Switch to Urdu (RTL)
    container.read(localeProvider.notifier).setLanguage('ur');
    await tester.pumpAndSettle();

    expect(container.read(localeProvider), const Locale('ur'));
  });

  testWidgets('Test theme mode toggling', (WidgetTester tester) async {
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

    // Default theme is dark
    expect(container.read(themeModeProvider), ThemeMode.dark);

    // Toggle to light theme
    container.read(themeModeProvider.notifier).toggleTheme();
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.light);

    // Toggle back to dark theme
    container.read(themeModeProvider.notifier).toggleTheme();
    await tester.pumpAndSettle();
    expect(container.read(themeModeProvider), ThemeMode.dark);
  });

  testWidgets('Test 5 navigation tabs selection & Qibla mode toggle',
      (WidgetTester tester) async {
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

    // Switch to Prayer tab (index 1)
    container.read(bottomNavIndexProvider.notifier).state = 1;
    await tester.pumpAndSettle();
    expect(container.read(bottomNavIndexProvider), 1);

    // Toggle Qibla mode inside Prayer tab
    expect(container.read(prayerTabModeProvider), PrayerTabMode.times);
    container.read(prayerTabModeProvider.notifier).state = PrayerTabMode.qibla;
    await tester.pumpAndSettle();
    expect(container.read(prayerTabModeProvider), PrayerTabMode.qibla);

    // Switch to Quran tab (index 2)
    container.read(bottomNavIndexProvider.notifier).state = 2;
    await tester.pumpAndSettle();
    expect(container.read(bottomNavIndexProvider), 2);

    // Switch to Dua tab (index 3)
    container.read(bottomNavIndexProvider.notifier).state = 3;
    await tester.pumpAndSettle();
    expect(container.read(bottomNavIndexProvider), 3);

    // Switch to Deen Companion tab (index 4)
    container.read(bottomNavIndexProvider.notifier).state = 4;
    await tester.pumpAndSettle();
    expect(container.read(bottomNavIndexProvider), 4);
  });
}
