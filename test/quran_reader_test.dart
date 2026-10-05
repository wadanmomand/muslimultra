import 'package:flutter_test/flutter_test.dart';
import 'package:muslim_ultra/features/quran/domain/models/reciter.dart';
import 'package:muslim_ultra/features/quran/data/audio_url_builder.dart';
import 'package:muslim_ultra/features/quran/data/tanzil_quran_data.dart';

void main() {
  group('EveryAyah CDN Audio URL Builder Tests (Spec §3 M2 Acceptance)', () {
    test('Correct URL mapping for Al-Fatiha 1:1 to 1:7', () {
      const reciter = 'Alafasy_128kbps';
      const surah = 1;

      final expectedUrls = [
        'https://everyayah.com/data/Alafasy_128kbps/001001.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001002.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001003.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001004.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001005.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001006.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/001007.mp3',
      ];

      for (int i = 1; i <= 7; i++) {
        final url = AudioUrlBuilder.buildAyahAudioUrl(
          reciterSubpath: reciter,
          surahNumber: surah,
          ayahNumber: i,
        );
        expect(url, expectedUrls[i - 1]);
      }
    });

    test('Correct URL mapping for Al-Baqarah 2:1 to 2:10', () {
      const reciter = 'Alafasy_128kbps';
      const surah = 2;

      final expectedUrls = [
        'https://everyayah.com/data/Alafasy_128kbps/002001.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002002.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002003.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002004.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002005.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002006.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002007.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002008.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002009.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/002010.mp3',
      ];

      for (int i = 1; i <= 10; i++) {
        final url = AudioUrlBuilder.buildAyahAudioUrl(
          reciterSubpath: reciter,
          surahNumber: surah,
          ayahNumber: i,
        );
        expect(url, expectedUrls[i - 1]);
      }
    });

    test('Reciter subpath switching generates valid URLs', () {
      final reciters = ReciterModel.availableReciters;
      expect(reciters.length, greaterThanOrEqualTo(5));

      final abdulBasitUrl = AudioUrlBuilder.buildAyahAudioUrl(
        reciterSubpath: 'Abdul_Basit_Murattal_192kbps',
        surahNumber: 112,
        ayahNumber: 1,
      );
      expect(
        abdulBasitUrl,
        'https://everyayah.com/data/Abdul_Basit_Murattal_192kbps/112001.mp3',
      );

      final husaryUrl = AudioUrlBuilder.buildAyahAudioUrl(
        reciterSubpath: 'Husary_128kbps',
        surahNumber: 36,
        ayahNumber: 83,
      );
      expect(
        husaryUrl,
        'https://everyayah.com/data/Husary_128kbps/036083.mp3',
      );
    });
  });

  group('Tanzil Quran Structure Tests', () {
    test('Contains exactly 114 Surahs sequentially numbered 1 to 114', () {
      final surahs = TanzilQuranData.allSurahs;
      expect(surahs.length, 114);

      for (int i = 0; i < 114; i++) {
        expect(surahs[i].number, i + 1);
        expect(surahs[i].name.isNotEmpty, isTrue);
        expect(surahs[i].englishName.isNotEmpty, isTrue);
        expect(surahs[i].numberOfAyahs, greaterThan(0));
      }

      expect(surahs[0].englishName, 'Al-Fatihah');
      expect(surahs[0].numberOfAyahs, 7);

      expect(surahs[1].englishName, 'Al-Baqarah');
      expect(surahs[1].numberOfAyahs, 286);

      expect(surahs[113].englishName, 'An-Nas');
      expect(surahs[113].numberOfAyahs, 6);
    });

    test('Contains exactly 30 Juz sequentially numbered 1 to 30', () {
      final juzList = TanzilQuranData.allJuz;
      expect(juzList.length, 30);

      for (int i = 0; i < 30; i++) {
        expect(juzList[i].number, i + 1);
        expect(juzList[i].nameArabic.isNotEmpty, isTrue);
        expect(juzList[i].nameEnglish.isNotEmpty, isTrue);
      }
    });

    test('Bundled Tanzil text for Al-Fatihah has 7 complete ayahs', () {
      final ayahs = TanzilQuranData.getBundledAyahs(1);
      expect(ayahs.length, 7);
      expect(ayahs[0].textUthmani, 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ');
      expect(ayahs[6].textUthmani.contains('ٱلضَّآلِّينَ'), isTrue);
    });
  });
}
