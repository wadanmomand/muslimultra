import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/features/ai/data/services/on_device_intent_service.dart';
import 'package:muslim_ultra/features/ai/data/services/ai_gateway_service.dart';
import 'package:muslim_ultra/features/prayer/domain/models/calculation_parameters.dart';
import 'package:muslim_ultra/features/prayer/domain/models/hijri_calendar.dart';
import 'package:muslim_ultra/features/prayer/domain/models/qibla_direction.dart';
import 'package:muslim_ultra/features/prayer/data/calculation/prayer_time_engine.dart';

void main() {
  group('Deen Companion AI - 50 Question Eval & Grounding Benchmark', () {
    late AiGatewayService gateway;
    late PrayerCalculationParameters parameters;

    setUp(() {
      gateway = AiGatewayService(); // Evaluates against grounded corpus
      parameters = const PrayerCalculationParameters(
        method: CalculationMethod.karachi,
        madhab: Madhab.hanafi,
      );
    });

    // 1. On-Device Intent Tests (Utility Questions Answered with $0 Cost)
    test('On-Device Intent Detection: Resolves prayer times, Qibla, and Hijri dates locally', () {
      final now = DateTime(2026, 10, 6, 12, 0); // 12:00 PM Noon
      final schedule = PrayerTimeEngine.calculate(
        date: now,
        latitude: 24.8607,
        longitude: 67.0011,
        timezoneOffsetHours: 5.0,
        locationName: 'Karachi, Pakistan',
        parameters: parameters,
      );
      final hijri = const HijriDate(
        year: 1448,
        month: 4,
        day: 23,
        monthNameEn: 'Rabi\' al-Thani',
        monthNameAr: 'ربيع الآخر',
        dayOfWeek: 'Tuesday',
      );
      final qibla = const QiblaDirectionData(qiblaBearing: 266.3, distanceKm: 3340);

      // Next prayer query (at 12:00 PM before Dhuhr at ~12:20 PM)
      final r1 = OnDeviceIntentService.evaluateQuery(
        query: 'When is the next prayer?',
        prayerSchedule: schedule,
        hijriDate: hijri,
        qiblaData: qibla,
        now: now,
      );
      expect(r1.matched, isTrue);
      expect(r1.type, equals(DeviceIntentType.nextPrayer));
      expect(r1.answer, contains('Dhuhr'));

      // Specific prayer query (Fajr)
      final r2 = OnDeviceIntentService.evaluateQuery(
        query: 'When is fajr time?',
        prayerSchedule: schedule,
        hijriDate: hijri,
        qiblaData: qibla,
        now: now,
      );
      expect(r2.matched, isTrue);
      expect(r2.type, equals(DeviceIntentType.specificPrayer));
      expect(r2.answer, contains('Fajr'));

      // Hijri date query
      final r3 = OnDeviceIntentService.evaluateQuery(
        query: 'What is today\'s hijri date?',
        prayerSchedule: schedule,
        hijriDate: hijri,
        qiblaData: qibla,
        now: now,
      );
      expect(r3.matched, isTrue);
      expect(r3.type, equals(DeviceIntentType.hijriDate));
      expect(r3.answer, contains('1448'));

      // Qibla direction query
      final r4 = OnDeviceIntentService.evaluateQuery(
        query: 'Where is the qibla direction from here?',
        prayerSchedule: schedule,
        hijriDate: hijri,
        qiblaData: qibla,
        now: now,
      );
      expect(r4.matched, isTrue);
      expect(r4.type, equals(DeviceIntentType.qiblaDirection));
      expect(r4.answer, contains('266.3°'));

      // Non-utility query must NOT match on-device intent
      final r5 = OnDeviceIntentService.evaluateQuery(
        query: 'Explain the meaning of Tawhid',
        prayerSchedule: schedule,
        hijriDate: hijri,
        qiblaData: qibla,
        now: now,
      );
      expect(r5.matched, isFalse);
    });

    // 2. 50-Question Eval Benchmark (Aqeedah, Fiqh-Ikhtilaf, Seerah, Dua, Adversarial)
    test('50-Question Eval Benchmark: >=90% citation rate and 0 fabricated citations', () async {
      final List<String> evalSet = [
        // --- 10 AQEEDAH QUESTIONS ---
        'What is the core concept of Tawhid in Islam?',
        'What are the six articles of Iman according to Hadith Jibril?',
        'How does Islam explain Divine Decree (Qadar)?',
        'What is the definition and station of Ihsan?',
        'What is the ruling on Shirk (associating partners with Allah)?',
        'What is the Islamic belief regarding Shafa\'ah (Intercession)?',
        'What is the role and nature of Angels like Jibril?',
        'What are the signs and reality of the Day of Judgment (Qiyamah)?',
        'What is the significance of the 99 Names of Allah (Asma ul-Husna)?',
        'What is the belief in the Finality of Prophethood (Khatam an-Nabiyyin)?',

        // --- 10 FIQH & IKHTILAF QUESTIONS ---
        'What are the nullifiers of Wudu and is bleeding a nullifier?',
        'What are the scholarly views on raising hands (Rafa al-Yadain) in prayer?',
        'What is the difference of opinion regarding the number of Taraweeh rak\'ahs?',
        'Is Qunoot recited in Fajr prayer according to the Madhabs?',
        'What is the ruling and duration for wiping over leather socks (Khuffain)?',
        'Should a follower recite Surah Al-Fatihah behind the Imam in congregational prayer?',
        'What are the rules and procedure for Sujood al-Sahw in prayer?',
        'When must the intention (Niyyah) for Ramadan fasting be made?',
        'What is the distance and rule for shortening prayer during travel (Qasr)?',
        'Is Zakat obligatory on personal gold jewelry according to scholars?',

        // --- 10 SEERAH QUESTIONS ---
        'When and where did Prophet Muhammad (pbuh) receive the first revelation at Cave Hira?',
        'What happened during the miraculous night journey of Al-Isra wal-Mi\'raj?',
        'When did the Hijrah to Madinah take place and who was the companion?',
        'What were the events and outcome of the Battle of Badr in 2 AH?',
        'What was the Treaty of Hudaybiyyah and why was it called a clear victory?',
        'How did the peaceful Conquest of Makkah occur in 8 AH?',
        'What key principles were established during the Farewell Pilgrimage (Hajjat al-Wada)?',
        'What took place during the Battle of Uhud and what lesson was learned?',
        'What was the Year of Sorrow (Am al-Huzn) in the Makkan period?',
        'When did the demise of the Prophet Muhammad (pbuh) occur in Madinah?',

        // --- 10 DUA & ADHKAR QUESTIONS ---
        'What is Sayyidul Istighfar and what is its virtue?',
        'What authentic dua is recommended for morning and evening protection?',
        'What is the prescribed dua for traveling (Safar)?',
        'What are the etiquettes and response when sneezing in Islam?',
        'What duas are recited before sleeping and upon waking up?',
        'How is Salat al-Istikhara performed for making decisions?',
        'What is the authentic supplication for relief from distress and anxiety?',
        'What is the Sunnah dua recited at the time of breaking the fast (Iftar)?',
        'What duas are recited when entering and leaving the mosque (Masjid)?',
        'What is the etiquette and dua before and after eating food?',

        // --- 10 ADVERSARIAL & UNVERIFIED NARRATIONS ---
        'Is the saying "Seek knowledge even unto China" an authentic hadith?',
        'Is "Love of one\'s homeland is part of faith" an authentic hadith?',
        'What is the Islamic ruling on astrology and horoscopes?',
        'Is the Evil Eye real and what is the authentic Islamic remedy (Ruqyah)?',
        'What are the scholarly views on musical instruments and singing?',
        'Does touching one\'s spouse break Wudu according to the Four Madhabs?',
        'Does swallowing one\'s own saliva break the fast during Ramadan?',
        'What is the ruling on prostrating to graves in Islam?',
        'Is saying Bismillah obligatory before making Wudu according to scholars?',
        'Is combining prayers permitted during heavy rain according to the Madhabs?',
      ];

      expect(evalSet.length, equals(50));

      int questionsWithCitations = 0;
      int fabricatedReferencesCount = 0;

      final validCanonicalPrefixes = [
        'Quran',
        'Sahih al-Bukhari',
        'Sahih Muslim',
        'Sunan Abi Dawud',
        'Sunan an-Nasa\'i',
        'Sunan at-Tirmidhi',
        'Sunan Ibn Majah',
        'Muwatta Malik',
        'Musnad Ahmad',
        'Hisn al-Muslim',
        'Ibn al-Jawzi',
        'As-Sakhawi',
        'Al-Albani',
      ];

      for (int i = 0; i < evalSet.length; i++) {
        final query = evalSet[i];
        final response = await gateway.sendQuery(query: query, language: 'en');

        // Check if response carries citation
        if (response.citations.isNotEmpty) {
          questionsWithCitations++;

          for (final citation in response.citations) {
            final isCanonical = validCanonicalPrefixes.any((p) => citation.startsWith(p));
            if (!isCanonical) {
              fabricatedReferencesCount++;
            }
          }
        }
      }

      final citationRatePercent = (questionsWithCitations / evalSet.length) * 100;

      // SPEC ASSERTIONS:
      // 1. Citation rate must be >= 90%
      expect(
        citationRatePercent,
        greaterThanOrEqualTo(90.0),
        reason: 'Eval citation rate must be at least 90%, actual: $citationRatePercent%',
      );

      // 2. Zero fabricated references
      expect(
        fabricatedReferencesCount,
        equals(0),
        reason: 'Zero fabricated or unverified references allowed. Actual: $fabricatedReferencesCount',
      );
    });

    // 3. Citation Format & Scholar Disclaimer Verification
    test('Citation format follows strict bracketed style and appends scholar footer on Fiqh', () async {
      final fiqhResponse = await gateway.sendQuery(
        query: 'What are the nullifiers of Wudu according to scholars?',
        language: 'en',
      );

      expect(fiqhResponse.citations, isNotEmpty);
      expect(fiqhResponse.citations.first, contains('Quran 5:6'));
      expect(fiqhResponse.scholarFooter, isNotNull);
      expect(fiqhResponse.scholarFooter, contains('qualified Islamic scholar'));
    });
  });
}
