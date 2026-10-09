import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_program.dart';
import 'package:muslim_ultra/features/academy/domain/models/academy_teacher.dart';
import 'package:muslim_ultra/features/academy/domain/models/trial_booking_request.dart';
import 'package:muslim_ultra/features/academy/data/academy_repository.dart';
import 'package:muslim_ultra/features/academy/presentation/providers/academy_providers.dart';
import 'package:muslim_ultra/features/academy/presentation/screens/academy_home_screen.dart';
import 'package:muslim_ultra/features/academy/presentation/screens/trial_booking_screen.dart';
import 'package:muslim_ultra/features/academy/presentation/screens/program_detail_screen.dart';

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

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AcademyRepository.clearCacheForTesting();
  });

  group('Academy Domain Models Tests', () {
    test('AcademyProgram.fromJson parses live API response shape correctly', () {
      final jsonSample = {
        'id': '8872b226-2bb6-46b5-9ea3-fa3c7062f6cf',
        'title': 'Noorani Qaida for Beginners',
        'slug': 'noorani-qaida',
        'description': 'Master the basics of Arabic letters, pronunciation, and foundational rules of reading the Holy Quran.',
        'monthly_fee': '40',
        'duration': '3-6 months',
        'schedule_flexibility': 'Flexible 1-on-1',
        'is_active': true,
        'display_order': 1,
      };

      final program = AcademyProgram.fromJson(jsonSample);
      expect(program.id, '8872b226-2bb6-46b5-9ea3-fa3c7062f6cf');
      expect(program.title, 'Noorani Qaida for Beginners');
      expect(program.monthlyFee, '40');
      expect(program.duration, '3-6 months');
      expect(program.scheduleFlexibility, 'Flexible 1-on-1');
      expect(program.isActive, isTrue);
    });

    test('AcademyTeacher.fromJson parses live API response shape & initial letter', () {
      final jsonSample = {
        'id': 'teacher-uuid-1',
        'name': 'Sheikh Ahmad Al-Mansoor',
        'qualification': 'Ijazah in Hafs & Shu\'bah, Al-Azhar Graduate',
        'experience': '12+ years teaching',
        'photo_url': 'images/teachers/ahmad.jpg',
        'bio': 'Specialized in Tajweed rules and Quran recitation for all levels.',
        'is_active': true,
        'display_order': 1,
      };

      final teacher = AcademyTeacher.fromJson(jsonSample);
      expect(teacher.id, 'teacher-uuid-1');
      expect(teacher.name, 'Sheikh Ahmad Al-Mansoor');
      expect(teacher.initial, 'A');
      expect(teacher.photoUrl, 'https://muslimultra-website.vercel.app/images/teachers/ahmad.jpg');
    });

    test('AcademyTeacher handles empty photo and name fallback', () {
      final teacher = AcademyTeacher.fromJson({
        'id': 't2',
        'name': 'Ustadha Fatima',
        'photo_url': null,
      });

      expect(teacher.initial, 'F');
      expect(teacher.photoUrl, isEmpty);
    });

    test('TrialBookingRequest.toJson formats exact Supabase table payload', () {
      final request = TrialBookingRequest(
        studentName: 'Zaid Khan',
        contactInfo: '+1234567890 (zaid@example.com)',
        programId: 'prog-1',
        programTitle: 'Quran Reading with Tajweed',
        preferredTime: 'Evenings (6 PM - 10 PM)',
        notes: 'Looking for trial classes on weekends',
      );

      final map = request.toJson();
      expect(map['student_name'], 'Zaid Khan');
      expect(map['contact_info'], '+1234567890 (zaid@example.com)');
      expect(map['program_id'], 'prog-1');
      expect(map['program_title'], 'Quran Reading with Tajweed');
      expect(map['preferred_time'], 'Evenings (6 PM - 10 PM)');
      expect(map['notes'], 'Looking for trial classes on weekends');
      expect(map['status'], 'new');
    });
  });

  group('Academy Repository & Offline Cache Tests', () {
    test('fetches live data when online and updates SharedPreferences cache', () async {
      final mockClient = MockClient((request) async {
        if (request.url.path.contains('/programs')) {
          return http.Response(
            json.encode([
              {
                'id': 'p1',
                'title': 'Quran Hifz Program',
                'description': 'Memorize the Holy Quran',
                'monthly_fee': '70',
                'is_active': true,
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        } else if (request.url.path.contains('/teachers')) {
          return http.Response(
            json.encode([
              {
                'id': 't1',
                'name': 'Qari Bilal',
                'qualification': 'Hafiz & Qari',
                'is_active': true,
              }
            ]),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        return http.Response('Not Found', 404);
      });

      final repo = AcademyRepository(client: mockClient);
      final programsResult = await repo.fetchPrograms(forceRefresh: true);
      final teachersResult = await repo.fetchTeachers(forceRefresh: true);

      expect(programsResult.data.length, 1);
      expect(programsResult.data.first.title, 'Quran Hifz Program');
      expect(programsResult.isFromOfflineCache, isFalse);

      expect(teachersResult.data.length, 1);
      expect(teachersResult.data.first.name, 'Qari Bilal');
      expect(teachersResult.isFromOfflineCache, isFalse);

      // Verify cached in prefs
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.containsKey(AcademyRepository.prefProgramsKey), isTrue);
      expect(prefs.containsKey(AcademyRepository.prefTeachersKey), isTrue);
    });

    test('falls back to SharedPreferences cache when network request fails', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AcademyRepository.prefProgramsKey,
        json.encode([
          {
            'id': 'cached-p1',
            'title': 'Cached Noorani Qaida',
            'description': 'Offline Qaida lesson',
            'is_active': true,
          }
        ]),
      );
      await prefs.setString(
        AcademyRepository.prefTeachersKey,
        json.encode([
          {
            'id': 'cached-t1',
            'name': 'Cached Sheikh',
            'is_active': true,
          }
        ]),
      );

      final failingClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final repo = AcademyRepository(client: failingClient);
      final programsResult = await repo.fetchPrograms(forceRefresh: true);
      final teachersResult = await repo.fetchTeachers(forceRefresh: true);

      expect(programsResult.data.length, 1);
      expect(programsResult.data.first.id, 'cached-p1');
      expect(programsResult.data.first.title, 'Cached Noorani Qaida');
      expect(programsResult.isFromOfflineCache, isTrue);

      expect(teachersResult.data.length, 1);
      expect(teachersResult.data.first.name, 'Cached Sheikh');
      expect(teachersResult.isFromOfflineCache, isTrue);
    });

    test('bookTrial sends POST request without ?select=* and succeeds on 201', () async {
      var postUrlCalled = '';
      Map<String, String>? postHeaders;
      String? postBody;

      final mockClient = MockClient((request) async {
        if (request.method == 'POST' && request.url.path.contains('/trial_bookings')) {
          postUrlCalled = request.url.toString();
          postHeaders = request.headers;
          postBody = request.body;
          return http.Response('', 201);
        }
        return http.Response('Error', 400);
      });

      final repo = AcademyRepository(client: mockClient);
      final success = await repo.bookTrial(TrialBookingRequest(
        studentName: 'Ali',
        contactInfo: 'ali@example.com',
        programTitle: 'Quran Hifz',
      ));

      expect(success, isTrue);
      expect(postUrlCalled.contains('select='), isFalse, reason: 'Must not append select=* to avoid 401');
      expect(postHeaders?['apikey'], isNotNull);
      expect(postHeaders?['Authorization'], isNotNull);
      expect(postBody, isNotNull);
      expect(json.decode(postBody!)['student_name'], 'Ali');
    });
  });

  group('Academy UI & Flow Tests', () {
    Widget buildTestWidget({required Widget child, Locale locale = const Locale('en')}) {
      final mockRepo = AcademyRepository(
        client: MockClient((request) async {
          if (request.url.path.contains('/programs')) {
            return http.Response(
              json.encode([
                {
                  'id': 'p1',
                  'title': 'Noorani Qaida for Beginners',
                  'description': 'Master the basics of Arabic letters and pronunciation.',
                  'monthly_fee': '40',
                  'duration': '3-6 months',
                  'schedule_flexibility': 'Flexible 1-on-1',
                  'is_active': true,
                }
              ]),
              200,
            );
          }
          if (request.url.path.contains('/trial_bookings')) {
            return http.Response('', 201);
          }
          return http.Response(
            json.encode([
              {
                'id': 't1',
                'name': 'Sheikh Ahmad Al-Mansoor',
                'qualification': 'Al-Azhar Graduate',
                'experience': '12+ years',
                'photo_url': null,
                'is_active': true,
              }
            ]),
            200,
          );
        }),
      );

      return ProviderScope(
        overrides: [
          academyRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: [
            TestLocalizationsDelegate(locale),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: child,
        ),
      );
    }

    testWidgets('AcademyHomeScreen renders Hero, features, programs, teachers and CTA at 360px without overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(child: const AcademyHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Noorani Qaida for Beginners'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Sheikh Ahmad Al-Mansoor'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Sheikh Ahmad Al-Mansoor'), findsOneWidget);
      expect(find.text('Book Free Trial'), findsWidgets);
    });

    testWidgets('ProgramDetailScreen displays full description and navigation to booking', (tester) async {
      const program = AcademyProgram(
        id: 'p1',
        title: 'Tajweed Mastery',
        slug: 'tajweed-mastery',
        description: 'Comprehensive course covering articulation points and Quran recitation rules.',
        monthlyFee: '50',
        duration: '4 months',
        scheduleFlexibility: 'Flexible 1-on-1',
      );

      await tester.pumpWidget(buildTestWidget(child: const ProgramDetailScreen(program: program)));
      await tester.pumpAndSettle();

      expect(find.text('Tajweed Mastery'), findsWidgets);
      expect(find.text('Book Free Trial'), findsOneWidget);

      await tester.tap(find.text('Book Free Trial'));
      await tester.pumpAndSettle();
      expect(find.text('Book 3-Day Free Trial'), findsOneWidget);
    });

    testWidgets('TrialBookingScreen validates inputs and handles booking submission', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const TrialBookingScreen()));
      await tester.pumpAndSettle();

      // Tap submit with empty fields
      final submitButton = find.widgetWithText(ElevatedButton, 'Confirm Trial Booking');
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Validation errors shown
      expect(find.text('Please enter student name'), findsOneWidget);
      expect(find.text('Please enter phone or WhatsApp number'), findsOneWidget);

      // Enter valid fields
      await tester.enterText(find.byType(TextFormField).at(0), 'Wadan Momand');
      await tester.enterText(find.byType(TextFormField).at(1), '+15551234567');
      await tester.pumpAndSettle();

      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Confirmation screen is shown
      expect(find.text('Free Trial Booked!'), findsOneWidget);
      expect(find.text('Our academic team will contact you on WhatsApp shortly to schedule your first 1-on-1 session.'), findsOneWidget);
    });

    testWidgets('AcademyHomeScreen renders in Arabic (RTL) without layout overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const AcademyHomeScreen(),
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AcademyHomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AcademyHomeScreen renders in Urdu (RTL) without layout overflow', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildTestWidget(
          child: const AcademyHomeScreen(),
          locale: const Locale('ur'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AcademyHomeScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
