/// Starter RAG Corpus for Muslim Ultra Muslim AI
/// Contains Starter Data: Juz 30 core passages, 40 authentic Duas (Hisnul Muslim),
/// and verified Islamic FAQs with classical primary source citations.
class CorpusItem {
  final String id;
  final String collection; // 'quran_juz30', 'duas_hisnul_muslim', 'faqs_corpus'
  final String reference;
  final String arabic;
  final String english;
  final String urdu;
  final List<String> tags;
  final bool isFabricatedWarning;

  const CorpusItem({
    required this.id,
    required this.collection,
    required this.reference,
    required this.arabic,
    required this.english,
    required this.urdu,
    this.tags = const [],
    this.isFabricatedWarning = false,
  });
}

class StarterCorpus {
  static const List<CorpusItem> items = [
    // =========================================================================
    // 1. AQEEDAH (CREED & FAITH)
    // =========================================================================
    CorpusItem(
      id: 'aqeedah_tawhid_1',
      collection: 'quran_juz30',
      reference: 'Quran 112:1-4',
      arabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
      english: 'Tawhid is the core foundation of Islamic belief: Allah is One, the Eternal Refuge, who neither begets nor is born, and has no equal [Quran 112:1-4].',
      urdu: 'توحید اسلامی عقیدہ کی بنیاد ہے: اللہ ایک ہے، بے نیاز ہے، نہ اس کی اولاد ہے نہ وہ کسی کی اولاد، اور کوئی اس کا ہمسر نہیں ہے۔ [Quran 112:1-4]',
      tags: ['tawhid', 'oneness', 'surah ikhlas', 'aqeedah', 'allah', 'monotheism'],
    ),
    CorpusItem(
      id: 'aqeedah_iman_articles_2',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 8',
      arabic: 'أَنْ تُؤْمِنَ بِاللَّهِ، وَمَلَائِكَتِهِ، وَكُتُبِهِ، وَرُسُلِهِ، وَالْيَوْمِ الْآخِرِ، وَتُؤْمِنَ بِالْقَدَرِ خَيْرِهِ وَشَرِّهِ',
      english: 'The 6 Pillars of Iman are belief in Allah, His Angels, His Books, His Messengers, the Last Day, and Divine Decree (Qadar), both its good and bad [Sahih Muslim 8].',
      urdu: 'ایمان کے چھ ارکان ہیں: اللہ پر ایمان، فرشتوں پر، کتب سماویہ پر، رسولوں پر، یوم آخرت پر، اور تقدیر کے اچھے اور برے ہونے پر۔ [Sahih Muslim 8]',
      tags: ['six articles of iman', 'pillars of faith', 'iman', 'qadar', 'angels', 'books', 'messengers'],
    ),
    CorpusItem(
      id: 'aqeedah_qadar_3',
      collection: 'faqs_corpus',
      reference: 'Quran 54:49; Sahih Muslim 2653',
      arabic: 'إِنَّا كُلَّ شَيْءٍ خَلَقْنَاهُ بِقَدَرٍ',
      english: 'Belief in Qadar (Divine Predestination) entails acknowledging Allah\'s eternal knowledge, His writing in al-Lawh al-Mahfuz, His overarching Will, and His creation of all things [Quran 54:49; Sahih Muslim 2653].',
      urdu: 'تقدیر پر ایمان کا مطلب یہ ہے کہ اللہ تعالیٰ نے ہر چیز کو ایک مقررہ اندازے اور اپنے ازلی علم کے مطابق پیدا فرمایا ہے۔ [Quran 54:49; Sahih Muslim 2653]',
      tags: ['qadar', 'destiny', 'predestination', 'decree', 'fate', 'taqdeer'],
    ),
    CorpusItem(
      id: 'aqeedah_ihsan_4',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 50; Sahih Muslim 8',
      arabic: 'أَنْ تَعْبُدَ اللَّهَ كَأَنَّكَ تَرَاهُ، فَإِنْ لَمْ تَكُنْ تَرَاهُ فَإِنَّهُ يَرَاكَ',
      english: 'Ihsan is the highest spiritual station in Islam: "To worship Allah as though you see Him, and if you cannot see Him, then know that He sees you" [Sahih al-Bukhari 50; Sahih Muslim 8].',
      urdu: 'احسان یہ ہے کہ تم اللہ کی عبادت اس طرح کرو گویا تم اسے دیکھ رہے ہو، اور اگر تم اسے نہیں دیکھ سکتے تو یقین جانو کہ وہ تمہیں دیکھ رہا ہے۔ [Sahih al-Bukhari 50; Sahih Muslim 8]',
      tags: ['ihsan', 'worship', 'mindfulness', 'hadith jibril', 'spirituality'],
    ),
    CorpusItem(
      id: 'aqeedah_shirk_5',
      collection: 'faqs_corpus',
      reference: 'Quran 4:48; Sahih al-Bukhari 4761',
      arabic: 'إِنَّ اللَّهَ لَا يَغْفِرُ أَن يُشْرَكَ بِهِ وَيَغْفِرُ مَا دُونَ ذَٰلِكَ لِمَن يَشَاءُ',
      english: 'Shirk (associating partners with Allah) is the gravest sin in Islam and nullifies deeds if not repented before death [Quran 4:48; Sahih al-Bukhari 4761].',
      urdu: 'شرک سب سے بڑا گناہ ہے جس کی بخشش توبہ کے بغیر نہیں ہوتی [Quran 4:48; Sahih al-Bukhari 4761]۔',
      tags: ['shirk', 'polytheism', 'major sins', 'tawhid'],
    ),
    CorpusItem(
      id: 'aqeedah_intercession_shafaa_6',
      collection: 'faqs_corpus',
      reference: 'Quran 2:255; Sahih al-Bukhari 3340',
      arabic: 'مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ',
      english: 'Intercession (Shafa\'ah) on the Day of Judgment is affirmed for Prophet Muhammad (pbuh) and righteous servants, granted solely by Allah\'s permission and pleasure [Quran 2:255; Sahih al-Bukhari 3340].',
      urdu: 'قیامت کے دن شفاعت کا حق اللہ کی اجازت اور رضا مندی سے نبی کریم ﷺ اور صالحین کو حاصل ہوگا [Quran 2:255; Sahih al-Bukhari 3340]۔',
      tags: ['shafaah', 'intercession', 'day of judgment', 'prophet'],
    ),
    CorpusItem(
      id: 'aqeedah_angels_jibril_7',
      collection: 'faqs_corpus',
      reference: 'Quran 2:97; Sahih Muslim 177',
      arabic: 'مَن كَانَ عَدُوًّا لِّجِبْرِيلَ فَإِنَّهُ نَزَّلَهُ عَلَىٰ قَلْبِكَ بِإِذْنِ اللَّهِ',
      english: 'Angels are created from light, do not disobey Allah, and perform commanded duties. Archangel Jibril is entrusted with conveying divine revelation to the Prophets [Quran 2:97; Sahih Muslim 177].',
      urdu: 'فرشتے نور سے پیدا کیے گئے ہیں، اللہ کی نافرمانی نہیں کرتے۔ حضرت جبرائیل علیہ السلام وحی لانے پر مامور ہیں [Quran 2:97; Sahih Muslim 177]۔',
      tags: ['angels', 'jibril', 'creation of light', 'revelation', 'malaika'],
    ),
    CorpusItem(
      id: 'aqeedah_resurrection_8',
      collection: 'quran_juz30',
      reference: 'Quran 78:17-20; Sahih al-Bukhari 4935',
      arabic: 'إِنَّ يَوْمَ الْفَصْلِ كَانَ مِيقَاتًا ۝ يَوْمَ يُنفَخُ فِي الصُّورِ فَتَأْتُونَ أَفْوَاجًا',
      english: 'The Day of Judgment is an established reality where all creation will be resurrected for accountability, weighed on the Scales (Mizan) [Quran 78:17-20; Sahih al-Bukhari 4935].',
      urdu: 'یوم آخرت برحق ہے جس میں صور پھونکے جانے پر تمام انسان دوبارہ زندہ کر کے حساب و کتاب کے لیے جمع کیے جائیں گے [Quran 78:17-20; Sahih al-Bukhari 4935]۔',
      tags: ['resurrection', 'day of judgment', 'qiyamah', 'mizan', 'hereafter'],
    ),
    CorpusItem(
      id: 'aqeedah_divine_names_9',
      collection: 'faqs_corpus',
      reference: 'Quran 7:180; Sahih al-Bukhari 2736',
      arabic: 'وَلِلَّهِ الْأَسْمَاءُ الْحُسْنَىٰ فَادْعُوهُ بِهَا',
      english: 'Allah has the Most Beautiful Names (Asma ul-Husna). Whoever learns, understands, and acts upon them will enter Paradise [Quran 7:180; Sahih al-Bukhari 2736].',
      urdu: 'اللہ تعالیٰ کے اچھے نام ہیں، پس ان کے ذریعے اسے پکارو۔ جس نے ان کو یاد رکھا اور ان پر عمل کیا وہ جنت میں داخل ہوگا [Quran 7:180; Sahih al-Bukhari 2736]۔',
      tags: ['asma ul husna', '99 names', 'names of allah', 'attributes'],
    ),
    CorpusItem(
      id: 'aqeedah_prophethood_finality_10',
      collection: 'faqs_corpus',
      reference: 'Quran 33:40; Sahih al-Bukhari 3535',
      arabic: 'مَّا كَانَ مُحَمَّدٌ أَبَا أَحَدٍ مِّن رِّجَالِكُمْ وَلَٰكِن رَّسُولَ اللَّهِ وَخَاتَمَ النَّبِيِّينَ',
      english: 'Prophet Muhammad (pbuh) is the final Messenger of Allah and the Seal of the Prophets (Khatam an-Nabiyyin) with no prophet to come after him [Quran 33:40; Sahih al-Bukhari 3535].',
      urdu: 'حضرت محمد ﷺ اللہ کے رسول اور خاتم النبیین ہیں اور آپ کے بعد کوئی نیا نبی نہیں آئے گا [Quran 33:40; Sahih al-Bukhari 3535]۔',
      tags: ['khatam an nabiyyin', 'finality of prophethood', 'prophet muhammad', 'seal of prophets'],
    ),

    // =========================================================================
    // 2. FIQH & IKHTILAF (JURISPRUDENCE DIFFERENCES)
    // =========================================================================
    CorpusItem(
      id: 'fiqh_wudu_nullifiers_11',
      collection: 'faqs_corpus',
      reference: 'Quran 5:6; Sahih al-Bukhari 135',
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا إِذَا قُمْتُمْ إِلَى الصَّلَاةِ فَاغْسِلُوا وُجُوهَكُمْ وَأَيْدِيَكُمْ إِلَى الْمَرَافِقِ',
      english: 'Wudu is nullified by discharges from private parts, deep sleep, and loss of consciousness [Quran 5:6; Sahih al-Bukhari 135]. [Hanafi: Flowing blood breaks wudu], while [Shafi\'i/Maliki: Bleeding does not break wudu].',
      urdu: 'وضو اخراج ریح، پیشاب و پاخانہ، اور بے ہوشی سے ٹوٹتا ہے۔ [حنفی: بہنے والا خون وضو توڑ دیتا ہے]، جبکہ [شافعی/مالکی: خون نکلنے سے وضو نہیں ٹوٹتا] [Quran 5:6; Sahih al-Bukhari 135]۔',
      tags: ['wudu', 'ablution', 'nullifiers', 'bleeding', 'madhab', 'ikhtilaf'],
    ),
    CorpusItem(
      id: 'fiqh_rafa_yadain_12',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 735; Sunan Abi Dawud 748',
      arabic: 'رَأَيْتُ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ إِذَا قَامَ فِي الصَّلَاةِ رَفَعَ يَدَيْهِ',
      english: 'Raising hands in prayer (Rafa al-Yadain) before and after Ruku is established Sunnah in [Shafi\'i/Hanbali: Practiced regularly based on Sahih al-Bukhari 735]. In [Hanafi/Maliki: Hands are raised only at the opening Takbir based on Sunan Abi Dawud 748]. Both are valid Sunnah traditions.',
      urdu: 'رکوع جاتے اور اٹھتے وقت رفع الیدین: [شافعی/حنبلی: مسنون ہے Sahih al-Bukhari 735]، [حنفی: صرف تکبیر تحریمہ پر Sunan Abi Dawud 748]۔ دونوں آراء ائمہ کی مستند روایات پر مبنی ہیں۔',
      tags: ['rafa yadain', 'prayer', 'salah', 'ikhtilaf', 'hands in prayer', 'hanafi', 'shafii'],
    ),
    CorpusItem(
      id: 'fiqh_taraweeh_rakats_13',
      collection: 'faqs_corpus',
      reference: 'Muwatta Malik 250; Sahih al-Bukhari 2012',
      arabic: 'كَانَ النَّاسُ يَقُومُونَ فِي زَمَانِ عُمَرَ بْنِ الْخَطَّابِ فِي رَمَضَانَ بِثَلَاثٍ وَعِشْرِينَ رَكْعَةً',
      english: 'Taraweeh prayers in Ramadan: [8 Rak\'ahs is confirmed from Prophet\'s personal practice in Sahih al-Bukhari 2012], while [20 Rak\'ahs was established in congregation by Caliph Umar and adopted by the Four Madhabs in Muwatta Malik 250]. Both are valid.',
      urdu: 'تراویح کی تعداد: [8 رکعت رسول اللہ ﷺ کی رات کی نماز سے ثابت ہے Sahih al-Bukhari 2012] اور [20 رکعت حضرت عمرؓ کے باجماعت اہتمام اور چاروں ائمہ سے منقول ہے Muwatta Malik 250]۔',
      tags: ['taraweeh', 'rakats', 'ramadan', 'qiyam', 'ikhtilaf'],
    ),
    CorpusItem(
      id: 'fiqh_qunoot_fajr_14',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 677; Sunan an-Nasa\'i 1079',
      arabic: 'كَانَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ يَقْنُتُ فِي الْفَجْرِ فِي النَّوَازِلِ',
      english: 'Qunoot in Fajr prayer: [Shafi\'i/Maliki: Recommended as daily Sunnah in the 2nd rak\'ah based on Sahih Muslim 677]. [Hanafi/Hanbali: Prescribed only during general calamities (Qunoot an-Nawazil) based on Sunan an-Nasa\'i 1079].',
      urdu: 'فجر میں دعائے قنوت: [شافعی/مالکی: روزانہ دوسری رکعت میں مستحب Sahih Muslim 677]، [حنفی/حنبلی: صرف نازلہ یا مصیبت کے وقت مسنون Sunan an-Nasa\'i 1079]۔',
      tags: ['qunoot', 'fajr', 'qunoot nazilah', 'ikhtilaf', 'madhab'],
    ),
    CorpusItem(
      id: 'fiqh_wiping_socks_khuffain_15',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 276; Sunan Abi Dawud 157',
      arabic: 'جَعَلَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ لِلْمُسَافِرِ ثَلَاثَةَ أَيَّامٍ وَلَيَالِيهِنَّ، وَلِلْمُقِيمِ يَوْمًا وَلَيْلَةً',
      english: 'Wiping over leather socks (Masah \'ala al-Khuffayn) is valid for 1 day and night for the resident, and 3 days and nights for the traveler, provided they were put on in a state of pure Wudu [Sahih Muslim 276; Sunan Abi Dawud 157].',
      urdu: 'موزوں پر مسح کرنا مقیم کے لیے ایک دن رات اور مسافر کے لیے تین دن رات جائز ہے بشرطیکہ وہ باوضو پہنے گئے ہوں [Sahih Muslim 276; Sunan Abi Dawud 157]۔',
      tags: ['masah', 'wiping socks', 'khuffain', 'tahara', 'traveler'],
    ),
    CorpusItem(
      id: 'fiqh_fatihah_behind_imam_16',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 756; Sunan Abi Dawud 823',
      arabic: 'لَا صَلَاةَ لِمَنْ لَمْ يَقْرَأْ بِفَاتِحَةِ الْكِتَابِ',
      english: 'Reciting Surah Al-Fatihah behind the Imam: [Shafi\'i: Obligatory in all prayers based on Sahih al-Bukhari 756]. [Hanafi: Not recited by the follower as Imam\'s recitation suffices based on Quran 7:204]. [Maliki/Hanbali: Recited in silent prayers, silent during audible prayers].',
      urdu: 'امام کے پیچھے سورہ فاتحہ پڑھنا: [شافعی: ہر نماز میں واجب Sahih al-Bukhari 756]، [حنفی: مقتدی کے لیے قرات نہیں Quran 7:204]، [مالکی/حنبلی: سری نمازوں میں پڑھی جائے گی]۔',
      tags: ['fatihah behind imam', 'salah', 'qiraat', 'ikhtilaf', 'madhab'],
    ),
    CorpusItem(
      id: 'fiqh_sujood_sahw_17',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 401; Sahih Muslim 571',
      arabic: 'إِذَا شَكَّ أَحَدُكُمْ فِي صَلَاتِهِ فَلْيَبْنِ عَلَى الْيَقِينِ وَيَسْجُدْ سَجْدَتَيْنِ',
      english: 'Sujood al-Sahw (Prostration of Forgetfulness) compensates for omissions or additions in prayer. It consists of two prostrations performed before or after Salam [Sahih al-Bukhari 401; Sahih Muslim 571].',
      urdu: 'سجدہ سہو نماز میں کمی یا زیادتی کے ازالے کے لیے سلام سے پہلے یا بعد دو سجدے کرنے سے ادا ہوتا ہے [Sahih al-Bukhari 401; Sahih Muslim 571]۔',
      tags: ['sujood sahw', 'forgetfulness in prayer', 'salah', 'prostration'],
    ),
    CorpusItem(
      id: 'fiqh_fasting_intention_niyyah_18',
      collection: 'faqs_corpus',
      reference: 'Sunan an-Nasa\'i 2331; Sahih Muslim 1154',
      arabic: 'مَنْ لَمْ يُبَيِّتِ الصِّيَامَ قَبْلَ الْفَجْرِ فَلَا صِيَامَ لَهُ',
      english: 'For obligatory Ramadan fasting, the intention must be formed before dawn (Fajr) [Sunan an-Nasa\'i 2331]. For voluntary (Nafl) fasts, intention may be made during the day before Dhuhr if no food was taken [Sahih Muslim 1154].',
      urdu: 'رمضان کے فرض روزے کی نیت فجر سے پہلے ضروری ہے [Sunan an-Nasa\'i 2331]، جبکہ نفلی روزے کی نیت دن کے وقت بھی جائز ہے اگر کچھ کھایا پیا نہ ہو [Sahih Muslim 1154]۔',
      tags: ['fasting intention', 'niyyah', 'ramadan', 'nafl fast', 'sawm'],
    ),
    CorpusItem(
      id: 'fiqh_shortening_prayer_safar_19',
      collection: 'faqs_corpus',
      reference: 'Quran 4:101; Sahih Muslim 686',
      arabic: 'وَإِذَا ضَرَبْتُمْ فِي الْأَرْضِ فَلَيْسَ عَلَيْكُمْ جُنَاحٌ أَن تَقْصُرُوا مِنَ الصَّلَاةِ',
      english: 'Travelers shorten 4-rak\'ah prayers to 2 rak\'ahs (Qasr) on journeys exceeding travel distance (approx. 77-88 km) [Quran 4:101; Sahih Muslim 686].',
      urdu: 'سفر شرعی (تقریباً 77 سے 88 کلومیٹر) کی مسافت پر چار رکعت والی نماز کو دو رکعت (قصر) پڑھنا رخصت ہے [Quran 4:101; Sahih Muslim 686]۔',
      tags: ['qasr', 'travel prayer', 'shortening prayer', 'safar', 'musafir'],
    ),
    CorpusItem(
      id: 'fiqh_zakat_gold_jewelry_20',
      collection: 'faqs_corpus',
      reference: 'Sunan Abi Dawud 1563; Sahih Muslim 987',
      arabic: 'فِي الرِّقَّةِ رُبُعُ الْعُشْرِ',
      english: 'Zakat on personal gold jewelry: [Hanafi: Obligatory if reaching Nisab (85g gold) based on Sunan Abi Dawud 1563]. [Shafi\'i/Maliki/Hanbali: Non-obligatory on customary personal use jewelry based on narrations of Companions].',
      urdu: 'زیورات پر زکوٰۃ: [حنفی: نصاب پہنچنے پر واجب ہے Sunan Abi Dawud 1563]، [جمہور ائمہ: ذاتی استعمال کے زیور پر زکوٰۃ واجب نہیں]۔',
      tags: ['zakat on gold', 'jewelry zakat', 'nisab', 'charity', 'ikhtilaf'],
    ),

    // =========================================================================
    // 3. SEERAH & HISTORICAL CHRONOLOGY
    // =========================================================================
    CorpusItem(
      id: 'seerah_cave_hira_21',
      collection: 'faqs_corpus',
      reference: 'Quran 96:1-5; Sahih al-Bukhari 3',
      arabic: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِي خَلَقَ',
      english: 'The first revelation descended upon Prophet Muhammad (pbuh) at the age of 40 in Cave Hira with the opening verses of Surah Al-Alaq [Quran 96:1-5; Sahih al-Bukhari 3].',
      urdu: 'پہلی وحی 40 سال کی عمر میں غار حرا میں نازل ہوئی جس میں سورہ علق کی ابتدائی آیات عطا ہوئیں [Quran 96:1-5; Sahih al-Bukhari 3]۔',
      tags: ['first revelation', 'cave hira', 'iqra', 'prophethood', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_isra_miraj_22',
      collection: 'faqs_corpus',
      reference: 'Quran 17:1; Sahih al-Bukhari 3887',
      arabic: 'سُبْحَانَ الَّذِي أَسْرَىٰ بِعَبْدِهِ لَيْلًا مِّنَ الْمَسْجِدِ الْحَرَامِ إِلَى الْمَسْجِدِ الْأَقْصَى',
      english: 'Al-Isra wal-Mi\'raj: The miraculous night journey from Makkah to Jerusalem and ascension through the heavens occurred in the Makkan period, where the 5 daily prayers were ordained [Quran 17:1; Sahih al-Bukhari 3887].',
      urdu: 'واقعہ اسراء و معراج میں نبی کریم ﷺ کو مکہ سے مسجد اقصی اور آسمانوں کی سیر کرائی گئی اور پانچ وقت کی نماز فرض ہوئی [Quran 17:1; Sahih al-Bukhari 3887]۔',
      tags: ['isra miraj', 'night journey', '5 prayers ordained', 'seerah', 'jerusalem'],
    ),
    CorpusItem(
      id: 'seerah_hijrah_madinah_23',
      collection: 'faqs_corpus',
      reference: 'Quran 9:40; Sahih al-Bukhari 3905',
      arabic: 'إِلَّا تَنصُرُوهُ فَقَدْ نَصَرَهُ اللَّهُ إِذْ أَخْرَجَهُ الَّذِينَ كَفَرُوا ثَانِيَ اثْنَيْنِ إِذْ هُمَا فِي الْغَارِ',
      english: 'The Hijrah to Madinah occurred in 622 CE alongside Abu Bakr as-Siddiq, marking the start of the Islamic Hijri calendar and establishment of the first Islamic state [Quran 9:40; Sahih al-Bukhari 3905].',
      urdu: 'ہجرت مدینہ 622ء میں حضرت ابوبکر صدیقؓ کے ہمراہ ہوئی، جس سے اسلامی ہجری تقویم کا آغاز ہوا [Quran 9:40; Sahih al-Bukhari 3905]۔',
      tags: ['hijrah', 'madinah', 'cave thawr', 'abu bakr', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_battle_badr_24',
      collection: 'faqs_corpus',
      reference: 'Quran 3:123; Sahih al-Bukhari 3953',
      arabic: 'وَلَقَدْ نَصَرَكُمُ اللَّهُ بِبَدْرٍ وَأَنتُمْ أَذِلَّةٌ',
      english: 'The Battle of Badr took place on 17 Ramadan, 2 AH. 313 Muslims achieved victory against over 1,000 Quraysh fighters with divine assistance [Quran 3:123; Sahih al-Bukhari 3953].',
      urdu: 'غزوہ بدر 17 رمضان 2 ہجری کو پیش آیا جس میں 313 مسلمانوں نے ایک ہزار کفار پر غلبہ پایا [Quran 3:123; Sahih al-Bukhari 3953]۔',
      tags: ['battle of badr', 'ghazwa badr', 'ramadan', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_treaty_hudaybiyyah_25',
      collection: 'faqs_corpus',
      reference: 'Quran 48:1; Sahih al-Bukhari 2731',
      arabic: 'إِنَّا فَتَحْنَا لَكَ فَتْحًا مُّبِينًا',
      english: 'The Treaty of Hudaybiyyah was signed in 6 AH. Allah described it in the Quran as a "clear triumph" (Fath Mubeen) paving the way for the peaceful spread of Islam [Quran 48:1; Sahih al-Bukhari 2731].',
      urdu: 'صلح حدیبیہ 6 ہجری میں طے پایا جسے قرآن نے فتح مبین قرار دیا اور اس سے اسلام کو وسیع غلبہ نصیب ہوا [Quran 48:1; Sahih al-Bukhari 2731]۔',
      tags: ['treaty of hudaybiyyah', 'sulh hudaybiyyah', 'fath mubeen', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_conquest_makkah_26',
      collection: 'faqs_corpus',
      reference: 'Quran 110:1-3; Sahih al-Bukhari 4280',
      arabic: 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
      english: 'The Conquest of Makkah (Fath Makkah) took place in Ramadan, 8 AH. The Prophet (pbuh) entered peacefully, purified the Ka\'bah from idols, and granted general amnesty [Quran 110:1-3; Sahih al-Bukhari 4280].',
      urdu: 'فتح مکہ 8 ہجری میں پیش آیا، نبی کریم ﷺ نے بغیر خون خرابے کے مکہ میں داخل ہو کر بتوں کو مٹایا اور عام معافی کا اعلان فرمایا [Quran 110:1-3; Sahih al-Bukhari 4280]۔',
      tags: ['conquest of makkah', 'fath makkah', 'general amnesty', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_farewell_pilgrimage_27',
      collection: 'faqs_corpus',
      reference: 'Quran 5:3; Sahih Muslim 1218',
      arabic: 'الْيَوْمَ أَكْمَلْتُ لَكُمْ دِينَكُمْ وَأَتْمَمْتُ عَلَيْكُمْ نِعْمَتِي وَرَضِيتُ لَكُمُ الْإِسْلَامَ دِينًا',
      english: 'The Farewell Pilgrimage (Hajjat al-Wada\') in 10 AH included the historic Farewell Sermon establishing human equality, rights of women, prohibition of usury, and completion of the religion [Quran 5:3; Sahih Muslim 1218].',
      urdu: 'حجۃ الوداع 10 ہجری میں ہوا جس میں خطبہ حجتہ الوداع کے ذریعے انسانی مساوات اور تکمیل دین کا اعلان ہوا [Quran 5:3; Sahih Muslim 1218]۔',
      tags: ['hajjat al wada', 'farewell sermon', 'equality', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_battle_uhud_28',
      collection: 'faqs_corpus',
      reference: 'Quran 3:152; Sahih al-Bukhari 4043',
      arabic: 'وَلَقَدْ صَدَقَكُمُ اللَّهُ وَعْدَهُ إِذْ تَحُسُّونَهُم بِإِذْنِهِ',
      english: 'The Battle of Uhud occurred in Shawwal, 3 AH. The believers faced hardship when archers left their designated positions, teaching vital lessons on obeying leadership [Quran 3:152; Sahih al-Bukhari 4043].',
      urdu: 'غزوہ احد 3 ہجری میں پیش آیا، جس میں تیر اندازوں کے مورچہ چھوڑنے سے مسلمانوں کو آزمائش کا سامنا کرنا پڑا [Quran 3:152; Sahih al-Bukhari 4043]۔',
      tags: ['battle of uhud', 'ghazwa uhud', 'lessons of obedience', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_year_of_sorrow_29',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 3815',
      arabic: 'عَامُ الْحُزْنِ: وَفَاةُ خَدِيجَةَ رَضِيَ اللَّهُ عَنْهَا وَأَبِي طَالِبٍ',
      english: 'The Year of Sorrow (\'Am al-Huzn) occurred in the 10th year of Prophethood with the loss of Khadijah (ra) and Abu Talib, leading to the journey to Ta\'if [Sahih al-Bukhari 3815].',
      urdu: 'عام الحزن (غم کا سال) نبوت کے دسویں سال حضرت خدیجہؓ اور ابو طالب کی وفات کا سال کہلاتا ہے [Sahih al-Bukhari 3815]۔',
      tags: ['year of sorrow', 'am al huzn', 'khadijah', 'taif', 'seerah'],
    ),
    CorpusItem(
      id: 'seerah_prophet_demise_30',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 4463',
      arabic: 'اللَّهُمَّ الرَّفِيقَ الْأَعْلَى',
      english: 'The Prophet Muhammad (pbuh) passed away on Monday, 12th Rabi al-Awwal, 11 AH in Madinah, with his final words being "With the Highest Companionship" [Sahih al-Bukhari 4463].',
      urdu: 'نبی کریم ﷺ کا وصال 12 ربیع الاول 11 ہجری کو مدینہ منورہ میں ہوا، آخری الفاظ تھے: "اللھم الرفیق الاعلیٰ" [Sahih al-Bukhari 4463]۔',
      tags: ['demise of prophet', 'wafat', 'highest companionship', 'seerah'],
    ),

    // =========================================================================
    // 4. DUAS & AUTHENTIC ADHKAR
    // =========================================================================
    CorpusItem(
      id: 'dua_sayyidul_istighfar_31',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih al-Bukhari 6306',
      arabic: 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
      english: 'Sayyidul Istighfar (Chief of Forgiveness Prayers): Reciting it with conviction in morning/evening guarantees Paradise upon death [Sahih al-Bukhari 6306].',
      urdu: 'سید الاستغفار: جو شخص صبح یا شام یقین کے ساتھ اسے پڑھے اور وفات پا جائے وہ جنتی ہے [Sahih al-Bukhari 6306]۔',
      tags: ['sayyidul istighfar', 'forgiveness', 'istighfar', 'morning adhkar', 'repentance'],
    ),
    CorpusItem(
      id: 'dua_morning_evening_32',
      collection: 'duas_hisnul_muslim',
      reference: 'Sunan Abi Dawud 5088',
      arabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
      english: 'Reciting "Bismillahil-ladhi la yadurru..." 3 times morning and evening provides comprehensive protection against all harm [Sunan Abi Dawud 5088].',
      urdu: 'صبح اور شام 3 بار پڑھنے سے زمین و آسمان کی کوئی چیز نقصان نہیں پہنچا سکتی [Sunan Abi Dawud 5088]۔',
      tags: ['morning adhkar', 'protection dua', 'hisnul muslim', 'evening adhkar'],
    ),
    CorpusItem(
      id: 'dua_travel_safar_33',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih Muslim 1342',
      arabic: 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ وَإِنَّا إِلَىٰ رَبِّنَا لَمُنقَلِبُونَ',
      english: 'Dua for traveling (Safar): "Glory be to Him who has placed this at our service, and we could not have done it by ourselves, and to our Lord we shall return" [Sahih Muslim 1342].',
      urdu: 'سفر کی مسنون دعا: پاک ہے وہ ذات جس نے اس سواری کو ہمارے تابع کیا [Sahih Muslim 1342]۔',
      tags: ['travel dua', 'safar ki dua', 'hisnul muslim'],
    ),
    CorpusItem(
      id: 'dua_sneezing_etiquette_34',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih al-Bukhari 6224',
      arabic: 'الْحَمْدُ لِلَّهِ - يَرْحَمُكَ اللَّهُ - يَهْدِيكُمُ اللَّهُ وَيُصْلِحُ بَالَكُمْ',
      english: 'When sneezing: Say "Alhamdulillah". The listener responds "Yarhamukallah", and the sneezer concludes "Yahdikumullahu wa yuslihu balakum" [Sahih al-Bukhari 6224].',
      urdu: 'چھینک کے آداب: چھینکنے والا الحمد للہ کہے، سننے والا یرحمک اللہ کہے، اور جواباً یہدیکم اللہ کہا جائے [Sahih al-Bukhari 6224]۔',
      tags: ['sneezing etiquette', 'alhamdulillah', 'yarhamukallah', 'manners'],
    ),
    CorpusItem(
      id: 'dua_sleeping_waking_35',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih al-Bukhari 6312',
      arabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا / الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
      english: 'Dua before sleeping: "Bismika Allahumma amootu wa ahya". Upon waking: "Alhamdulillahil-ladhi ahyana ba\'da ma amatana wa ilayhin-nushoor" [Sahih al-Bukhari 6312].',
      urdu: 'سونے اور بیدار ہونے کی مسنون دعائیں [Sahih al-Bukhari 6312]۔',
      tags: ['sleeping dua', 'waking up dua', 'adhkar'],
    ),
    CorpusItem(
      id: 'dua_istikhara_guidance_36',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih al-Bukhari 1162',
      arabic: 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ',
      english: 'Salat al-Istikhara is prayed (2 voluntary rak\'ahs followed by the Istikhara supplication) when seeking Allah\'s guidance in making permissible life decisions [Sahih al-Bukhari 1162].',
      urdu: 'استخارہ کی مسنون نماز اور دعا کسی بھی جائز فیصلے میں اللہ کی رہنمائی حاصل کرنے کے لیے ہے [Sahih al-Bukhari 1162]۔',
      tags: ['istikhara', 'decision making', 'guidance', 'hisnul muslim'],
    ),
    CorpusItem(
      id: 'dua_distress_anxiety_37',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih al-Bukhari 6346',
      arabic: 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ',
      english: 'Supplication for relief in times of grief and distress: "La ilaha illallahul-Azimul-Halim..." [Sahih al-Bukhari 6346].',
      urdu: 'پریشانی اور غم سے نجات کی مسنون دعا [Sahih al-Bukhari 6346]۔',
      tags: ['distress dua', 'grief', 'anxiety', 'relief', 'hisnul muslim'],
    ),
    CorpusItem(
      id: 'dua_iftar_fasting_38',
      collection: 'duas_hisnul_muslim',
      reference: 'Sunan Abi Dawud 2357',
      arabic: 'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
      english: 'Dua at the time of breaking the fast (Iftar): "Dhahaba adh-Dhama\'u wabtallatil-\'urooqu wa thabatal-ajru in sha Allah" [Sunan Abi Dawud 2357].',
      urdu: 'افطار کے وقت کی مسنون دعا: پیاس بجھ گئی اور رگیں تر ہو گئیں [Sunan Abi Dawud 2357]۔',
      tags: ['iftar', 'breaking fast', 'fasting dua', 'ramadan'],
    ),
    CorpusItem(
      id: 'dua_masjid_enter_exit_39',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih Muslim 713',
      arabic: 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ / اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
      english: 'Upon entering the mosque: "Allahummaftah li abwaba rahmatik" (open for me gates of Your mercy). Upon leaving: "Allahumma inni as\'aluka min fadlik" (I ask You of Your bounty) [Sahih Muslim 713].',
      urdu: 'مسجد میں داخل ہونے اور نکلنے کی مسنون دعائیں [Sahih Muslim 713]۔',
      tags: ['masjid entering', 'masjid leaving', 'mosque etiquette', 'hisnul muslim'],
    ),
    CorpusItem(
      id: 'dua_eating_food_40',
      collection: 'duas_hisnul_muslim',
      reference: 'Sunan Abi Dawud 3767',
      arabic: 'بِسْمِ اللَّهِ فِي أَوَّلِهِ وَآخِرِهِ',
      english: 'Say Bismillah before eating; if forgotten, say "Bismillahi fi awwalihi wa akhirihi" [Sunan Abi Dawud 3767].',
      urdu: 'کھانے کے شروع اور بھول جانے پر پڑھنے کی دعا [Sunan Abi Dawud 3767]۔',
      tags: ['eating dua', 'food manners', 'bismillah'],
    ),

    // =========================================================================
    // 5. ADVERSARIAL & UNVERIFIED NARRATIONS (ZERO FABRICATION STRICT DECLINES)
    // =========================================================================
    CorpusItem(
      id: 'adv_china_knowledge_41',
      collection: 'faqs_corpus',
      reference: 'Ibn al-Jawzi in Al-Mawdu\'at 1/215; Al-Albani in Da\'if al-Jami\' 906',
      arabic: 'اطْلُبُوا الْعِلْمَ وَلَوْ بِالصِّينِ (حَدِيثٌ مَوْضُوعٌ / بَاطِلٌ)',
      english: 'The saying "Seek knowledge even unto China" is classified by hadith scholars (including Ibn al-Jawzi and Al-Albani) as fabricated (Mawdu\') or severely weak, though seeking beneficial knowledge is generally mandated in authentic texts [Ibn al-Jawzi in Al-Mawdu\'at 1/215; Al-Albani in Da\'if al-Jami\' 906].',
      urdu: 'مشہور جملہ "علم حاصل کرو خواہ چین جانا پڑے" محدثین کے نزدیک باطل و من گھڑت (موضوع) روایت ہے [Ibn al-Jawzi in Al-Mawdu\'at 1/215; Al-Albani in Da\'if al-Jami\' 906]۔',
      tags: ['seek knowledge china', 'fabricated hadith', 'mawdu', 'china hadith', 'authenticity'],
      isFabricatedWarning: true,
    ),
    CorpusItem(
      id: 'adv_love_of_homeland_42',
      collection: 'faqs_corpus',
      reference: 'As-Sakhawi in Al-Maqasid al-Hasanah 1/297; Al-Albani in Silsilat al-Ahadith ad-Da\'ifah 36',
      arabic: 'حُبُّ الْوَطَنِ مِنَ الْإِيمَانِ (لَا أَصْلَ لَهُ مَرْفُوعًا)',
      english: 'The phrase "Love of one\'s homeland is part of faith" has no authentic basis (La asla lahu) as a saying of the Prophet (pbuh) according to hadith masters [As-Sakhawi in Al-Maqasid al-Hasanah 1/297; Al-Albani in Silsilat al-Ahadith ad-Da\'ifah 36].',
      urdu: '"وطن کی محبت ایمان کا حصہ ہے" کو حدیث کے طور پر منسوب کرنا ثابت نہیں ہے [As-Sakhawi in Al-Maqasid al-Hasanah 1/297; Al-Albani in Silsilat al-Ahadith ad-Da\'ifah 36]۔',
      tags: ['love of homeland', 'hubb al watan', 'unverified hadith', 'daeef'],
      isFabricatedWarning: true,
    ),
    CorpusItem(
      id: 'adv_astrology_horoscopes_43',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 2230; Sunan Abi Dawud 3905',
      arabic: 'مَنِ اقْتَبَسَ عِلْمًا مِنَ النُّجُومِ اقْتَبَسَ شُعْبَةً مِنَ السِّحْرِ',
      english: 'Believing in astrology, horoscopes, or fortune-telling is strictly prohibited in Islam. Seeking knowledge of the unseen from celestial bodies or soothsayers nullifies the acceptance of prayers [Sahih Muslim 2230; Sunan Abi Dawud 3905].',
      urdu: 'علم نجوم، زائچہ (Horoscope) اور قسمت کا حال جاننے کے دعوے اسلام میں حرام اور باطل ہیں [Sahih Muslim 2230; Sunan Abi Dawud 3905]۔',
      tags: ['astrology', 'horoscope', 'zodiac', 'fortune telling', 'unseen', 'haram'],
    ),
    CorpusItem(
      id: 'adv_evil_eye_ruqyah_44',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 2188; Sahih al-Bukhari 5735',
      arabic: 'الْعَيْنُ حَقٌّ، وَلَوْ كَانَ شَيْءٌ سَابَقَ الْقَدَرَ سَبَقَتْهُ الْعَيْنُ',
      english: 'The Evil Eye (Al-Ayn) is real [Sahih Muslim 2188]. Its remedy is grounded strictly in authentic Ruqyah (reciting Surah Al-Falaq, An-Nas, Al-Fatihah, and Prophetic duas), while wearing amulets or talismans (Ta\'weez containing unknown symbols) is prohibited [Sahih al-Bukhari 5735].',
      urdu: 'نظر بد برحق ہے اور اس کا مسنون علاج معوذتین اور شرعی دم (رقیہ) ہے، نہ کہ غیر شرعی تعویذ یا کالے دھاگے [Sahih Muslim 2188; Sahih al-Bukhari 5735]۔',
      tags: ['evil eye', 'ruqyah', 'nazar', 'amulet', 'talisman', 'superstition'],
    ),
    CorpusItem(
      id: 'adv_music_instruments_45',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 5590; Sunan Abi Dawud 4927',
      arabic: 'لَيَكُونَنَّ مِنْ أُمَّتِي أَقْوَامٌ يَسْتَحِلُّونَ الْحِرَ وَالْحَرِيرَ وَالْخَمْرَ وَالْمَعَازِفَ',
      english: 'Scholarly discourse on musical instruments: The Four Madhabs prohibit stringed and wind instruments based on [Sahih al-Bukhari 5590], with the exception of the Duff drum on Eid and weddings [Sunan Abi Dawud 4927].',
      urdu: 'آلات موسیقی کے بارے میں چاروں ائمہ کا موقف ممانعت کا ہے [Sahih al-Bukhari 5590]، ماسوائے عید اور شادی کے موقع پر دف کے [Sunan Abi Dawud 4927]۔',
      tags: ['music', 'instruments', 'maazif', 'duff', 'ikhtilaf', 'ruling'],
    ),
    CorpusItem(
      id: 'adv_wudu_touching_spouse_46',
      collection: 'faqs_corpus',
      reference: 'Quran 4:43; Sunan Abi Dawud 179; Sunan at-Tirmidhi 86',
      arabic: 'أَوْ لَامَسْتُمُ النِّسَاءَ',
      english: 'Touching one\'s spouse and Wudu: [Shafi\'i: Invalidates wudu on any direct skin contact based on literal Quran 4:43]. [Hanafi: Does not invalidate wudu unless leading to discharge based on Sunan Abi Dawud 179]. [Maliki/Hanbali: Invalidates only if accompanied by desire].',
      urdu: 'بیوی کو چھونے سے وضو: [شافعی: جلد چھونے سے وضو ٹوٹ جاتا ہے Quran 4:43]، [حنفی: محض چھونے سے وضو نہیں ٹوٹتا Sunan Abi Dawud 179]، [مالکی/حنبلی: اگر شہوت کے ساتھ ہو تو ٹوٹتا ہے]۔',
      tags: ['touching spouse', 'wudu nullifiers', 'marriage', 'ikhtilaf', 'madhab'],
    ),
    CorpusItem(
      id: 'adv_fasting_swallowing_saliva_47',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari Chapter on Fasting (Book 31)',
      arabic: 'بَابُ الصَّائِمِ يُصْبِحُ جُنُبًا وَبَلْعُ الرِّيقِ',
      english: 'Swallowing one\'s own normal saliva does not break the fast by consensus of Islamic scholars [Sahih al-Bukhari Chapter on Fasting (Book 31)].',
      urdu: 'اپنا تھوک نگلنے سے بالاتفاق روزہ نہیں ٹوٹتا [Sahih al-Bukhari Chapter on Fasting (Book 31)]۔',
      tags: ['saliva fasting', 'fasting rules', 'swallowing spit', 'sawm'],
    ),
    CorpusItem(
      id: 'adv_prostrating_to_graves_48',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 532; Sahih al-Bukhari 1390',
      arabic: 'لَا تَجْلِسُوا عَلَى الْقُبُورِ وَلَا تُصَلُّوا إِلَيْهَا',
      english: 'Prostrating to graves or building places of worship over them is strictly forbidden in Islam [Sahih Muslim 532; Sahih al-Bukhari 1390]. Prostration is an exclusive act of worship reserved solely for Allah.',
      urdu: 'قبروں کو سجدہ گاہ بنانا یا قبر کے آگے سجدہ کرنا اسلام میں قطعی طور پر حرام ہے، سجدہ صرف اللہ کے لیے ہے [Sahih Muslim 532; Sahih al-Bukhari 1390]۔',
      tags: ['graves', 'prostration', 'sajdah', 'shirk', 'forbidden'],
    ),
    CorpusItem(
      id: 'adv_saying_bismillah_wudu_49',
      collection: 'faqs_corpus',
      reference: 'Sunan Abi Dawud 101; Sunan Ibn Majah 399',
      arabic: 'لَا صَلَاةَ لِمَنْ لَا وُضُوءَ لَهُ، وَلَا وُضُوءَ لِمَنْ لَمْ يَذْكُرِ اسْمَ اللَّهِ عَلَيْهِ',
      english: 'Saying Bismillah before Wudu is [Hanbali: Obligatory if remembered based on Sunan Abi Dawud 101], while [Hanafi/Shafi\'i/Maliki: It is an emphatic Sunnah and wudu is valid without it].',
      urdu: 'وضو سے پہلے بسم اللہ کہنا: [حنبلی: یاد ہونے پر واجب Sunan Abi Dawud 101]، [حنفی/شافعی/مالکی: مسنون و مستحب ہے اور وضو درست ہو جاتا ہے]۔',
      tags: ['bismillah wudu', 'tahara', 'sunnah', 'ikhtilaf'],
    ),
    CorpusItem(
      id: 'adv_combining_prayers_rain_50',
      collection: 'faqs_corpus',
      reference: 'Sahih al-Bukhari 543; Sahih Muslim 705',
      arabic: 'جَمَعَ رَسُولُ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ بَيْنَ الظُّهْرِ وَالْعَصْرِ، وَالْمَغْرِبِ وَالْعِشَاءِ',
      english: 'Combining Maghrib and Isha prayers during heavy torrential rain is permitted in [Shafi\'i/Maliki/Hanbali based on Sahih Muslim 705]. In [Hanafi: Prayers may only be formally combined at Arafat and Muzdalifah during Hajj, while in other situations apparent combination (Jam\' Suri) is performed].',
      urdu: 'بارش میں نمازوں کو جمع کرنا: [جمہور ائمہ: شدید بارش و کیچڑ میں مغرب اور عشاء کو جمع کرنا جائز ہے Sahih Muslim 705]، [حنفی: صرف حج میں جمع حقیقی ہے، دیگر اوقات میں جمع صوری کی جائے گی]۔',
      tags: ['combining prayers', 'jam bayn as salatayn', 'rain prayer', 'ikhtilaf'],
    ),
    // =========================================================================
    // 6. V3 EXPANSION (KEY QURANIC VERSES, ESSENTIAL DUAS & CLASSICAL FAQS)
    // =========================================================================
    CorpusItem(
      id: 'v3_quran_al_fatiha',
      collection: 'quran',
      reference: 'Quran 1:1-7',
      arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ  الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ  الرَّحْمَٰنِ الرَّحِيمِ  مَالِكِ يَوْمِ الدِّينِ  إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ  اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ  صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
      english: 'In the name of Allah, the Most Gracious, the Most Merciful. All praise is due to Allah, Lord of the worlds - the Most Gracious, the Most Merciful, Master of the Day of Judgment. You alone we worship, and You alone we ask for help. Guide us along the Straight Path - the path of those You have blessed, not of those who earned Your anger, nor of those who went astray [Quran 1:1-7].',
      urdu: 'اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے۔ تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا رب ہے، بڑا مہربان نہایت رحم والا، روزِ جزا کا مالک۔ ہم صرف تیری ہی عبادت کرتے ہیں اور صرف تجھ ہی سے مدد مانگتے ہیں۔ ہمیں سیدھے راستے پر چلا، ان لوگوں کے راستے پر جن پر تو نے انعام کیا، نہ ان کے جن پر تیرا غضب ہوا اور نہ گمراہوں کے راستے پر۔ [Quran 1:1-7]',
      tags: ['al fatiha', 'surah fatiha', 'opening chapter', 'umm al quran', 'straight path', 'siraat'],
    ),
    CorpusItem(
      id: 'v3_quran_ayat_al_kursi',
      collection: 'quran',
      reference: 'Quran 2:255',
      arabic: 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضِ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
      english: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great [Quran 2:255].',
      urdu: 'اللہ، اس کے سوا کوئی معبود نہیں، وہ زندہ ہے، سب کو قائم رکھنے والا ہے۔ نہ اسے اونگھ آتی ہے اور نہ نیند۔ اسی کا ہے جو کچھ آسمانوں میں ہے اور جو کچھ زمین میں ہے۔ کون ہے جو اس کی اجازت کے بغیر اس کے پاس سفارش کر سکے؟ وہ جانتا ہے جو ان کے سامنے ہے اور جو ان کے پیچھے ہے، اور وہ اس کے علم میں سے کسی چیز کا احاطہ نہیں کر سکتے مگر جتنا وہ چاہے۔ اس کی کرسی آسمانوں اور زمین کو گھیرے ہوئے ہے، اور ان کی حفاظت اسے تھکاتی نہیں۔ اور وہ بلند و بالا، عظمت والا ہے۔ [Quran 2:255]',
      tags: ['ayat al kursi', 'throne verse', 'surah baqarah', 'protection', 'kursi'],
    ),
    CorpusItem(
      id: 'v3_quran_dhikr_remembrance',
      collection: 'quran',
      reference: 'Quran 2:152',
      arabic: 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
      english: 'So remember Me; I will remember you. Be grateful to Me and do not deny Me [Quran 2:152].',
      urdu: 'پس تم مجھے یاد کرو، میں تمہیں یاد کروں گا، اور میرا شکر ادا کرو اور میری ناشکری نہ کرو۔ [Quran 2:152]',
      tags: ['dhikr', 'remembrance', 'gratitude', 'shukr'],
    ),
    CorpusItem(
      id: 'v3_quran_no_burden_beyond_capacity',
      collection: 'quran',
      reference: 'Quran 2:286',
      arabic: 'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا',
      english: 'Allah does not burden a soul beyond that it can bear. It will have the consequence of what good it has gained, and it will bear the consequence of what evil it has earned [Quran 2:286].',
      urdu: 'اللہ کسی جان کو اس کی طاقت سے زیادہ بوجھ نہیں ڈالتا۔ اسے ملے گا جو اس نے کمایا اور اس پر ہوگا جو اس نے برا کمایا۔ [Quran 2:286]',
      tags: ['ease', 'no burden', 'capacity', 'dua', 'surah baqarah last verses'],
    ),
    CorpusItem(
      id: 'v3_quran_patience_and_prayer',
      collection: 'quran',
      reference: 'Quran 2:153',
      arabic: 'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
      english: 'O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient [Quran 2:153].',
      urdu: 'اے ایمان والو! صبر اور نماز سے مدد مانگو۔ بے شک اللہ صبر کرنے والوں کے ساتھ ہے۔ [Quran 2:153]',
      tags: ['sabr', 'patience', 'prayer', 'salah', 'help from allah'],
    ),
    CorpusItem(
      id: 'v3_quran_peace_of_hearts',
      collection: 'quran',
      reference: 'Quran 13:28',
      arabic: 'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
      english: 'Those who have believed and whose hearts are assured by the remembrance of Allah. Unquestionably, by the remembrance of Allah hearts are assured [Quran 13:28].',
      urdu: 'جو ایمان لائے اور جن کے دل اللہ کے ذکر سے مطمئن ہوتے ہیں۔ خبردار! اللہ کے ذکر ہی سے دل مطمئن ہوتے ہیں۔ [Quran 13:28]',
      tags: ['peace of heart', 'tranquility', 'anxiety relief', 'dhikr allah'],
    ),
    CorpusItem(
      id: 'v3_quran_mercy_and_forgiveness',
      collection: 'quran',
      reference: 'Quran 39:53',
      arabic: 'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
      english: 'Say, "O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful" [Quran 39:53].',
      urdu: 'کہہ دیجئے: اے میرے بندو جنہوں نے اپنی جانوں پر زیادتی کی ہے، اللہ کی رحمت سے مایوس نہ ہو۔ بے شک اللہ تمام گناہ معاف کر دیتا ہے۔ بے شک وہی بخشنے والا، رحم کرنے والا ہے۔ [Quran 39:53]',
      tags: ['mercy', 'repentance', 'tawbah', 'forgiveness of sins', 'hope'],
    ),
    CorpusItem(
      id: 'v3_quran_tawakkul_sufficiency',
      collection: 'quran',
      reference: 'Quran 65:3',
      arabic: 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ ۚ قَدْ جَعَلَ اللَّهُ لِكُلِّ شَيْءٍ قَدْرًا',
      english: 'And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose. Allah has already set for everything a [decreed] extent [Quran 65:3].',
      urdu: 'اور جو اللہ پر توکل کرے تو وہ اس کے لیے کافی ہے۔ بے شک اللہ اپنا کام پورا کرنے والا ہے۔ اللہ نے ہر چیز کے لیے ایک اندازہ مقرر کر رکھا ہے۔ [Quran 65:3]',
      tags: ['tawakkul', 'reliance', 'trust in allah', 'provision'],
    ),
    CorpusItem(
      id: 'v3_dua_morning_asbahna',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih Muslim 2723',
      arabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      english: 'We have entered the morning and with it all dominion belongs to Allah, praise be to Allah. None has the right to be worshipped but Allah alone, without partner [Sahih Muslim 2723].',
      urdu: 'ہم نے صبح کی اور بادشاہی اللہ کے لیے ہے، اور تمام تعریفیں اللہ کے لیے ہیں۔ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں [Sahih Muslim 2723]۔',
      tags: ['morning adhkar', 'asbahna', 'praise', 'daily remembrance'],
    ),
    CorpusItem(
      id: 'v3_dua_forgiveness_abu_bakr',
      collection: 'duas_hisnul_muslim',
      reference: 'Sahih al-Bukhari 834',
      arabic: 'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ، وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
      english: 'O Allah, I have wronged myself greatly, and none forgives sins except You. So forgive me with a forgiveness from You, and have mercy on me. Indeed, You are the Forgiving, the Merciful [Sahih al-Bukhari 834].',
      urdu: 'اے اللہ! میں نے اپنی جان پر بہت ظلم کیا، اور تیرے سوا کوئی گناہ معاف نہیں کرتا، پس مجھے اپنی طرف سے بخشش عطا فرما، اور مجھ پر رحم کر [Sahih al-Bukhari 834]۔',
      tags: ['forgiveness', 'dua in tashahhud', 'abu bakr dua', 'istighfar'],
    ),
    CorpusItem(
      id: 'v3_faq_witr_prayer',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 752',
      arabic: 'صَلَاةُ اللَّيْلِ مَثْنَى مَثْنَى، فَإِذَا خَشِيَ أَحَدُكُمُ الصُّبْحَ صَلَّى رَكْعَةً وَاحِدَةً تُوتِرُ لَهُ مَا قَدْ صَلَّى',
      english: 'Witr is prayed in odd numbers (1, 3, 5 or more rakats). The night prayer is prayed two by two, then one rakah of witr at the end [Sahih Muslim 752]. Madhab practice differs: Hanafi - 3 rakats prayed as wajib in one specific form; Shafi\'i/Maliki/Hanbali - minimum 1 rakah, up to 11, in the two-by-two form.',
      urdu: 'وتر طاق عدد میں پڑھی جاتی ہے (1، 3، 5 یا زیادہ رکعات)۔ رات کی نماز دو دو رکعت کر کے پڑھی جاتی ہے، پھر آخر میں ایک رکعت وتر [Sahih Muslim 752]۔ فقہی عمل میں فرق: حنفی - 3 رکعت واجب کی ایک مخصوص صورت میں؛ شافعی/مالکی/حنبلی - کم از کم 1 رکعت، زیادہ سے زیادہ 11، دو دو رکعت کی صورت میں۔',
      tags: ['witr', 'witr prayer', 'night prayer', 'qiyam', 'ikhtilaf'],
    ),
    CorpusItem(
      id: 'v3_faq_sujud_al_sahw_doubt',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 571',
      arabic: 'إِذَا شَكَّ أَحَدُكُمْ فِي صَلَاتِهِ فَلَمْ يَدْرِ كَمْ صَلَّى ثَلَاثًا أَمْ أَرْبَعًا فَلْيَطْرَحِ الشَّكَّ وَلْيَبْنِ عَلَى مَا اسْتَيْقَنَ ثُمَّ يَسْجُدُ سَجْدَتَيْنِ قَبْلَ أَنْ يُسَلِّمَ',
      english: 'If you are unsure in prayer whether you prayed 3 or 4 rakats, build on what you are certain of, then perform two prostrations of forgetfulness (sujud al-sahw) before the salam [Sahih Muslim 571].',
      urdu: 'اگر نماز میں شک ہو کہ 3 رکعت پڑھی ہیں یا 4، تو جس پر یقین ہو اسی پر بنیاد رکھیں، پھر سلام سے پہلے سہو کے دو سجدے کریں [Sahih Muslim 571]۔',
      tags: ['sujud al sahw', 'doubt in prayer', 'rakats mistake', 'forgetfulness prostration'],
    ),
    CorpusItem(
      id: 'v3_faq_monday_thursday_fasting',
      collection: 'faqs_corpus',
      reference: 'Sahih Muslim 1162; Jami at-Tirmidhi 747',
      arabic: 'ذَاكَ يَوْمٌ وُلِدْتُ فِيهِ، وَيَوْمٌ بُعِثْتُ أَوْ أُنْزِلَ عَلَيَّ فِيهِ',
      english: 'Fasting Mondays and Thursdays: The Prophet (pbuh) fasted on Mondays, saying "that is the day I was born and the day revelation was sent down to me" [Sahih Muslim 1162]. Deeds are presented to Allah on Mondays and Thursdays [Jami\' at-Tirmidhi 747], which is why fasting those days is recommended.',
      urdu: 'پیر اور جمعرات کے روزے: رسول اللہ ﷺ پیر کو روزہ رکھتے تھے، فرمایا: "یہ وہ دن ہے جس میں میں پیدا ہوا اور جس میں مجھ پر وحی نازل ہوئی" [Sahih Muslim 1162]۔ اعمال پیر اور جمعرات کو اللہ کے سامنے پیش کیے جاتے ہیں [Jami at-Tirmidhi 747]، اس لیے ان دنوں روزہ رکھنا مستحب ہے۔',
      tags: ['fasting mondays', 'voluntary fasting', 'monday thursday fast', 'sunnah fasts'],
    ),
  ];

  /// Offline keyword search across starter corpus items
  static List<CorpusItem> search(String query) {
    final tokens = query.toLowerCase().split(RegExp(r'[\s\?\!\.,]+')).where((t) => t.length > 1).toList();
    if (tokens.isEmpty) return [];

    final scored = <CorpusItem, int>{};

    for (final item in items) {
      int score = 0;
      final fullText = '${item.reference} ${item.english} ${item.urdu} ${item.arabic} ${item.tags.join(' ')}'.toLowerCase();
      for (final t in tokens) {
        if (fullText.contains(t)) score += 2;
        for (final tag in item.tags) {
          if (tag.toLowerCase() == t) {
            score += 5;
          } else if (tag.toLowerCase().contains(t)) {
            score += 3;
          }
        }
      }
      if (score > 0) {
        scored[item] = score;
      }
    }

    final sorted = scored.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.map((e) => e.key).toList();
  }
}
