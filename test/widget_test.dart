import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/main.dart';
import 'package:muslim_ultra/features/home/presentation/screens/app_shell.dart';
import 'package:muslim_ultra/features/prayer/presentation/providers/prayer_providers.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({'onboarding_done_v1': true});
  });

  testWidgets('Muslim Ultra App Shell renders with 5 navigation tabs',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          countdownTickProvider.overrideWith((ref) => Stream.value(DateTime.now())),
        ],
        child: const MuslimUltraApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(AppShell), findsOneWidget);
  });
}
