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
import 'package:muslim_ultra/features/mosques/domain/models/mosque.dart';
import 'package:muslim_ultra/features/mosques/data/mosques_repository.dart';
import 'package:muslim_ultra/features/mosques/presentation/providers/mosques_providers.dart';
import 'package:muslim_ultra/features/mosques/presentation/screens/mosques_screen.dart';

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

  const sampleOverpassJson = '''
  {
    "version": 0.6,
    "generator": "Overpass API",
    "elements": [
      {
        "type": "node",
        "id": 101,
        "lat": 24.8620,
        "lon": 67.0020,
        "tags": {
          "amenity": "place_of_worship",
          "religion": "muslim",
          "name": "Masjid Al-Falah",
          "addr:street": "Main Boulevard"
        }
      },
      {
        "type": "node",
        "id": 102,
        "lat": 24.8700,
        "lon": 67.0100,
        "tags": {
          "amenity": "place_of_worship",
          "religion": "muslim",
          "name:en": "Grand Jamia Mosque",
          "name:ar": "جامع التقوى"
        }
      },
      {
        "type": "node",
        "id": 103,
        "lat": 24.8600,
        "lon": 67.0005,
        "tags": {
          "amenity": "place_of_worship",
          "religion": "muslim"
        }
      }
    ]
  }
  ''';

  group('Mosque Domain Model & Math Tests', () {
    test('Calculates Haversine distance and bearing correctly', () {
      const userLat = 24.8607;
      const userLon = 67.0011;

      const mosqueLat = 24.8620;
      const mosqueLon = 67.0020;

      final dist = Mosque.calculateDistance(userLat, userLon, mosqueLat, mosqueLon);
      final bearing = Mosque.calculateBearing(userLat, userLon, mosqueLat, mosqueLon);

      expect(dist, greaterThan(100));
      expect(dist, lessThan(300));
      expect(bearing, inInclusiveRange(0.0, 360.0));
    });

    test('Parses Overpass element JSON into Mosque model with fallback name', () {
      final json = {
        'id': 999,
        'lat': 24.865,
        'lon': 67.005,
        'tags': {
          'amenity': 'place_of_worship',
          'religion': 'muslim',
        },
      };

      final mosque = Mosque.fromOverpassJson(json, userLat: 24.8607, userLon: 67.0011);
      expect(mosque.id, '999');
      expect(mosque.name, 'Masjid');
      expect(mosque.distanceMeters, greaterThan(0));
    });

    test('Serializes and deserializes Mosque toJson/fromJson', () {
      const mosque = Mosque(
        id: '123',
        name: 'Masjid Quba',
        latitude: 24.4,
        longitude: 39.6,
        distanceMeters: 1250.5,
        bearingDegrees: 45.0,
        street: 'Quba Road',
        city: 'Madinah',
      );

      final json = mosque.toJson();
      final revived = Mosque.fromJson(json);

      expect(revived.id, '123');
      expect(revived.name, 'Masjid Quba');
      expect(revived.distanceMeters, 1250.5);
      expect(revived.bearingDegrees, 45.0);
      expect(revived.street, 'Quba Road');
      expect(revived.city, 'Madinah');
    });
  });

  group('Mosques Repository & Cache Tests', () {
    test('fetchNearbyMosques parses Overpass response and sorts by distance', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(sampleOverpassJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final repo = MosquesRepository(client: mockClient, prefs: prefs);
      final result = await repo.fetchNearbyMosques(
        latitude: 24.8607,
        longitude: 67.0011,
        radiusMeters: 5000,
      );

      expect(result.isFromCache, isFalse);
      expect(result.mosques.length, 3);
      expect(result.mosques[0].distanceMeters, lessThanOrEqualTo(result.mosques[1].distanceMeters));
      expect(result.mosques[1].distanceMeters, lessThanOrEqualTo(result.mosques[2].distanceMeters));
    });

    test('Cached results are saved and returned on subsequent fetch within TTL', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      var callCount = 0;
      final mockClient = MockClient((request) async {
        callCount++;
        return http.Response.bytes(
          utf8.encode(sampleOverpassJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final repo = MosquesRepository(client: mockClient, prefs: prefs);

      // First call (fetches over network)
      final res1 = await repo.fetchNearbyMosques(
        latitude: 24.8607,
        longitude: 67.0011,
        radiusMeters: 5000,
      );
      expect(res1.isFromCache, isFalse);
      expect(callCount, 1);

      // Second call (hits cache)
      final res2 = await repo.fetchNearbyMosques(
        latitude: 24.8607,
        longitude: 67.0011,
        radiusMeters: 5000,
      );
      expect(res2.isFromCache, isTrue);
      expect(res2.mosques.length, 3);
      expect(callCount, 1);
    });

    test('Network error throws typed MosquesException when no cache available', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        return http.Response('Server Error', 500);
      });

      final repo = MosquesRepository(client: mockClient, prefs: prefs);

      expect(
        () => repo.fetchNearbyMosques(
          latitude: 24.8607,
          longitude: 67.0011,
          radiusMeters: 5000,
          forceRefresh: true,
        ),
        throwsA(isA<MosquesException>()),
      );
    });

    test('Expired cache (>24h) is ignored during normal fetch', () async {
      final oldTimestamp =
          DateTime.now().subtract(const Duration(hours: 25)).millisecondsSinceEpoch;
      final expiredCacheData = jsonEncode({
        'timestamp': oldTimestamp,
        'userLat': 24.8607,
        'userLon': 67.0011,
        'radiusMeters': 5000,
        'mosques': [
          {
            'id': '99',
            'name': 'Old Mosque',
            'latitude': 24.861,
            'longitude': 67.002,
            'distanceMeters': 100.0,
            'bearingDegrees': 10.0,
          }
        ],
      });

      SharedPreferences.setMockInitialValues({
        MosquesRepository.cacheKey: expiredCacheData,
      });
      final prefs = await SharedPreferences.getInstance();

      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode(sampleOverpassJson),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final repo = MosquesRepository(client: mockClient, prefs: prefs);
      final result = await repo.fetchNearbyMosques(
        latitude: 24.8607,
        longitude: 67.0011,
        radiusMeters: 5000,
      );

      expect(result.isFromCache, isFalse);
      expect(result.mosques.length, 3);
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

  group('MosquesScreen Widget & Responsive Layout Tests', () {
    testWidgets('Renders nearby mosques list when data loads successfully', (tester) async {
      final mockMosques = [
        const Mosque(
          id: '1',
          name: 'Al-Madina Masjid',
          latitude: 24.861,
          longitude: 67.002,
          distanceMeters: 250,
          bearingDegrees: 45,
          street: 'Tariq Road',
        ),
        const Mosque(
          id: '2',
          name: 'Bait-ul-Mukarram',
          latitude: 24.865,
          longitude: 67.005,
          distanceMeters: 1400,
          bearingDegrees: 120,
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            nearbyMosquesProvider.overrideWith(
              (ref) => Future.value(MosquesQueryResult(mosques: mockMosques)),
            ),
          ],
          child: const MosquesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nearby Mosques'), findsOneWidget);
      expect(find.text('Al-Madina Masjid'), findsOneWidget);
      expect(find.text('Bait-ul-Mukarram'), findsOneWidget);
      expect(find.text('250 m'), findsOneWidget);
      expect(find.text('1.4 km'), findsOneWidget);

      // Tap mosque card to open maps sheet
      await tester.tap(find.text('Al-Madina Masjid'));
      await tester.pumpAndSettle();

      expect(find.text('Open in Maps / Copy Link'), findsOneWidget);
    });

    testWidgets('Renders offline state with retry button on network error', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          overrides: [
            nearbyMosquesProvider.overrideWith(
              (ref) => Future.error(const MosquesException('No network connection')),
            ),
          ],
          child: const MosquesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Internet Required'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('360x640 responsive smoke test in Arabic (RTL) with 0 overflow errors',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockMosques = [
        const Mosque(
          id: '1',
          name: 'مسجد النور الكبير المبارك',
          latitude: 24.861,
          longitude: 67.002,
          distanceMeters: 350,
          bearingDegrees: 90,
          street: 'شارع الملك فيصل',
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ar'),
          overrides: [
            nearbyMosquesProvider.overrideWith(
              (ref) => Future.value(MosquesQueryResult(mosques: mockMosques)),
            ),
          ],
          child: const MosquesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('المساجد القريبة'), findsOneWidget);
      expect(find.text('مسجد النور الكبير المبارك'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('360x640 responsive smoke test in Urdu (RTL) with 0 overflow errors',
        (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final mockMosques = [
        const Mosque(
          id: '1',
          name: 'جامع مسجد رحمت اللعالمین',
          latitude: 24.861,
          longitude: 67.002,
          distanceMeters: 550,
          bearingDegrees: 180,
          street: 'مرکزی شاہراہ',
        ),
      ];

      await tester.pumpWidget(
        createTestWidget(
          locale: const Locale('ur'),
          overrides: [
            nearbyMosquesProvider.overrideWith(
              (ref) => Future.value(MosquesQueryResult(mosques: mockMosques)),
            ),
          ],
          child: const MosquesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('قریبی مساجد'), findsOneWidget);
      expect(find.text('جامع مسجد رحمت اللعالمین'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
