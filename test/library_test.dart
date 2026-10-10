import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/library/domain/models/book.dart';
import 'package:muslim_ultra/features/library/domain/models/book_progress.dart';
import 'package:muslim_ultra/features/library/data/library_repository.dart';
import 'package:muslim_ultra/features/library/presentation/providers/library_providers.dart';
import 'package:muslim_ultra/features/library/presentation/screens/library_screen.dart';

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

  group('Bundled books.json Verification & Model Tests', () {
    test('Bundled assets/books/books.json parses and contains required fields and HTTPS URLs',
        () async {
      final jsonStr = await rootBundle.loadString('assets/books/books.json');
      final dynamic decoded = jsonDecode(jsonStr);

      expect(decoded, isA<Map<String, dynamic>>());
      final booksList = decoded['books'] as List;
      expect(booksList, isNotEmpty);

      for (final raw in booksList) {
        final book = Book.fromJson(raw as Map<String, dynamic>);
        expect(book.id, isNotEmpty);
        expect(book.titleEn, isNotEmpty);
        expect(book.titleAr, isNotEmpty);
        expect(book.titleUr, isNotEmpty);
        expect(book.sizeMb, greaterThan(0));
        expect(book.url.startsWith('https://'), isTrue);
        expect(book.descEn, isNotEmpty);
        expect(book.descAr, isNotEmpty);
        expect(book.descUr, isNotEmpty);
      }
    });

    test('Book domain model localized getters work properly', () {
      const book = Book(
        id: 'test-1',
        titleEn: 'English Title',
        titleAr: 'العنوان العربي',
        titleUr: 'اردو عنوان',
        lang: 'en',
        sizeMb: 15.5,
        url: 'https://example.com/book.pdf',
        descEn: 'English Desc',
        descAr: 'وصف عربي',
        descUr: 'اردو تفصیل',
      );

      expect(book.localizedTitle('en'), 'English Title');
      expect(book.localizedTitle('ar'), 'العنوان العربي');
      expect(book.localizedTitle('ur'), 'اردو عنوان');
      expect(book.isLargeFile, isTrue); // 15.5 > 10.0
    });
  });

  group('LibraryRepository & Progress Persistence Tests', () {
    test('Reading progress saves and loads round-trip correctly', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final repo = LibraryRepository(prefs: prefs);

      final progress1 = BookProgress(
        bookId: 'hisn-ul-muslim',
        lastPage: 42,
        totalPages: 120,
        lastReadAt: DateTime.now(),
      );

      await repo.saveProgress(progress1);

      final loaded = await repo.getBookProgress('hisn-ul-muslim');
      expect(loaded, isNotNull);
      expect(loaded!.bookId, 'hisn-ul-muslim');
      expect(loaded.lastPage, 42);
      expect(loaded.totalPages, 120);
    });

    test('getBooksCatalog falls back to bundled asset if remote fails', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        return http.Response('Not Found', 404);
      });

      final repo = LibraryRepository(client: mockClient, prefs: prefs);
      final books = await repo.getBooksCatalog();

      expect(books, isNotEmpty);
      expect(books.any((b) => b.id == 'hisn-ul-muslim'), isTrue);
    });
  });

  Widget createTestWidget({
    required Widget child,
    Locale locale = const Locale('en'),
    List<dynamic> overrides = const [],
  }) {
    return ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        locale: locale,
        supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
        localizationsDelegates: [
          TestLocalizationsDelegate(locale),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: child,
      ),
    );
  }

  group('LibraryScreen UI & Widget Flow Tests', () {
    final testBooks = [
      const Book(
        id: 'hisn-ul-muslim',
        titleEn: 'Fortress of the Muslim',
        titleAr: 'حصن المسلم',
        titleUr: 'حصن المسلم',
        lang: 'en',
        sizeMb: 0.9,
        url: 'https://archive.org/download/sample1.pdf',
        descEn: 'The famous dua collection of Sa\'id al-Qahtani.',
        descAr: 'مجموعة الأدعية المشهورة.',
        descUr: 'مشہور دعاؤں کی کتاب۔',
      ),
      const Book(
        id: 'riyad-us-saliheen-1',
        titleEn: 'Riyad-us-Saliheen Vol. 1',
        titleAr: 'رياض الصالحين ج١',
        titleUr: 'ریاض الصالحین جلد ۱',
        lang: 'en',
        sizeMb: 34.0,
        url: 'https://archive.org/download/sample2.pdf',
        descEn: 'Imam Nawawi\'s classic hadith collection.',
        descAr: 'مجموعة الإمام النووي المشهورة.',
        descUr: 'امام نووی کی مشہور کتاب۔',
      ),
    ];

    testWidgets('Renders book list, size chips, and download buttons', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            booksCatalogProvider.overrideWith((ref) => Future.value(testBooks)),
            downloadedBooksProvider.overrideWith((ref) => Future.value({'hisn-ul-muslim'})),
            libraryProgressMapProvider.overrideWith(
              (ref) => Future.value({
                'hisn-ul-muslim': BookProgress(
                  bookId: 'hisn-ul-muslim',
                  lastPage: 15,
                  totalPages: 90,
                  lastReadAt: DateTime.now(),
                ),
              }),
            ),
          ],
          child: const LibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Islamic Book Library'), findsOneWidget);
      expect(find.text('Fortress of the Muslim'), findsOneWidget);
      expect(find.text('Riyad-us-Saliheen Vol. 1'), findsOneWidget);
      expect(find.text('0.9 MB'), findsOneWidget);
      expect(find.text('34.0 MB'), findsOneWidget);
      expect(find.text('Read Book'), findsOneWidget); // Downloaded one
      expect(find.text('Download PDF'), findsOneWidget); // Not downloaded one
      expect(find.text('Last read: Page 15'), findsOneWidget);
    });

    testWidgets('Large file (>10MB) triggers Wi-Fi warning dialog on tap', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            booksCatalogProvider.overrideWith((ref) => Future.value(testBooks)),
            downloadedBooksProvider.overrideWith((ref) => Future.value({})),
          ],
          child: const LibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap download on 34 MB Riyad-us-Saliheen
      final downloadButtons = find.text('Download PDF');
      expect(downloadButtons, findsNWidgets(2));
      await tester.tap(downloadButtons.last);
      await tester.pumpAndSettle();

      expect(find.text('Large File Notice'), findsOneWidget);
      expect(find.text('Download Anyway'), findsOneWidget);
    });

    testWidgets('360x640 responsive smoke test in Arabic (RTL) with 0 overflow errors',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          overrides: [
            booksCatalogProvider.overrideWith((ref) => Future.value(testBooks)),
          ],
          child: const LibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('مكتبة الكتب الإسلامية'), findsOneWidget);
      expect(find.text('حصن المسلم'), findsOneWidget);
      expect(find.text('رياض الصالحين ج١'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('360x640 responsive smoke test in Urdu (RTL) with 0 overflow errors',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ur'),
          overrides: [
            booksCatalogProvider.overrideWith((ref) => Future.value(testBooks)),
          ],
          child: const LibraryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('اسلامی کتب خانہ'), findsOneWidget);
      expect(find.text('حصن المسلم'), findsOneWidget);
      expect(find.text('ریاض الصالحین جلد ۱'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
