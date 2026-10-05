-- ==============================================================================
-- Muslim Ultra - Starter RAG Corpus Seed Data (Spec §3 M3 & §5)
-- Full Quran & Sahih Hadith bulk ingestion is a planned follow-up pipeline.
-- ==============================================================================

insert into public.corpus_documents (collection, reference, content_arabic, content_english, content_urdu, metadata)
values
  -- 1. Juz 30 Selections
  (
    'quran_juz30',
    'Quran 112:1-4',
    'قُلْ هُوَ اللَّهُ أَحَدٌ ۝ اللَّهُ الصَّمَدُ ۝ لَمْ يَلِدْ وَلَمْ يُولَدْ ۝ وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    'Say, "He is Allah, [who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent."',
    'کہہ دیجئے: وہ اللہ ایک ہے، اللہ بے نیاز ہے، نہ اس کی کوئی اولاد ہے اور نہ وہ کسی کی اولاد ہے، اور کوئی اس کے برابر کا نہیں ہے۔',
    '{"surah": 112, "topic": "Tawhid"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 113:1-5',
    'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ ۝ مِن شَرِّ مَا خَلَقَ ۝ وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ ۝ وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ ۝ وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'Say, "I seek refuge in the Lord of daybreak From the evil of that which He created And from the evil of darkness when it settles And from the evil of the blowers in knots And from the evil of an envier when he envies."',
    'کہہ دیجئے: میں صبح کے رب کی پناہ مانگتا ہوں، ہر اس چیز کے شر سے جو اس نے پیدا کی، اور اندھیری رات کے شر سے جب وہ چھا جائے، اور گرہوں میں پھونکنے والیوں کے شر سے، اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔',
    '{"surah": 113, "topic": "Protection"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 114:1-6',
    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ ۝ مَلِكِ النَّاسِ ۝ إِلَٰهِ النَّاسِ ۝ مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ ۝ الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ ۝ مِنَ الْجِنَّةِ وَالنَّاسِ',
    'Say, "I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind."',
    'کہہ دیجئے: میں لوگوں کے رب کی پناہ مانگتا ہوں، لوگوں کے بادشاہ کی، لوگوں کے معبود کی، وسوسہ ڈالنے والے کے شر سے، جو لوگوں کے سینوں میں وسوسے ڈالتا ہے، جنات میں سے اور انسانوں میں سے۔',
    '{"surah": 114, "topic": "Protection from whispers"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 94:5-6',
    'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا ۝ إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
    'پس بے شک تنگی کے ساتھ آسانی ہے۔ یقیناً تنگی کے ساتھ آسانی ہے۔',
    '{"surah": 94, "topic": "Patience and Ease"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 97:1-3',
    'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ ۝ وَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ ۝ لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ',
    'Indeed, We sent the Quran down during the Night of Decree. And what can make you know what is the Night of Decree? The Night of Decree is better than a thousand months.',
    'بے شک ہم نے اس (قرآن) کو شب قدر میں نازل کیا۔ اور آپ کو کیا معلوم کہ شب قدر کیا ہے؟ شب قدر ہزار مہینوں سے بہتر ہے۔',
    '{"surah": 97, "topic": "Laylatul Qadr"}'::jsonb
  ),

  -- 2. 40 Duas Core Samples (Hisnul Muslim)
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 6306',
    'اللَّهُمَّ بِكَ أَصْبَحْنَا، وَبِكَ أَمْسَيْنَا، وَبِكَ نَحْيَا، وَبِكَ نَمُوتُ، وَإِلَيْكَ النُّشُورُ',
    'O Allah, by You we enter the morning and by You we enter the evening, by You we live and by You we die, and unto You is the resurrection.',
    'اے اللہ! تیرے ہی حکم سے ہم نے صبح کی اور تیرے ہی حکم سے ہم نے شام کی، اور تیرے ہی حکم سے ہم جیتے ہیں اور تیرے ہی حکم سے ہم مریں گے اور تیری ہی طرف اٹھنا ہے۔',
    '{"category": "Morning & Evening Adhkar"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 1162',
    'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ',
    'O Allah, I consult You through Your knowledge and seek ability through Your power, and I ask You from Your immense bounty.',
    'اے اللہ! میں تیرے علم کی برکت سے تجھ سے بھلائی مانگتا ہوں اور تیری قدرت کے ذریعے تجھ سے طاقت مانگتا ہوں اور تیرے فضل عظیم کا سوال کرتا ہوں۔',
    '{"category": "Istikhara Prayer"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 6346',
    'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ',
    'There is no deity worthy of worship except Allah, the Magnificent, the Forbearing. There is no deity except Allah, Lord of the Magnificent Throne.',
    'اللہ کے سوا کوئی معبود نہیں جو عظمت والا، بردبار ہے۔ اللہ کے سوا کوئی معبود نہیں جو عرش عظیم کا رب ہے۔',
    '{"category": "Dua for Relief from Distress"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 2357',
    'ذَهَبَ الظَّمَأُ وَابْتَلَّتِ الْعُرُوقُ وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ',
    'The thirst has gone, the veins are moistened, and the reward is confirmed, if Allah wills.',
    'پیاس بجھ گئی، رگیں تر ہو گئیں اور اجر ثابت ہو گیا اگر اللہ نے چاہا۔',
    '{"category": "Breaking Fast (Iftar)"}'::jsonb
  ),

  -- 3. Verified Islamic FAQs & Ikhtilaf Topics
  (
    'faqs_corpus',
    'Sahih al-Bukhari 735; Sunan Abi Dawud 748',
    'رَأَيْتُ رَسُولَ اللَّهِ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ إِذَا قَامَ فِي الصَّلَاةِ رَفَعَ يَدَيْهِ',
    'Scholarly views on raising hands (Rafa al-Yadain): In the Shafi''i and Hanbali madhabs, raising hands before and after Ruku is established Sunnah [Sahih al-Bukhari 735]. In the Hanafi madhab, hands are raised at the opening Takbir only [Sunan Abi Dawud 748]. Both positions stem from authentic narrations.',
    'نماز میں رفع الیدین: شافعی اور حنبلی فقہ میں رکوع سے پہلے اور بعد رفع الیدین مسنون ہے [Sahih al-Bukhari 735]، جبکہ حنفی فقہ میں تکبیر تحریمہ پر ہی ہاتھ اٹھائے جاتے ہیں [Sunan Abi Dawud 748]۔',
    '{"category": "Fiqh Differences", "topic": "Rafa al-Yadain"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Muwatta Malik 250; Sahih al-Bukhari 2012',
    'كَانَ النَّاسُ يَقُومُونَ فِي زَمَانِ عُمَرَ بْنِ الْخَطَّابِ فِي رَمَضَانَ بِثَلَاثٍ وَعِشْرِينَ رَكْعَةً',
    'Scholarly views on Taraweeh rakats: 8 rak''ahs is confirmed from the personal night prayer of the Prophet (pbuh) [Sahih al-Bukhari 2012], while 20 rak''ahs was practiced in congregation under Umar ibn al-Khattab and agreed upon by the 4 schools of Fiqh [Muwatta Malik 250].',
    'تراویح کی رکعات: 8 رکعت رسول اللہ ﷺ کے رات کے معمول سے اور 20 رکعت حضرت عمرؓ کے دور خلافت سے ثابت ہیں [Muwatta Malik 250; Sahih al-Bukhari 2012]۔',
    '{"category": "Fiqh Differences", "topic": "Taraweeh"}'::jsonb
  )
on conflict do nothing;
