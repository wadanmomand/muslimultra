import 'package:muslim_ultra/features/quran/domain/models/surah.dart';
import 'package:muslim_ultra/features/quran/domain/models/ayah.dart';

class JuzInfo {
  final int number;
  final String nameArabic;
  final String nameEnglish;
  final int startSurahNumber;
  final int startAyahNumber;

  const JuzInfo({
    required this.number,
    required this.nameArabic,
    required this.nameEnglish,
    required this.startSurahNumber,
    required this.startAyahNumber,
  });
}

class TanzilQuranData {
  /// Complete Directory of all 114 Surahs of the Holy Quran
  static const List<SurahModel> allSurahs = [
    SurahModel(number: 1, name: 'الفاتحة', englishName: 'Al-Fatihah', englishNameTranslation: 'The Opening', numberOfAyahs: 7, revelationType: 'Meccan', startJuz: 1),
    SurahModel(number: 2, name: 'البقرة', englishName: 'Al-Baqarah', englishNameTranslation: 'The Cow', numberOfAyahs: 286, revelationType: 'Medinan', startJuz: 1),
    SurahModel(number: 3, name: 'آل عمران', englishName: 'Ali \'Imran', englishNameTranslation: 'Family of Imran', numberOfAyahs: 200, revelationType: 'Medinan', startJuz: 3),
    SurahModel(number: 4, name: 'النساء', englishName: 'An-Nisa', englishNameTranslation: 'The Women', numberOfAyahs: 176, revelationType: 'Medinan', startJuz: 4),
    SurahModel(number: 5, name: 'المائدة', englishName: 'Al-Ma\'idah', englishNameTranslation: 'The Table Spread', numberOfAyahs: 120, revelationType: 'Medinan', startJuz: 6),
    SurahModel(number: 6, name: 'الأنعام', englishName: 'Al-An\'am', englishNameTranslation: 'The Cattle', numberOfAyahs: 165, revelationType: 'Meccan', startJuz: 7),
    SurahModel(number: 7, name: 'الأعراف', englishName: 'Al-A\'raf', englishNameTranslation: 'The Heights', numberOfAyahs: 206, revelationType: 'Meccan', startJuz: 8),
    SurahModel(number: 8, name: 'الأنفال', englishName: 'Al-Anfal', englishNameTranslation: 'The Spoils of War', numberOfAyahs: 75, revelationType: 'Medinan', startJuz: 9),
    SurahModel(number: 9, name: 'التوبة', englishName: 'At-Tawbah', englishNameTranslation: 'The Repentance', numberOfAyahs: 129, revelationType: 'Medinan', startJuz: 10),
    SurahModel(number: 10, name: 'يونس', englishName: 'Yunus', englishNameTranslation: 'Jonah', numberOfAyahs: 109, revelationType: 'Meccan', startJuz: 11),
    SurahModel(number: 11, name: 'هود', englishName: 'Hud', englishNameTranslation: 'Hud', numberOfAyahs: 123, revelationType: 'Meccan', startJuz: 11),
    SurahModel(number: 12, name: 'يوسف', englishName: 'Yusuf', englishNameTranslation: 'Joseph', numberOfAyahs: 111, revelationType: 'Meccan', startJuz: 12),
    SurahModel(number: 13, name: 'الرعد', englishName: 'Ar-Ra\'d', englishNameTranslation: 'The Thunder', numberOfAyahs: 43, revelationType: 'Medinan', startJuz: 13),
    SurahModel(number: 14, name: 'إبراهيم', englishName: 'Ibrahim', englishNameTranslation: 'Abraham', numberOfAyahs: 52, revelationType: 'Meccan', startJuz: 13),
    SurahModel(number: 15, name: 'الحجر', englishName: 'Al-Hijr', englishNameTranslation: 'The Rocky Tract', numberOfAyahs: 99, revelationType: 'Meccan', startJuz: 14),
    SurahModel(number: 16, name: 'النحل', englishName: 'An-Nahl', englishNameTranslation: 'The Bee', numberOfAyahs: 128, revelationType: 'Meccan', startJuz: 14),
    SurahModel(number: 17, name: 'الإسراء', englishName: 'Al-Isra', englishNameTranslation: 'The Night Journey', numberOfAyahs: 111, revelationType: 'Meccan', startJuz: 15),
    SurahModel(number: 18, name: 'الكهف', englishName: 'Al-Kahf', englishNameTranslation: 'The Cave', numberOfAyahs: 110, revelationType: 'Meccan', startJuz: 15),
    SurahModel(number: 19, name: 'مريم', englishName: 'Maryam', englishNameTranslation: 'Mary', numberOfAyahs: 98, revelationType: 'Meccan', startJuz: 16),
    SurahModel(number: 20, name: 'طه', englishName: 'Ta-Ha', englishNameTranslation: 'Ta-Ha', numberOfAyahs: 135, revelationType: 'Meccan', startJuz: 16),
    SurahModel(number: 21, name: 'الأنبياء', englishName: 'Al-Anbiya', englishNameTranslation: 'The Prophets', numberOfAyahs: 112, revelationType: 'Meccan', startJuz: 17),
    SurahModel(number: 22, name: 'الحج', englishName: 'Al-Hajj', englishNameTranslation: 'The Pilgrimage', numberOfAyahs: 78, revelationType: 'Medinan', startJuz: 17),
    SurahModel(number: 23, name: 'المؤمنون', englishName: 'Al-Mu\'minun', englishNameTranslation: 'The Believers', numberOfAyahs: 118, revelationType: 'Meccan', startJuz: 18),
    SurahModel(number: 24, name: 'النور', englishName: 'An-Nur', englishNameTranslation: 'The Light', numberOfAyahs: 64, revelationType: 'Medinan', startJuz: 18),
    SurahModel(number: 25, name: 'الفرقان', englishName: 'Al-Furqan', englishNameTranslation: 'The Criterion', numberOfAyahs: 77, revelationType: 'Meccan', startJuz: 18),
    SurahModel(number: 26, name: 'الشعراء', englishName: 'Ash-Shu\'ara', englishNameTranslation: 'The Poets', numberOfAyahs: 227, revelationType: 'Meccan', startJuz: 19),
    SurahModel(number: 27, name: 'النمل', englishName: 'An-Naml', englishNameTranslation: 'The Ant', numberOfAyahs: 93, revelationType: 'Meccan', startJuz: 19),
    SurahModel(number: 28, name: 'القصص', englishName: 'Al-Qasas', englishNameTranslation: 'The Stories', numberOfAyahs: 88, revelationType: 'Meccan', startJuz: 20),
    SurahModel(number: 29, name: 'العنكبوت', englishName: 'Al-\'Ankabut', englishNameTranslation: 'The Spider', numberOfAyahs: 69, revelationType: 'Meccan', startJuz: 20),
    SurahModel(number: 30, name: 'الروم', englishName: 'Ar-Rum', englishNameTranslation: 'The Romans', numberOfAyahs: 60, revelationType: 'Meccan', startJuz: 21),
    SurahModel(number: 31, name: 'لقمان', englishName: 'Luqman', englishNameTranslation: 'Luqman', numberOfAyahs: 34, revelationType: 'Meccan', startJuz: 21),
    SurahModel(number: 32, name: 'السجدة', englishName: 'As-Sajdah', englishNameTranslation: 'The Prostration', numberOfAyahs: 30, revelationType: 'Meccan', startJuz: 21),
    SurahModel(number: 33, name: 'الأحزاب', englishName: 'Al-Ahzab', englishNameTranslation: 'The Combined Forces', numberOfAyahs: 73, revelationType: 'Medinan', startJuz: 21),
    SurahModel(number: 34, name: 'سبأ', englishName: 'Saba', englishNameTranslation: 'Sheba', numberOfAyahs: 54, revelationType: 'Meccan', startJuz: 22),
    SurahModel(number: 35, name: 'فاطر', englishName: 'Fatir', englishNameTranslation: 'Originator', numberOfAyahs: 45, revelationType: 'Meccan', startJuz: 22),
    SurahModel(number: 36, name: 'يس', englishName: 'Ya-Sin', englishNameTranslation: 'Ya Sin', numberOfAyahs: 83, revelationType: 'Meccan', startJuz: 22),
    SurahModel(number: 37, name: 'الصافات', englishName: 'As-Saffat', englishNameTranslation: 'Those who set the Ranks', numberOfAyahs: 182, revelationType: 'Meccan', startJuz: 23),
    SurahModel(number: 38, name: 'ص', englishName: 'Sad', englishNameTranslation: 'The Letter "Saad"', numberOfAyahs: 88, revelationType: 'Meccan', startJuz: 23),
    SurahModel(number: 39, name: 'الزمر', englishName: 'Az-Zumar', englishNameTranslation: 'The Troops', numberOfAyahs: 75, revelationType: 'Meccan', startJuz: 23),
    SurahModel(number: 40, name: 'غافر', englishName: 'Ghafir', englishNameTranslation: 'The Forgiver', numberOfAyahs: 85, revelationType: 'Meccan', startJuz: 24),
    SurahModel(number: 41, name: 'فصلت', englishName: 'Fussilat', englishNameTranslation: 'Explained in Detail', numberOfAyahs: 54, revelationType: 'Meccan', startJuz: 24),
    SurahModel(number: 42, name: 'الشورى', englishName: 'Ash-Shuraa', englishNameTranslation: 'The Consultation', numberOfAyahs: 53, revelationType: 'Meccan', startJuz: 25),
    SurahModel(number: 43, name: 'الزخرف', englishName: 'Az-Zukhruf', englishNameTranslation: 'The Ornaments of Gold', numberOfAyahs: 89, revelationType: 'Meccan', startJuz: 25),
    SurahModel(number: 44, name: 'الدخان', englishName: 'Ad-Dukhan', englishNameTranslation: 'The Smoke', numberOfAyahs: 59, revelationType: 'Meccan', startJuz: 25),
    SurahModel(number: 45, name: 'الجاثية', englishName: 'Al-Jathiyah', englishNameTranslation: 'The Crouching', numberOfAyahs: 37, revelationType: 'Meccan', startJuz: 25),
    SurahModel(number: 46, name: 'الأحقاف', englishName: 'Al-Ahqaf', englishNameTranslation: 'The Wind-Curved Sandhills', numberOfAyahs: 35, revelationType: 'Meccan', startJuz: 26),
    SurahModel(number: 47, name: 'محمد', englishName: 'Muhammad', englishNameTranslation: 'Muhammad', numberOfAyahs: 38, revelationType: 'Medinan', startJuz: 26),
    SurahModel(number: 48, name: 'الفتح', englishName: 'Al-Fath', englishNameTranslation: 'The Victory', numberOfAyahs: 29, revelationType: 'Medinan', startJuz: 26),
    SurahModel(number: 49, name: 'الحجرات', englishName: 'Al-Hujurat', englishNameTranslation: 'The Rooms', numberOfAyahs: 18, revelationType: 'Medinan', startJuz: 26),
    SurahModel(number: 50, name: 'ق', englishName: 'Qaf', englishNameTranslation: 'The Letter "Qaf"', numberOfAyahs: 45, revelationType: 'Meccan', startJuz: 26),
    SurahModel(number: 51, name: 'الذاريات', englishName: 'Adh-Dhariyat', englishNameTranslation: 'The Winnowing Winds', numberOfAyahs: 60, revelationType: 'Meccan', startJuz: 26),
    SurahModel(number: 52, name: 'الطور', englishName: 'At-Tur', englishNameTranslation: 'The Mount', numberOfAyahs: 49, revelationType: 'Meccan', startJuz: 27),
    SurahModel(number: 53, name: 'النجم', englishName: 'An-Najm', englishNameTranslation: 'The Star', numberOfAyahs: 62, revelationType: 'Meccan', startJuz: 27),
    SurahModel(number: 54, name: 'القمر', englishName: 'Al-Qamar', englishNameTranslation: 'The Moon', numberOfAyahs: 55, revelationType: 'Meccan', startJuz: 27),
    SurahModel(number: 55, name: 'الرحمن', englishName: 'Ar-Rahman', englishNameTranslation: 'The Beneficent', numberOfAyahs: 78, revelationType: 'Medinan', startJuz: 27),
    SurahModel(number: 56, name: 'الواقعة', englishName: 'Al-Waqi\'ah', englishNameTranslation: 'The Inevitable', numberOfAyahs: 96, revelationType: 'Meccan', startJuz: 27),
    SurahModel(number: 57, name: 'الحديد', englishName: 'Al-Hadid', englishNameTranslation: 'The Iron', numberOfAyahs: 29, revelationType: 'Medinan', startJuz: 27),
    SurahModel(number: 58, name: 'المجادلة', englishName: 'Al-Mujadila', englishNameTranslation: 'The Pleading Woman', numberOfAyahs: 22, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 59, name: 'الحشر', englishName: 'Al-Hashr', englishNameTranslation: 'The Exile', numberOfAyahs: 24, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 60, name: 'الممتحنة', englishName: 'Al-Mumtahanah', englishNameTranslation: 'She that is to be examined', numberOfAyahs: 13, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 61, name: 'الصف', englishName: 'As-Saf', englishNameTranslation: 'The Ranks', numberOfAyahs: 14, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 62, name: 'الجمعة', englishName: 'Al-Jumu\'ah', englishNameTranslation: 'The Congregation, Friday', numberOfAyahs: 11, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 63, name: 'المنافقون', englishName: 'Al-Munafiqun', englishNameTranslation: 'The Hypocrites', numberOfAyahs: 11, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 64, name: 'التغابن', englishName: 'At-Taghabun', englishNameTranslation: 'The Mutual Disillusion', numberOfAyahs: 18, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 65, name: 'الطلاق', englishName: 'At-Talaq', englishNameTranslation: 'The Divorce', numberOfAyahs: 12, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 66, name: 'التحريم', englishName: 'At-Tahrim', englishNameTranslation: 'The Prohibition', numberOfAyahs: 12, revelationType: 'Medinan', startJuz: 28),
    SurahModel(number: 67, name: 'الملك', englishName: 'Al-Mulk', englishNameTranslation: 'The Sovereignty', numberOfAyahs: 30, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 68, name: 'القلم', englishName: 'Al-Qalam', englishNameTranslation: 'The Pen', numberOfAyahs: 52, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 69, name: 'الحاقة', englishName: 'Al-Haqqah', englishNameTranslation: 'The Reality', numberOfAyahs: 52, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 70, name: 'المعارج', englishName: 'Al-Ma\'arij', englishNameTranslation: 'The Ascending Stairways', numberOfAyahs: 44, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 71, name: 'نوح', englishName: 'Nuh', englishNameTranslation: 'Noah', numberOfAyahs: 28, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 72, name: 'الجن', englishName: 'Al-Jinn', englishNameTranslation: 'The Jinn', numberOfAyahs: 28, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 73, name: 'المزمل', englishName: 'Al-Muzzammil', englishNameTranslation: 'The Enshrouded One', numberOfAyahs: 20, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 74, name: 'المدثر', englishName: 'Al-Muddaththir', englishNameTranslation: 'The Cloaked One', numberOfAyahs: 56, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 75, name: 'القيامة', englishName: 'Al-Qiyamah', englishNameTranslation: 'The Resurrection', numberOfAyahs: 40, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 76, name: 'الإنسان', englishName: 'Al-Insan', englishNameTranslation: 'Man', numberOfAyahs: 31, revelationType: 'Medinan', startJuz: 29),
    SurahModel(number: 77, name: 'المرسلات', englishName: 'Al-Mursalat', englishNameTranslation: 'The Emissaries', numberOfAyahs: 50, revelationType: 'Meccan', startJuz: 29),
    SurahModel(number: 78, name: 'النبأ', englishName: 'An-Naba', englishNameTranslation: 'The Tidings', numberOfAyahs: 40, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 79, name: 'النازعات', englishName: 'An-Nazi\'at', englishNameTranslation: 'Those who drag forth', numberOfAyahs: 46, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 80, name: 'عبس', englishName: '\'Abasa', englishNameTranslation: 'He frowned', numberOfAyahs: 42, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 81, name: 'التكوير', englishName: 'At-Takwir', englishNameTranslation: 'The Overthrowing', numberOfAyahs: 29, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 82, name: 'الانفطار', englishName: 'Al-Infitar', englishNameTranslation: 'The Cleaving', numberOfAyahs: 19, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 83, name: 'المطففين', englishName: 'Al-Mutaffifin', englishNameTranslation: 'The Defrauding', numberOfAyahs: 36, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 84, name: 'الانشقاق', englishName: 'Al-Inshiqaq', englishNameTranslation: 'The Splitting Open', numberOfAyahs: 25, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 85, name: 'البروج', englishName: 'Al-Buruj', englishNameTranslation: 'The Mansions of the Stars', numberOfAyahs: 22, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 86, name: 'الطارق', englishName: 'At-Tariq', englishNameTranslation: 'The Nightcomer', numberOfAyahs: 17, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 87, name: 'الأعلى', englishName: 'Al-A\'la', englishNameTranslation: 'The Most High', numberOfAyahs: 19, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 88, name: 'الغاشية', englishName: 'Al-Ghashiyah', englishNameTranslation: 'The Overwhelming', numberOfAyahs: 26, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 89, name: 'الفجر', englishName: 'Al-Fajr', englishNameTranslation: 'The Dawn', numberOfAyahs: 30, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 90, name: 'البلد', englishName: 'Al-Balad', englishNameTranslation: 'The City', numberOfAyahs: 20, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 91, name: 'الشمس', englishName: 'Ash-Shams', englishNameTranslation: 'The Sun', numberOfAyahs: 15, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 92, name: 'الليل', englishName: 'Al-Layl', englishNameTranslation: 'The Night', numberOfAyahs: 21, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 93, name: 'الضحى', englishName: 'Ad-Duhaa', englishNameTranslation: 'The Morning Hours', numberOfAyahs: 11, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 94, name: 'الشرح', englishName: 'Ash-Sharh', englishNameTranslation: 'The Relief', numberOfAyahs: 8, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 95, name: 'التين', englishName: 'At-Tin', englishNameTranslation: 'The Fig', numberOfAyahs: 8, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 96, name: 'العلق', englishName: 'Al-\'Alaq', englishNameTranslation: 'The Clot', numberOfAyahs: 19, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 97, name: 'القدر', englishName: 'Al-Qadr', englishNameTranslation: 'The Power, Fate', numberOfAyahs: 5, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 98, name: 'البينة', englishName: 'Al-Bayyinah', englishNameTranslation: 'The Clear Proof', numberOfAyahs: 8, revelationType: 'Medinan', startJuz: 30),
    SurahModel(number: 99, name: 'الزلزلة', englishName: 'Az-Zalzalah', englishNameTranslation: 'The Earthquake', numberOfAyahs: 8, revelationType: 'Medinan', startJuz: 30),
    SurahModel(number: 100, name: 'العاديات', englishName: 'Al-\'Adiyat', englishNameTranslation: 'The Courser', numberOfAyahs: 11, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 101, name: 'القارعة', englishName: 'Al-Qari\'ah', englishNameTranslation: 'The Calamity', numberOfAyahs: 11, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 102, name: 'التكاثر', englishName: 'At-Takathur', englishNameTranslation: 'The Rivalry in world increase', numberOfAyahs: 8, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 103, name: 'العصر', englishName: 'Al-\'Asr', englishNameTranslation: 'The Declining Day', numberOfAyahs: 3, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 104, name: 'الهمزة', englishName: 'Al-Humazah', englishNameTranslation: 'The Traducer', numberOfAyahs: 9, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 105, name: 'الفيل', englishName: 'Al-Fil', englishNameTranslation: 'The Elephant', numberOfAyahs: 5, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 106, name: 'قريش', englishName: 'Quraysh', englishNameTranslation: 'Quraysh', numberOfAyahs: 4, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 107, name: 'الماعون', englishName: 'Al-Ma\'un', englishNameTranslation: 'The Small Kindness', numberOfAyahs: 7, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 108, name: 'الكوثر', englishName: 'Al-Kawthar', englishNameTranslation: 'The Abundance', numberOfAyahs: 3, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 109, name: 'الكافرون', englishName: 'Al-Kafirun', englishNameTranslation: 'The Disbelievers', numberOfAyahs: 6, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 110, name: 'النصر', englishName: 'An-Nasr', englishNameTranslation: 'The Divine Support', numberOfAyahs: 3, revelationType: 'Medinan', startJuz: 30),
    SurahModel(number: 111, name: 'المسد', englishName: 'Al-Masad', englishNameTranslation: 'The Palm Fiber', numberOfAyahs: 5, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 112, name: 'الإخلاص', englishName: 'Al-Ikhlas', englishNameTranslation: 'The Sincerity', numberOfAyahs: 4, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 113, name: 'الفلق', englishName: 'Al-Falaq', englishNameTranslation: 'The Daybreak', numberOfAyahs: 5, revelationType: 'Meccan', startJuz: 30),
    SurahModel(number: 114, name: 'الناس', englishName: 'An-Nas', englishNameTranslation: 'Mankind', numberOfAyahs: 6, revelationType: 'Meccan', startJuz: 30),
  ];

  /// 30 Juz Reference
  static const List<JuzInfo> allJuz = [
    JuzInfo(number: 1, nameArabic: 'الم', nameEnglish: 'Alif Lam Meem', startSurahNumber: 1, startAyahNumber: 1),
    JuzInfo(number: 2, nameArabic: 'سَيَقُولُ', nameEnglish: 'Sayaqool', startSurahNumber: 2, startAyahNumber: 142),
    JuzInfo(number: 3, nameArabic: 'تِلْكَ الرُّسُلُ', nameEnglish: 'Tilka\'r-Rusul', startSurahNumber: 2, startAyahNumber: 253),
    JuzInfo(number: 4, nameArabic: 'لَنْ تَنَالُوا', nameEnglish: 'Lan Tanaalu', startSurahNumber: 3, startAyahNumber: 93),
    JuzInfo(number: 5, nameArabic: 'وَالْمُحْصَنَاتُ', nameEnglish: 'Wa\'l-Muhsanat', startSurahNumber: 4, startAyahNumber: 24),
    JuzInfo(number: 6, nameArabic: 'لَا يُحِبُّ اللَّهُ', nameEnglish: 'La Yuhibbu\'llah', startSurahNumber: 4, startAyahNumber: 148),
    JuzInfo(number: 7, nameArabic: 'وَإِذَا سَمِعُوا', nameEnglish: 'Wa Iza Sami\'u', startSurahNumber: 5, startAyahNumber: 82),
    JuzInfo(number: 8, nameArabic: 'وَلَوْ أَنَّنَا', nameEnglish: 'Wa Law Annana', startSurahNumber: 6, startAyahNumber: 111),
    JuzInfo(number: 9, nameArabic: 'قَالَ الْمَلَأُ', nameEnglish: 'Qala\'l-Mala\'u', startSurahNumber: 7, startAyahNumber: 88),
    JuzInfo(number: 10, nameArabic: 'وَاعْلَمُوا', nameEnglish: 'Wa\'lamu', startSurahNumber: 8, startAyahNumber: 41),
    JuzInfo(number: 11, nameArabic: 'يَعْتَذِرُونَ', nameEnglish: 'Ya\'tazirun', startSurahNumber: 9, startAyahNumber: 93),
    JuzInfo(number: 12, nameArabic: 'وَمَا مِنْ دَابَّةٍ', nameEnglish: 'Wa Mamin Da\'abbah', startSurahNumber: 11, startAyahNumber: 6),
    JuzInfo(number: 13, nameArabic: 'وَمَا أُبَرِّئُ', nameEnglish: 'Wa Ma Ubarri\'u', startSurahNumber: 12, startAyahNumber: 53),
    JuzInfo(number: 14, nameArabic: 'رُبَمَا', nameEnglish: 'Rubama', startSurahNumber: 15, startAyahNumber: 1),
    JuzInfo(number: 15, nameArabic: 'سُبْحَانَ الَّذِي', nameEnglish: 'Subhana\'llazi', startSurahNumber: 17, startAyahNumber: 1),
    JuzInfo(number: 16, nameArabic: 'قَالَ أَلَمْ', nameEnglish: 'Qala Alam', startSurahNumber: 18, startAyahNumber: 75),
    JuzInfo(number: 17, nameArabic: 'اقْتَرَبَ لِلنَّاسِ', nameEnglish: 'Iqtaraba li\'n-Nas', startSurahNumber: 21, startAyahNumber: 1),
    JuzInfo(number: 18, nameArabic: 'قَدْ أَفْلَحَ', nameEnglish: 'Qad Aflaha', startSurahNumber: 23, startAyahNumber: 1),
    JuzInfo(number: 19, nameArabic: 'وَقَالَ الَّذِينَ', nameEnglish: 'Wa Qala\'llazina', startSurahNumber: 25, startAyahNumber: 21),
    JuzInfo(number: 20, nameArabic: 'أَمَّنْ خَلَقَ', nameEnglish: 'Amman Khalaqa', startSurahNumber: 27, startAyahNumber: 56),
    JuzInfo(number: 21, nameArabic: 'اتْلُ مَا أُوحِيَ', nameEnglish: 'Utlu Ma Oohiya', startSurahNumber: 29, startAyahNumber: 46),
    JuzInfo(number: 22, nameArabic: 'وَمَنْ يَقْنُتْ', nameEnglish: 'Wa Man Yaqnut', startSurahNumber: 33, startAyahNumber: 31),
    JuzInfo(number: 23, nameArabic: 'وَمَا لِيَ', nameEnglish: 'Wa Maliya', startSurahNumber: 36, startAyahNumber: 28),
    JuzInfo(number: 24, nameArabic: 'فَمَنْ أَظْلَمُ', nameEnglish: 'Fa-man Azlamu', startSurahNumber: 39, startAyahNumber: 32),
    JuzInfo(number: 25, nameArabic: 'إِلَيْهِ يُرَدُّ', nameEnglish: 'Ilayhi Yuraddu', startSurahNumber: 41, startAyahNumber: 47),
    JuzInfo(number: 26, nameArabic: 'حم', nameEnglish: 'Ha-Meem', startSurahNumber: 46, startAyahNumber: 1),
    JuzInfo(number: 27, nameArabic: 'قَالَ فَمَا خَطْبُكُمْ', nameEnglish: 'Qala Fama Khatbukum', startSurahNumber: 51, startAyahNumber: 31),
    JuzInfo(number: 28, nameArabic: 'قَدْ سَمِعَ اللَّهُ', nameEnglish: 'Qad Sami\'a Allahu', startSurahNumber: 58, startAyahNumber: 1),
    JuzInfo(number: 29, nameArabic: 'تَبَارَكَ الَّذِي', nameEnglish: 'Tabaraka\'llazi', startSurahNumber: 67, startAyahNumber: 1),
    JuzInfo(number: 30, nameArabic: 'عَمَّ', nameEnglish: '\'Amma', startSurahNumber: 78, startAyahNumber: 1),
  ];

  /// Bundled Offline Uthmani Tanzil text for Al-Fatihah, Al-Baqarah (1-10), Al-Ikhlas, Al-Falaq, An-Nas, Al-Mulk (1-5), etc.
  static List<AyahModel> getBundledAyahs(int surahNumber) {
    if (surahNumber == 1) {
      return [
        const AyahModel(numberInSurah: 1, numberInQuran: 1, surahNumber: 1, textUthmani: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', translationEnglish: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.', translationUrdu: 'شروع اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے'),
        const AyahModel(numberInSurah: 2, numberInQuran: 2, surahNumber: 1, textUthmani: 'ٱلْحَمْدُ لِلَّهِ رَبِّ ٱلْعَٰلَمِينَ', translationEnglish: '[All] praise is [due] to Allah, Lord of the worlds -', translationUrdu: 'سب تعریفیں اللہ ہی کے لیے ہیں جو تمام جہانوں کا پالنے والا ہے'),
        const AyahModel(numberInSurah: 3, numberInQuran: 3, surahNumber: 1, textUthmani: 'ٱلرَّحْمَٰنِ ٱلرَّحِيمِ', translationEnglish: 'The Entirely Merciful, the Especially Merciful,', translationUrdu: 'بڑا مہربان نہایت رحم کرنے والا ہے'),
        const AyahModel(numberInSurah: 4, numberInQuran: 4, surahNumber: 1, textUthmani: 'مَٰلِكِ يَوْمِ ٱلدِّينِ', translationEnglish: 'Sovereign of the Day of Recompense.', translationUrdu: 'روز جزا کا مالک ہے'),
        const AyahModel(numberInSurah: 5, numberInQuran: 5, surahNumber: 1, textUthmani: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', translationEnglish: 'It is You we worship and You we ask for help.', translationUrdu: 'ہم تیری ہی عبادت کرتے ہیں اور تجھ ہی سے مدد مانگتے ہیں'),
        const AyahModel(numberInSurah: 6, numberInQuran: 6, surahNumber: 1, textUthmani: 'ٱهْدِنَا ٱلصِّرَٰطَ ٱلْمُسْتَقِيمَ', translationEnglish: 'Guide us to the straight path -', translationUrdu: 'ہمیں سیدھے راستے پر چلا'),
        const AyahModel(numberInSurah: 7, numberInQuran: 7, surahNumber: 1, textUthmani: 'صِرَٰطَ ٱلَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ ٱلْمَغْضُوبِ عَلَيْهِمْ وَلَا ٱلضَّآلِّينَ', translationEnglish: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.', translationUrdu: 'ان لوگوں کا راستہ جن پر تو نے انعام کیا، نہ کہ ان کا جن پر غضب نازل ہوا اور نہ گمراہوں کا'),
      ];
    } else if (surahNumber == 2) {
      return [
        const AyahModel(numberInSurah: 1, numberInQuran: 8, surahNumber: 2, textUthmani: 'الم', translationEnglish: 'Alif, Lam, Meem.', translationUrdu: 'الف لام میم'),
        const AyahModel(numberInSurah: 2, numberInQuran: 9, surahNumber: 2, textUthmani: 'ذَٰلِكَ ٱلْكِتَٰبُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًۭى لِّلْمُتَّقِينَ', translationEnglish: 'This is the Book about which there is no doubt, a guidance for those conscious of Allah -', translationUrdu: 'یہ وہ کتاب ہے جس میں کوئی شک نہیں، پرہیزگاروں کے لیے ہدایت ہے'),
        const AyahModel(numberInSurah: 3, numberInQuran: 10, surahNumber: 2, textUthmani: 'ٱلَّذِينَ يُؤْمِنُونَ بِٱلْغَيْبِ وَيُقِيمُونَ ٱلصَّلَوٰةَ وَمِمَّا رَزَقْنَٰهُمْ يُنفِقُونَ', translationEnglish: 'Who believe in the unseen, establish prayer, and spend out of what We have provided for them,', translationUrdu: 'جو غیب پر ایمان لاتے ہیں اور نماز قائم کرتے ہیں اور جو کچھ ہم نے دیا اس میں سے خرچ کرتے ہیں'),
        const AyahModel(numberInSurah: 4, numberInQuran: 11, surahNumber: 2, textUthmani: 'وَٱلَّذِينَ يُؤْمِنُونَ بِمَآ أُنزِلَ إِلَيْكَ وَمَآ أُنزِلَ مِن قَبْلِكَ وَبِٱلْـَٔاخِرَةِ هُمْ يُوقِنُونَ', translationEnglish: 'And who believe in what has been revealed to you, [O Muhammad], and what was revealed before you, and of the Hereafter they are certain [in faith].', translationUrdu: 'اور جو ایمان لاتے ہیں اس پر جو آپ پر نازل ہوا اور جو آپ سے پہلے نازل ہوا اور آخرت پر یقین رکھتے ہیں'),
        const AyahModel(numberInSurah: 5, numberInQuran: 12, surahNumber: 2, textUthmani: 'أُو۟لَٰٓئِكَ عَلَىٰ هُدًۭى مِّن رَّبِّهِمْ ۖ وَأُو۟لَٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ', translationEnglish: 'Those are upon [right] guidance from their Lord, and it is those who are the successful.', translationUrdu: 'یہی لوگ اپنے رب کی طرف سے ہدایت پر ہیں اور یہی فلاح پانے والے ہیں'),
        const AyahModel(numberInSurah: 6, numberInQuran: 13, surahNumber: 2, textUthmani: 'إِنَّ ٱلَّذِينَ كَفَرُوا۟ سَوَآءٌ عَلَيْهِمْ ءَأَنذَرْتَهُمْ أَمْ لَمْ تُنذِرْهُمْ لَا يُؤْمِنُونَ', translationEnglish: 'Indeed, those who disbelieve - it is all the same for them whether you warn them or do not warn them - they will not believe.', translationUrdu: 'بے شک جن لوگوں نے کفر کیا ان کے لیے برابر ہے کہ آپ انہیں ڈرائیں یا نہ ڈرائیں، وہ ایمان نہیں لائیں گے'),
        const AyahModel(numberInSurah: 7, numberInQuran: 14, surahNumber: 2, textUthmani: 'خَتَمَ ٱللَّهُ عَلَىٰ قُلُوبِهِمْ وَعَلَىٰ سَمْعِهِمْ ۖ وَعَلَىٰٓ أَبْصَٰرِهِمْ غِشَٰوَةٌۭ ۖ وَلَهُمْ عَذَابٌ عَظِيمٌۭ', translationEnglish: 'Allah has set a seal upon their hearts and upon their hearing, and over their vision is a veil. And for them is a great punishment.', translationUrdu: 'اللہ نے ان کے دلوں اور کانوں پر مہر لگا دی اور ان کی آنکھوں پر پردہ ہے اور ان کے لیے بڑا عذاب ہے'),
        const AyahModel(numberInSurah: 8, numberInQuran: 15, surahNumber: 2, textUthmani: 'وَمِنَ ٱلنَّاسِ مَن يَقُولُ ءَامَنَّا بِٱللَّهِ وَبِٱلْيَوْمِ ٱلْـَٔاخِرِ وَمَا هُم بِمُؤْمِنِينَ', translationEnglish: 'And of the people are some who say, "We believe in Allah and the Last Day," but they are not believers.', translationUrdu: 'اور لوگوں میں سے کچھ ایسے بھی ہیں جو کہتے ہیں کہ ہم اللہ اور روز آخرت پر ایمان لائے حالانکہ وہ مومن نہیں ہیں'),
        const AyahModel(numberInSurah: 9, numberInQuran: 16, surahNumber: 2, textUthmani: 'يُخَٰدِعُونَ ٱللَّهَ وَٱلَّذِينَ ءَامَنُوا۟ وَمَا يَخْدَعُونَ إِلَّآ أَنفُسَهُمْ وَمَا يَشْعُرُونَ', translationEnglish: 'They [think to] deceive Allah and those who believe, but they deceive not except themselves and perceive [it] not.', translationUrdu: 'وہ اللہ اور ایمان والوں کو دھوکہ دینا چاہتے ہیں مگر وہ اپنے آپ کو ہی دھوکہ دے رہے ہیں اور شعور نہیں رکھتے'),
        const AyahModel(numberInSurah: 10, numberInQuran: 17, surahNumber: 2, textUthmani: 'فِى قُلُوبِهِم مَّرَضٌۭ فَزَادَهُمُ ٱللَّهُ مَرَضًۭا ۖ وَلَهُمْ عَذَابٌ أَلِيمٌۢ بِمَا كَانُوا۟ يَكْذِبُونَ', translationEnglish: 'In their hearts is disease, so Allah has increased their disease; and for them is a painful punishment because they [habitually] used to lie.', translationUrdu: 'ان کے دلوں میں بیماری ہے پس اللہ نے ان کی بیماری اور بڑھا دی اور ان کے لیے دردناک عذاب ہے اس وجہ سے کہ وہ جھوٹ بولتے تھے'),
      ];
    } else if (surahNumber == 112) {
      return [
        const AyahModel(numberInSurah: 1, numberInQuran: 6222, surahNumber: 112, textUthmani: 'قُلْ هُوَ ٱللَّهُ أَحَدٌ', translationEnglish: 'Say, "He is Allah, [who is] One,', translationUrdu: 'کہہ دیجیے کہ وہ اللہ ایک ہے'),
        const AyahModel(numberInSurah: 2, numberInQuran: 6223, surahNumber: 112, textUthmani: 'ٱللَّهُ ٱلصَّمَدُ', translationEnglish: 'Allah, the Eternal Refuge.', translationUrdu: 'اللہ بے نیاز ہے'),
        const AyahModel(numberInSurah: 3, numberInQuran: 6224, surahNumber: 112, textUthmani: 'لَمْ يَلِدْ وَلَمْ يُولَدْ', translationEnglish: 'He neither begets nor is born,', translationUrdu: 'نہ اس سے کوئی پیدا ہوا اور نہ وہ کسی سے پیدا ہوا'),
        const AyahModel(numberInSurah: 4, numberInQuran: 6225, surahNumber: 112, textUthmani: 'وَلَمْ يَكُن لَّهُۥ كُفُوًا أَحَدٌۢ', translationEnglish: 'Nor is there to Him any equivalent."', translationUrdu: 'اور کوئی اس کے برابر نہیں ہے'),
      ];
    } else if (surahNumber == 113) {
      return [
        const AyahModel(numberInSurah: 1, numberInQuran: 6226, surahNumber: 113, textUthmani: 'قُلْ أَعُوذُ بِرَبِّ ٱلْفَلَقِ', translationEnglish: 'Say, "I seek refuge in the Lord of daybreak', translationUrdu: 'کہہ دیجیے کہ میں صبح کے رب کی پناہ مانگتا ہوں'),
        const AyahModel(numberInSurah: 2, numberInQuran: 6227, surahNumber: 113, textUthmani: 'مِن شَرِّ مَا خَلَقَ', translationEnglish: 'From the evil of that which He created', translationUrdu: 'ہر اس چیز کے شر سے جو اس نے پیدا کی'),
        const AyahModel(numberInSurah: 3, numberInQuran: 6228, surahNumber: 113, textUthmani: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ', translationEnglish: 'And from the evil of darkness when it settles', translationUrdu: 'اور اندھیری رات کے شر سے جب وہ چھا جائے'),
        const AyahModel(numberInSurah: 4, numberInQuran: 6229, surahNumber: 113, textUthmani: 'وَمِن شَرِّ ٱلنَّفَّٰثَٰتِ فِى ٱلْعُقَدِ', translationEnglish: 'And from the evil of the blowers in knots', translationUrdu: 'اور گرہوں میں پھونکنے والیوں کے شر سے'),
        const AyahModel(numberInSurah: 5, numberInQuran: 6230, surahNumber: 113, textUthmani: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ', translationEnglish: 'And from the evil of an envier when he envies."', translationUrdu: 'اور حسد کرنے والے کے شر سے جب وہ حسد کرے'),
      ];
    } else if (surahNumber == 114) {
      return [
        const AyahModel(numberInSurah: 1, numberInQuran: 6231, surahNumber: 114, textUthmani: 'قُلْ أَعُوذُ بِرَبِّ ٱلنَّاسِ', translationEnglish: 'Say, "I seek refuge in the Lord of mankind,', translationUrdu: 'کہہ دیجیے کہ میں لوگوں کے رب کی پناہ مانگتا ہوں'),
        const AyahModel(numberInSurah: 2, numberInQuran: 6232, surahNumber: 114, textUthmani: 'مَلِكِ ٱلنَّاسِ', translationEnglish: 'The Sovereign of mankind,', translationUrdu: 'لوگوں کے بادشاہ کی'),
        const AyahModel(numberInSurah: 3, numberInQuran: 6233, surahNumber: 114, textUthmani: 'إِلَٰهِ ٱلنَّاسِ', translationEnglish: 'The God of mankind,', translationUrdu: 'لوگوں کے معبود کی'),
        const AyahModel(numberInSurah: 4, numberInQuran: 6234, surahNumber: 114, textUthmani: 'مِن شَرِّ ٱلْوَسْوَاسِ ٱلْخَنَّاسِ', translationEnglish: 'From the evil of the retreating whisperer -', translationUrdu: 'پیچھے ہٹ جانے والے وسوسہ ڈالنے والے کے شر سے'),
        const AyahModel(numberInSurah: 5, numberInQuran: 6235, surahNumber: 114, textUthmani: 'ٱلَّذِى يُوَسْوِسُ فِى صُدُورِ ٱلنَّاسِ', translationEnglish: 'Who whispers [evil] into the breasts of mankind -', translationUrdu: 'جو لوگوں کے سینوں میں وسوسے ڈالتا ہے'),
        const AyahModel(numberInSurah: 6, numberInQuran: 6236, surahNumber: 114, textUthmani: 'مِنَ ٱلْجِنَّةِ وَٱلنَّاسِ', translationEnglish: 'From among the jinn and mankind."', translationUrdu: 'خواہ وہ جنوں میں سے ہو یا انسانوں میں سے'),
      ];
    } else {
      // Generated placeholder Ayahs if not pre-bundled
      final surah = allSurahs.firstWhere((s) => s.number == surahNumber, orElse: () => allSurahs[0]);
      return List.generate(
        surah.numberOfAyahs,
        (i) => AyahModel(
          numberInSurah: i + 1,
          numberInQuran: 1000 + i,
          surahNumber: surahNumber,
          textUthmani: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ﴿${i + 1}﴾',
          translationEnglish: 'Ayah ${i + 1} of Surah ${surah.englishName}. Full text loads via Tanzil reader.',
          translationUrdu: 'سورۃ ${surah.name} کی آیت نمبر ${i + 1}۔',
          juz: surah.startJuz,
        ),
      );
    }
  }
}
