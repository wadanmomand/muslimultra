import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';
import 'tanzil_quran_data.dart';
import 'quran_storage_service.dart';

class QuranApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';

  /// Fetch Surah with Uthmani text, English translation (Saheeh International), and Urdu (Jalandhry)
  static Future<List<AyahModel>> fetchSurahAyahs(int surahNumber) async {
    // 1. Check local cache first
    final cached = await QuranStorageService.getCachedSurahData(surahNumber, 'uthmani_en_ur');
    if (cached != null && cached['ayahs'] != null) {
      return _parseAyahsFromCache(cached['ayahs'] as List<dynamic>, surahNumber);
    }

    // 2. Fetch from Al-Quran Cloud API with verified edition codes:
    // quran-uthmani (Tanzil Uthmani text)
    // en.sahih (Saheeh International)
    // ur.jalandhry (Fateh Muhammad Jalandhry)
    try {
      final url = Uri.parse(
        '$baseUrl/surah/$surahNumber/editions/quran-uthmani,en.sahih,ur.jalandhry',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['code'] == 200 && data['data'] is List) {
          final List editions = data['data'] as List;
          final List uthmaniAyahs = editions[0]['ayahs'] as List;
          final List englishAyahs = editions.length > 1 ? editions[1]['ayahs'] as List : [];
          final List urduAyahs = editions.length > 2 ? editions[2]['ayahs'] as List : [];

          final List<AyahModel> result = [];
          final List<Map<String, dynamic>> cacheList = [];

          for (int i = 0; i < uthmaniAyahs.length; i++) {
            final u = uthmaniAyahs[i];
            final en = i < englishAyahs.length ? englishAyahs[i]['text'] as String : '';
            final ur = i < urduAyahs.length ? urduAyahs[i]['text'] as String : '';

            final ayah = AyahModel(
              numberInSurah: u['numberInSurah'] as int,
              numberInQuran: u['number'] as int,
              surahNumber: surahNumber,
              textUthmani: u['text'] as String,
              translationEnglish: en,
              translationUrdu: ur,
              juz: u['juz'] as int? ?? 1,
              page: u['page'] as int? ?? 1,
            );
            result.add(ayah);

            cacheList.add({
              'numberInSurah': ayah.numberInSurah,
              'numberInQuran': ayah.numberInQuran,
              'textUthmani': ayah.textUthmani,
              'translationEnglish': ayah.translationEnglish,
              'translationUrdu': ayah.translationUrdu,
              'juz': ayah.juz,
              'page': ayah.page,
            });
          }

          // Cache on device for offline reading
          await QuranStorageService.cacheSurahData(surahNumber, 'uthmani_en_ur', {'ayahs': cacheList});
          return result;
        }
      }
    } catch (_) {
      // Fallback seamlessly to bundled Tanzil data
    }

    // 3. Bundled Tanzil fallback
    return TanzilQuranData.getBundledAyahs(surahNumber);
  }

  static List<AyahModel> _parseAyahsFromCache(List<dynamic> list, int surahNumber) {
    return list.map((item) {
      final map = item as Map<String, dynamic>;
      return AyahModel(
        numberInSurah: map['numberInSurah'] as int,
        numberInQuran: map['numberInQuran'] as int,
        surahNumber: surahNumber,
        textUthmani: map['textUthmani'] as String,
        translationEnglish: map['translationEnglish'] as String,
        translationUrdu: map['translationUrdu'] as String? ?? '',
        juz: map['juz'] as int? ?? 1,
        page: map['page'] as int? ?? 1,
      );
    }).toList();
  }
}
