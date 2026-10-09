import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:muslim_ultra/core/l10n/app_localizations.dart';
import 'package:muslim_ultra/features/deen/data/activity_heatmap.dart';
import 'package:muslim_ultra/features/deen/data/deen_score.dart';
import 'package:muslim_ultra/features/deen/data/milestones.dart';
import 'package:muslim_ultra/features/deen/presentation/widgets/activity_heatmap.dart';
import 'package:muslim_ultra/features/dua_journal/data/dua_journal_repository.dart';
import 'package:muslim_ultra/features/mood/data/mood_repository.dart';

void main() {

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    MoodRepository.clearCacheForTesting();
  });

  group('Part 1: Activity Heatmap Logic & Score Bounds', () {
    test('calculateDayScore bounds & weights', () {
      // Empty day
      final emptyScore = ActivityHeatmapService.calculateDayScore(
        prayersPrayed: 0,
        isFasting: false,
        quranMinutes: 0,
        isDhikrDone: false,
        isQuizDone: false,
      );
      expect(emptyScore, 0.0);

      // Full day: 5 prayers (0.50) + fasting (0.20) + 30m Quran (0.15) + dhikr (0.10) + quiz (0.05) = 1.0
      final fullScore = ActivityHeatmapService.calculateDayScore(
        prayersPrayed: 5,
        isFasting: true,
        quranMinutes: 30,
        isDhikrDone: true,
        isQuizDone: true,
      );
      expect(fullScore, closeTo(1.0, 0.001));

      // Partial day: 3 prayers = (3/5)*0.50 = 0.30
      final partialScore = ActivityHeatmapService.calculateDayScore(
        prayersPrayed: 3,
        isFasting: false,
        quranMinutes: 0,
        isDhikrDone: false,
        isQuizDone: false,
      );
      expect(partialScore, closeTo(0.30, 0.001));

      // Over bounds clamping
      final clampedScore = ActivityHeatmapService.calculateDayScore(
        prayersPrayed: 10,
        isFasting: true,
        quranMinutes: 120,
        isDhikrDone: true,
        isQuizDone: true,
      );
      expect(clampedScore, 1.0);
    });

    test('buildHeatmap empty logs produce all zero scores for 53 weeks', () {
      final now = DateTime(2026, 10, 9);
      final heatmap = buildHeatmap(
        prayersMap: {},
        fastsKeptSet: {},
        quranMinutesMap: {},
        dhikrDoneSet: {},
        quizDoneSet: {},
        endDate: now,
        totalWeeks: 53,
      );

      expect(heatmap.length, 53 * 7);
      for (final day in heatmap) {
        expect(day.score, 0.0);
        expect(day.intensityLevel, 0);
      }
    });

    test('buildHeatmap correctly maps days with activity', () {
      final now = DateTime(2026, 10, 9);
      final todayKey = '2026-10-09';
      final heatmap = buildHeatmap(
        prayersMap: {todayKey: 5},
        fastsKeptSet: {todayKey},
        quranMinutesMap: {todayKey: 30},
        dhikrDoneSet: {todayKey},
        quizDoneSet: {todayKey},
        endDate: now,
        totalWeeks: 53,
      );

      final todayActivity = heatmap.firstWhere(
        (d) =>
            d.date.year == now.year &&
            d.date.month == now.month &&
            d.date.day == now.day,
      );

      expect(todayActivity.score, 1.0);
      expect(todayActivity.intensityLevel, 4);
      expect(todayActivity.prayersPrayed, 5);
      expect(todayActivity.isFasting, true);
      expect(todayActivity.quranMinutes, 30);
      expect(todayActivity.isDhikrDone, true);
      expect(todayActivity.isQuizDone, true);
    });
  });

  group('Part 2: Dua Journal (Private & On-Device)', () {
    test('CRUD round-trip & answered filtering', () async {
      final repo = DuaJournalRepository();

      // Initial state is empty
      var entries = await repo.getAllEntries();
      expect(entries, isEmpty);

      // Create entries
      final entry1 = await repo.addEntry('Ya Allah grant me ease');
      final entry2 = await repo.addEntry('Rabbana atina fid-dunya hasanah');

      entries = await repo.getAllEntries();
      expect(entries.length, 2);
      expect(entries.first.id, entry2.id); // Newest first
      expect(entries.first.isAnswered, isFalse);

      // Mark entry1 as answered
      await repo.toggleAnswered(entry1.id);

      final updated1 = await repo.getEntryById(entry1.id);
      expect(updated1?.isAnswered, isTrue);
      expect(updated1?.answeredAt, isNotNull);

      // Filter Answered & Pending
      final all = await repo.getAllEntries();
      final answered = all.where((e) => e.isAnswered).toList();
      expect(answered.length, 1);
      expect(answered.first.id, entry1.id);

      final pending = all.where((e) => !e.isAnswered).toList();
      expect(pending.length, 1);
      expect(pending.first.id, entry2.id);


      // Delete entry2
      await repo.deleteEntry(entry2.id);
      entries = await repo.getAllEntries();
      expect(entries.length, 1);
      expect(entries.first.id, entry1.id);
    });
  });

  group('Part 3: Mood -> Dhikr Dataset & Logging', () {
    test('Loads all 8 moods and verifies Arabic text and structure', () async {
      // Create a test bundle or use MoodItem directly
      final repo = MoodRepository();

      const sampleJson = '''
      {
        "moods": [
          {
            "mood_en": "Anxious",
            "mood_ur": "بے چین / پریشان",
            "mood_ar": "قلق",
            "emoji": "😰",
            "dua_ar": "حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ ۖ عَلَيْهِ تَوَكَّلْتُ ۖ وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ",
            "dua_en": "Sufficient for me is Allah; there is no deity except Him. On Him I have relied, and He is the Lord of the Great Throne.",
            "dua_ur": "میرے لیے اللہ ہی کافی ہے، اس کے سوا کوئی معبود نہیں، اسی پر میں نے بھروسہ کیا اور وہی عرشِ عظیم کا مالک ہے۔",
            "source": "Quran 9:129"
          },
          {
            "mood_en": "Grateful",
            "mood_ur": "شکر گزار",
            "mood_ar": "شاكر",
            "emoji": "🤲",
            "dua_ar": "الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ",
            "dua_en": "All praise is due to Allah, Lord of the worlds.",
            "dua_ur": "تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا رب ہے۔",
            "source": "Quran 1:2"
          },
          {
            "mood_en": "Sad",
            "mood_ur": "اداس",
            "mood_ar": "حزين",
            "emoji": "😢",
            "dua_ar": "إِنَّمَا أَشْكُو بَثِّي وَحُزْنِي إِلَى اللَّهِ",
            "dua_en": "I only complain of my suffering and my grief to Allah.",
            "dua_ur": "میں تو اپنی پریشانی اور غم کی فریاد صرف اللہ ہی سے کرتا ہوں۔",
            "source": "Quran 12:86"
          },
          {
            "mood_en": "Stressed",
            "mood_ur": "دباؤ میں",
            "mood_ar": "مضغوط",
            "emoji": "😫",
            "dua_ar": "لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ",
            "dua_en": "There is no power and no strength except with Allah.",
            "dua_ur": "گناہوں سے بچنے کی طاقت اور نیکی کرنے کی قوت صرف اللہ ہی کی توفیق سے ہے۔",
            "source": "Sahih Bukhari"
          },
          {
            "mood_en": "Angry",
            "mood_ur": "غصے میں",
            "mood_ar": "غاضب",
            "emoji": "😡",
            "dua_ar": "أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ",
            "dua_en": "I seek refuge in Allah from Satan, the accursed.",
            "dua_ur": "میں شیطان مردود سے اللہ کی پناہ مانگتا ہوں۔",
            "source": "Sahih Bukhari"
          },
          {
            "mood_en": "Lonely",
            "mood_ur": "تنہا",
            "mood_ar": "وحيد",
            "emoji": "🥺",
            "dua_ar": "رَبِّ إِنِّي لِمَا أَنزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ",
            "dua_en": "My Lord, indeed I am in need of whatever good You would send down to me.",
            "dua_ur": "اے میرے پروردگار! تو جو بھی بھلائی مجھ پر نازل فرمائے میں اس کا محتاج ہوں۔",
            "source": "Quran 28:24"
          },
          {
            "mood_en": "Hopeful",
            "mood_ur": "پرامید",
            "mood_ar": "متفائل",
            "emoji": "✨",
            "dua_ar": "لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ",
            "dua_en": "Do not despair of the mercy of Allah.",
            "dua_ur": "اللہ کی رحمت سے ناامید نہ ہو۔",
            "source": "Quran 39:53"
          },
          {
            "mood_en": "Repentant",
            "mood_ur": "توبہ گزار",
            "mood_ar": "تائب",
            "emoji": "🧎",
            "dua_ar": "أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ وَأَتُوبُ إِلَيْهِ",
            "dua_en": "I seek the forgiveness of Allah the Great and I repent unto Him.",
            "dua_ur": "میں عظمت والے اللہ سے مغفرت مانگتا ہوں اور اسی کی بارگاہ میں توبہ کرتا ہوں۔",
            "source": "Sunan an-Nasa'i"
          }
        ]
      }
      ''';

      final mockBundle = _MockAssetBundle({'assets/mood/mood_dhikr.json': sampleJson});
      final moods = await repo.getAllMoods(bundle: mockBundle);

      expect(moods.length, 8);
      for (final m in moods) {
        expect(m.moodEn, isNotEmpty);
        expect(m.duaAr, isNotEmpty);
        expect(m.emoji, isNotEmpty);
        expect(m.source, isNotEmpty);
      }
    });

    test('Mood logging and overwrite per day', () async {
      final repo = MoodRepository();
      final today = DateTime(2026, 10, 9);

      expect(await repo.getLoggedMoodKey(today), isNull);

      // Log initial mood
      await repo.logMood('Anxious', today);
      expect(await repo.getLoggedMoodKey(today), 'Anxious');

      // Overwrite today's mood
      await repo.logMood('Grateful', today);
      expect(await repo.getLoggedMoodKey(today), 'Grateful');
    });
  });

  group('Part 4: Milestones & Celebration Persistence', () {
    test('checkMilestones detects newly hit milestones and ignores already celebrated', () {
      // 0 stats -> no milestones
      final initial = checkMilestones(
        prayerStreak: 0,
        fastingStreak: 0,
        totalXp: 0,
        hasCompletedKhatmah: false,
        quizStreak: 0,
        alreadyCelebratedIds: {},
      );
      expect(initial, isEmpty);

      // Hit 7-day prayer streak + 1000 XP
      final hit = checkMilestones(
        prayerStreak: 7,
        fastingStreak: 0,
        totalXp: 1200,
        hasCompletedKhatmah: false,
        quizStreak: 0,
        alreadyCelebratedIds: {},
      );
      expect(hit.length, 2);
      expect(hit.map((m) => m.id), containsAll(['prayer_streak_7', 'xp_1000']));

      // If 'prayer_streak_7' was already celebrated, only 'xp_1000' is returned
      final filtered = checkMilestones(
        prayerStreak: 7,
        fastingStreak: 0,
        totalXp: 1200,
        hasCompletedKhatmah: false,
        quizStreak: 0,
        alreadyCelebratedIds: {'prayer_streak_7'},
      );
      expect(filtered.length, 1);
      expect(filtered.first.id, 'xp_1000');
    });

    test('Milestone repository persists celebrated milestones', () async {
      final repo = MilestoneRepository();

      expect(await repo.getCelebratedMilestones(), isEmpty);

      await repo.markCelebrated('prayer_streak_7');
      await repo.markCelebrated('khatmah_complete');

      final celebrated = await repo.getCelebratedMilestones();
      expect(celebrated, containsAll(['prayer_streak_7', 'khatmah_complete']));
    });
  });

  group('Part 5: Deen Score Logic (0–100)', () {
    test('dailyScore calculates 0 for nothing, 100 for all complete, and correct partials', () {
      // 0 score
      final zero = calculateDailyDeenScore(
        prayersPrayed: 0,
        quranMinutes: 0,
        dhikrDone: false,
        quizAnswered: false,
        learningViewed: false,
      );
      expect(zero.totalScore, 0);

      // 100 score: 5*12=60 + 15 + 10 + 10 + 5 = 100
      final full = calculateDailyDeenScore(
        prayersPrayed: 5,
        quranMinutes: 15,
        dhikrDone: true,
        quizAnswered: true,
        learningViewed: true,
      );
      expect(full.totalScore, 100);
      expect(full.prayerScore, 60);
      expect(full.quranScore, 15);
      expect(full.dhikrScore, 10);
      expect(full.quizScore, 10);
      expect(full.learningScore, 5);

      // Partial score: 3 prayers (36) + dhikr (10) = 46
      final partial = calculateDailyDeenScore(
        prayersPrayed: 3,
        quranMinutes: 5, // under 10m -> 0
        dhikrDone: true,
        quizAnswered: false,
        learningViewed: false,
      );
      expect(partial.totalScore, 46);
      expect(partial.prayerScore, 36);
      expect(partial.quranScore, 0);
    });
  });

  group('Widget Tests: Heatmap 53x7 & RTL Smoke', () {
    testWidgets('Heatmap renders 53x7 grid cells', (tester) async {
      final sampleActivities = List.generate(
        53 * 7,
        (i) => DayActivity(
          date: DateTime(2026, 1, 1).add(Duration(days: i)),
          score: (i % 5) / 4.0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en')],
          home: Scaffold(
            body: SingleChildScrollView(
              child: ActivityHeatmapWidget(
                activities: sampleActivities,
                totalWeeks: 53,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ActivityHeatmapWidget), findsOneWidget);
      // Verify cells exist
      expect(find.byKey(const ValueKey('heatmap_cell_0_0')), findsOneWidget);
      expect(find.byKey(const ValueKey('heatmap_cell_52_6')), findsOneWidget);
    });

    testWidgets('360px RTL smoke test', (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final sampleActivities = List.generate(
        53 * 7,
        (i) => DayActivity(
          date: DateTime(2026, 1, 1).add(Duration(days: i)),
          score: 0.5,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ar'),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],

          supportedLocales: const [Locale('en'), Locale('ar'), Locale('ur')],
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: SingleChildScrollView(
                child: ActivityHeatmapWidget(
                  activities: sampleActivities,
                  totalWeeks: 53,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ActivityHeatmapWidget), findsOneWidget);
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
