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
    'قُلْ هُوَ اللَّهُ أَحَدٌ  اللَّهُ الصَّمَدُ  لَمْ يَلِدْ وَلَمْ يُولَدْ  وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    'Say, "He is Allah, [who is] One, Allah, the Eternal Refuge. He neither begets nor is born, Nor is there to Him any equivalent."',
    'کہہ دیجئے: وہ اللہ ایک ہے، اللہ بے نیاز ہے، نہ اس کی کوئی اولاد ہے اور نہ وہ کسی کی اولاد ہے، اور کوئی اس کے برابر کا نہیں ہے۔',
    '{"surah": 112, "topic": "Tawhid"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 113:1-5',
    'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ  مِن شَرِّ مَا خَلَقَ  وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ  وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ  وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    'Say, "I seek refuge in the Lord of daybreak From the evil of that which He created And from the evil of darkness when it settles And from the evil of the blowers in knots And from the evil of an envier when he envies."',
    'کہہ دیجئے: میں صبح کے رب کی پناہ مانگتا ہوں، ہر اس چیز کے شر سے جو اس نے پیدا کی، اور اندھیری رات کے شر سے جب وہ چھا جائے، اور گرہوں میں پھونکنے والیوں کے شر سے، اور حسد کرنے والے کے شر سے جب وہ حسد کرے۔',
    '{"surah": 113, "topic": "Protection"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 114:1-6',
    'قُلْ أَعُوذُ بِرَبِّ النَّاسِ  مَلِكِ النَّاسِ  إِلَٰهِ النَّاسِ  مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ  الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ  مِنَ الْجِنَّةِ وَالنَّاسِ',
    'Say, "I seek refuge in the Lord of mankind, The Sovereign of mankind, The God of mankind, From the evil of the retreating whisperer - Who whispers into the breasts of mankind - From among the jinn and mankind."',
    'کہہ دیجئے: میں لوگوں کے رب کی پناہ مانگتا ہوں، لوگوں کے بادشاہ کی، لوگوں کے معبود کی، وسوسہ ڈالنے والے کے شر سے، جو لوگوں کے سینوں میں وسوسے ڈالتا ہے، جنات میں سے اور انسانوں میں سے۔',
    '{"surah": 114, "topic": "Protection from whispers"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 94:5-6',
    'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا  إِنَّ مَعَ الْعُسْرِ يُسْرًا',
    'For indeed, with hardship [will be] ease. Indeed, with hardship [will be] ease.',
    'پس بے شک تنگی کے ساتھ آسانی ہے۔ یقیناً تنگی کے ساتھ آسانی ہے۔',
    '{"surah": 94, "topic": "Patience and Ease"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 97:1-3',
    'إِنَّا أَنزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ  وَمَا أَدْرَاكَ مَا لَيْلَةُ الْقَدْرِ  لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ شَهْرٍ',
    'Indeed, We sent the Quran down during the Night of Decree. And what can make you know what is the Night of Decree? The Night of Decree is better than a thousand months.',
    'بے شک ہم نے اس (قرآن) کو شب قدر میں نازل کیا۔ اور آپ کو کیا معلوم کہ شب قدر کیا ہے؟ شب قدر ہزار مہینوں سے بہتر ہے۔',
    '{"surah": 97, "topic": "Laylatul Qadr"}'::jsonb
  ),

  -- 2. 40 Duas Core Samples (Hisnul Muslim)
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 5068',
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

-- ==============================================================================
-- v2 EXPANSION (2026-10-07): +89 docs — 32 Juz 30 surahs (API-verified),
-- 37 Hisn al-Muslim duas, 20 FAQs. Embeddings generated via gemini-embedding-001.
-- NOTE: run AFTER the v1 seed above. Safe to re-run only on a fresh DB
-- (no dedup guard). Reference fix applied above: morning dua was mislabeled
-- 'Sahih al-Bukhari 6306' (that's Sayyid al-Istighfar); corrected to
-- 'Sunan Abi Dawud 5068'.
-- ==============================================================================

insert into public.corpus_documents
(collection, reference, content_arabic, content_english, content_urdu, metadata)
values
  (
    'quran_juz30',
    'Quran 78:1-40',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ عَمَّ يَتَسَآءَلُونَ  عَنِ ٱلنَّبَإِ ٱلْعَظِيمِ  ٱلَّذِى هُمْ فِيهِ مُخْتَلِفُونَ  كَلَّا سَيَعْلَمُونَ  ثُمَّ كَلَّا سَيَعْلَمُونَ  أَلَمْ نَجْعَلِ ٱلْأَرْضَ مِهَٰدًۭا  وَٱلْجِبَالَ أَوْتَادًۭا  وَخَلَقْنَٰكُمْ أَزْوَٰجًۭا  وَجَعَلْنَا نَوْمَكُمْ سُبَاتًۭا  وَجَعَلْنَا ٱلَّيْلَ لِبَاسًۭا  وَجَعَلْنَا ٱلنَّهَارَ مَعَاشًۭا  وَبَنَيْنَا فَوْقَكُمْ سَبْعًۭا شِدَادًۭا  وَجَعَلْنَا سِرَاجًۭا وَهَّاجًۭا  وَأَنزَلْنَا مِنَ ٱلْمُعْصِرَٰتِ مَآءًۭ ثَجَّاجًۭا  لِّنُخْرِجَ بِهِۦ حَبًّۭا وَنَبَاتًۭا  وَجَنَّٰتٍ أَلْفَافًا  إِنَّ يَوْمَ ٱلْفَصْلِ كَانَ مِيقَٰتًۭا  يَوْمَ يُنفَخُ فِى ٱلصُّورِ فَتَأْتُونَ أَفْوَاجًۭا  وَفُتِحَتِ ٱلسَّمَآءُ فَكَانَتْ أَبْوَٰبًۭا  وَسُيِّرَتِ ٱلْجِبَالُ فَكَانَتْ سَرَابًا  إِنَّ جَهَنَّمَ كَانَتْ مِرْصَادًۭا  لِّلطَّٰغِينَ مَـَٔابًۭا  لَّٰبِثِينَ فِيهَآ أَحْقَابًۭا  لَّا يَذُوقُونَ فِيهَا بَرْدًۭا وَلَا شَرَابًا  إِلَّا حَمِيمًۭا وَغَسَّاقًۭا  جَزَآءًۭ وِفَاقًا  إِنَّهُمْ كَانُوا۟ لَا يَرْجُونَ حِسَابًۭا  وَكَذَّبُوا۟ بِـَٔايَٰتِنَا كِذَّابًۭا  وَكُلَّ شَىْءٍ أَحْصَيْنَٰهُ كِتَٰبًۭا  فَذُوقُوا۟ فَلَن نَّزِيدَكُمْ إِلَّا عَذَابًا  إِنَّ لِلْمُتَّقِينَ مَفَازًا  حَدَآئِقَ وَأَعْنَٰبًۭا  وَكَوَاعِبَ أَتْرَابًۭا  وَكَأْسًۭا دِهَاقًۭا  لَّا يَسْمَعُونَ فِيهَا لَغْوًۭا وَلَا كِذَّٰبًۭا  جَزَآءًۭ مِّن رَّبِّكَ عَطَآءً حِسَابًۭا  رَّبِّ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضِ وَمَا بَيْنَهُمَا ٱلرَّحْمَٰنِ ۖ لَا يَمْلِكُونَ مِنْهُ خِطَابًۭا  يَوْمَ يَقُومُ ٱلرُّوحُ وَٱلْمَلَٰٓئِكَةُ صَفًّۭا ۖ لَّا يَتَكَلَّمُونَ إِلَّا مَنْ أَذِنَ لَهُ ٱلرَّحْمَٰنُ وَقَالَ صَوَابًۭا  ذَٰلِكَ ٱلْيَوْمُ ٱلْحَقُّ ۖ فَمَن شَآءَ ٱتَّخَذَ إِلَىٰ رَبِّهِۦ مَـَٔابًا  إِنَّآ أَنذَرْنَٰكُمْ عَذَابًۭا قَرِيبًۭا يَوْمَ يَنظُرُ ٱلْمَرْءُ مَا قَدَّمَتْ يَدَاهُ وَيَقُولُ ٱلْكَافِرُ يَٰلَيْتَنِى كُنتُ تُرَٰبًۢا',
    'About what are they asking one another? About the great news - That over which they are in disagreement. No! They are going to know. Then, no! They are going to know. Have We not made the earth a resting place? And the mountains as stakes? And We created you in pairs And made your sleep [a means for] rest And made the night as clothing And made the day for livelihood And constructed above you seven strong [heavens] And made [therein] a burning lamp And sent down, from the rain clouds, pouring water That We may bring forth thereby grain and vegetation And gardens of entwined growth. Indeed, the Day of Judgement is an appointed time - The Day the Horn is blown and you will come forth in multitudes And the heaven is opened and will become gateways And the mountains are removed and will be [but] a mirage. Indeed, Hell has been lying in wait For the transgressors, a place of return, In which they will remain for ages [unending]. They will not taste therein [any] coolness or drink Except scalding water and [foul] purulence - An appropriate recompense. Indeed, they were not expecting an account And denied Our verses with [emphatic] denial. But all things We have enumerated in writing. "So taste [the penalty], and never will We increase you except in torment." Indeed, for the righteous is attainment - Gardens and grapevines And full-breasted [companions] of equal age And a full cup. No ill speech will they hear therein or any falsehood - [As] reward from your Lord, [a generous] gift [made due by] account, [From] the Lord of the heavens and the earth and whatever is between them, the Most Merciful. They possess not from Him [authority for] speech. The Day that the Spirit and the angels will stand in rows, they will not speak except for one whom the Most Merciful permits, and he will say what is correct. That is the True Day; so he who wills may take to his Lord a [way of] return. Indeed, We have warned you of a near punishment on the Day when a man will observe what his hands have put forth and the disbeliever will say, "Oh, I wish that I were dust!"',
    '(یہ) لوگ کس چیز کی نسبت پوچھتے ہیں؟ (کیا) بڑی خبر کی نسبت؟ جس میں یہ اختلاف کر رہے ہیں دیکھو یہ عنقریب جان لیں گے پھر دیکھو یہ عنقریب جان لیں گے کیا ہم نے زمین کو بچھونا نہیں بنایا اور پہاڑوں کو (ا س کی) میخیں (نہیں ٹھہرایا؟) (بے شک بنایا) اور تم کو جوڑا جوڑابھی پیدا کیا اور نیند کو تمہارے لیے (موجب) آرام بنایا اور رات کو پردہ مقرر کیا اور دن کو معاش (کا وقت) قرار دیا اور تمہارے اوپر سات مضبوط (آسمان) بنائے اور (آفتاب کا) روشن چراغ بنایا اور نچڑتے بادلوں سے موسلا دھار مینہ برسایا تاکہ اس سے اناج اور سبزہ پیدا کریں اور گھنے گھنے باغ بےشک فیصلہ کا دن مقرر ہے جس دن صور پھونکا جائے گا تو تم لوگ غٹ کے غٹ آ موجود ہو گے اور آسمان کھولا جائے گا تو (اس میں) دروازے ہو جائیں گے اور پہاڑ چلائے جائیں گے تو وہ ریت ہو کر رہ جائیں گے بےشک دوزخ گھات میں ہے (یعنی) سرکشوں کا وہی ٹھکانہ ہے اس میں وہ مدتوں پڑے رہیں گے وہاں نہ ٹھنڈک کا مزہ چکھیں گے۔ نہ (کچھ) پینا (نصیب ہو گا) مگر گرم پانی اور بہتی پیپ (یہ) بدلہ ہے پورا پورا یہ لوگ حساب (آخرت) کی امید ہی نہیں رکھتے تھے اور ہماری آیتوں کو جھوٹ سمجھ کر جھٹلاتے رہتے تھے اور ہم نے ہر چیز کو لکھ کر ضبط کر رکھا ہے سو (اب) مزہ چکھو۔ ہم تم پر عذاب ہی بڑھاتے جائیں گے بے شک پرہیز گاروں کے لیے کامیابی ہے (یعنی) باغ اور انگور اور ہم عمر نوجوان عورتیں اور شراب کے چھلکتے ہوئے گلاس وہاں نہ بیہودہ بات سنیں گے نہ جھوٹ (خرافات) یہ تمہارے پروردگار کی طرف سے صلہ ہے انعام کثیر وہ جو آسمانوں اور زمین اور جو ان دونوں میں ہے سب کا مالک ہے بڑا مہربان کسی کو اس سے بات کرنے کا یارا نہیں ہوگا جس دن روح (الامین) اور فرشتے صف باندھ کر کھڑے ہوں گے تو کوئی بول نہ سکے گا مگر جس کو (خدائے رحمٰن) اجازت بخشے اور اس نے بات بھی درست کہی ہو یہ دن برحق ہے۔ پس جو شخص چاہے اپنے پروردگار کے پاس ٹھکانہ بنا ئے ہم نے تم کو عذاب سے جو عنقریب آنے والا ہے آگاہ کر دیا ہے جس دن ہر شخص ان (اعمال) کو جو اس نے آگے بھیجے ہوں گے دیکھ لے گا اور کافر کہے گا کہ اے کاش میں مٹی ہوتا',
    '{"surah": 78, "name": "An-Naba", "topic": "The Day of Judgment"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 79:1-46',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلنَّٰزِعَٰتِ غَرْقًۭا  وَٱلنَّٰشِطَٰتِ نَشْطًۭا  وَٱلسَّٰبِحَٰتِ سَبْحًۭا  فَٱلسَّٰبِقَٰتِ سَبْقًۭا  فَٱلْمُدَبِّرَٰتِ أَمْرًۭا  يَوْمَ تَرْجُفُ ٱلرَّاجِفَةُ  تَتْبَعُهَا ٱلرَّادِفَةُ  قُلُوبٌۭ يَوْمَئِذٍۢ وَاجِفَةٌ  أَبْصَٰرُهَا خَٰشِعَةٌۭ  يَقُولُونَ أَءِنَّا لَمَرْدُودُونَ فِى ٱلْحَافِرَةِ  أَءِذَا كُنَّا عِظَٰمًۭا نَّخِرَةًۭ  قَالُوا۟ تِلْكَ إِذًۭا كَرَّةٌ خَاسِرَةٌۭ  فَإِنَّمَا هِىَ زَجْرَةٌۭ وَٰحِدَةٌۭ  فَإِذَا هُم بِٱلسَّاهِرَةِ  هَلْ أَتَىٰكَ حَدِيثُ مُوسَىٰٓ  إِذْ نَادَىٰهُ رَبُّهُۥ بِٱلْوَادِ ٱلْمُقَدَّسِ طُوًى  ٱذْهَبْ إِلَىٰ فِرْعَوْنَ إِنَّهُۥ طَغَىٰ  فَقُلْ هَل لَّكَ إِلَىٰٓ أَن تَزَكَّىٰ  وَأَهْدِيَكَ إِلَىٰ رَبِّكَ فَتَخْشَىٰ  فَأَرَىٰهُ ٱلْءَايَةَ ٱلْكُبْرَىٰ  فَكَذَّبَ وَعَصَىٰ  ثُمَّ أَدْبَرَ يَسْعَىٰ  فَحَشَرَ فَنَادَىٰ  فَقَالَ أَنَا۠ رَبُّكُمُ ٱلْأَعْلَىٰ  فَأَخَذَهُ ٱللَّهُ نَكَالَ ٱلْءَاخِرَةِ وَٱلْأُولَىٰٓ  إِنَّ فِى ذَٰلِكَ لَعِبْرَةًۭ لِّمَن يَخْشَىٰٓ  ءَأَنتُمْ أَشَدُّ خَلْقًا أَمِ ٱلسَّمَآءُ ۚ بَنَىٰهَا  رَفَعَ سَمْكَهَا فَسَوَّىٰهَا  وَأَغْطَشَ لَيْلَهَا وَأَخْرَجَ ضُحَىٰهَا  وَٱلْأَرْضَ بَعْدَ ذَٰلِكَ دَحَىٰهَآ  أَخْرَجَ مِنْهَا مَآءَهَا وَمَرْعَىٰهَا  وَٱلْجِبَالَ أَرْسَىٰهَا  مَتَٰعًۭا لَّكُمْ وَلِأَنْعَٰمِكُمْ  فَإِذَا جَآءَتِ ٱلطَّآمَّةُ ٱلْكُبْرَىٰ  يَوْمَ يَتَذَكَّرُ ٱلْإِنسَٰنُ مَا سَعَىٰ  وَبُرِّزَتِ ٱلْجَحِيمُ لِمَن يَرَىٰ  فَأَمَّا مَن طَغَىٰ  وَءَاثَرَ ٱلْحَيَوٰةَ ٱلدُّنْيَا  فَإِنَّ ٱلْجَحِيمَ هِىَ ٱلْمَأْوَىٰ  وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِۦ وَنَهَى ٱلنَّفْسَ عَنِ ٱلْهَوَىٰ  فَإِنَّ ٱلْجَنَّةَ هِىَ ٱلْمَأْوَىٰ  يَسْـَٔلُونَكَ عَنِ ٱلسَّاعَةِ أَيَّانَ مُرْسَىٰهَا  فِيمَ أَنتَ مِن ذِكْرَىٰهَآ  إِلَىٰ رَبِّكَ مُنتَهَىٰهَآ  إِنَّمَآ أَنتَ مُنذِرُ مَن يَخْشَىٰهَا  كَأَنَّهُمْ يَوْمَ يَرَوْنَهَا لَمْ يَلْبَثُوٓا۟ إِلَّا عَشِيَّةً أَوْ ضُحَىٰهَا',
    'By those [angels] who extract with violence And [by] those who remove with ease And [by] those who glide [as if] swimming And those who race each other in a race And those who arrange [each] matter, On the Day the blast [of the Horn] will convulse [creation], There will follow it the subsequent [one]. Hearts, that Day, will tremble, Their eyes humbled. They are [presently] saying, "Will we indeed be returned to [our] former state [of life]? Even if we should be decayed bones? They say, "That, then, would be a losing return." Indeed, it will be but one shout, And suddenly they will be [alert] upon the earth''s surface. Has there reached you the story of Moses? - When his Lord called to him in the sacred valley of Tuwa, "Go to Pharaoh. Indeed, he has transgressed. And say to him, ''Would you [be willing to] purify yourself And let me guide you to your Lord so you would fear [Him]?''" And he showed him the greatest sign, But Pharaoh denied and disobeyed. Then he turned his back, striving. And he gathered [his people] and called out And said, "I am your most exalted lord." So Allah seized him in exemplary punishment for the last and the first [transgression]. Indeed in that is a warning for whoever would fear [Allah]. Are you a more difficult creation or is the heaven? Allah constructed it. He raised its ceiling and proportioned it. And He darkened its night and extracted its brightness. And after that He spread the earth. He extracted from it its water and its pasture, And the mountains He set firmly As provision for you and your grazing livestock. But when there comes the greatest Overwhelming Calamity - The Day when man will remember that for which he strove, And Hellfire will be exposed for [all] those who see - So as for he who transgressed And preferred the life of the world, Then indeed, Hellfire will be [his] refuge. But as for he who feared the position of his Lord and prevented the soul from [unlawful] inclination, Then indeed, Paradise will be [his] refuge. They ask you, [O Muhammad], about the Hour: when is its arrival? In what [position] are you that you should mention it? To your Lord is its finality. You are only a warner for those who fear it. It will be, on the Day they see it, as though they had not remained [in the world] except for an afternoon or a morning thereof.',
    'ان (فرشتوں) کی قسم جو ڈوب کر کھینچ لیتے ہیں اور ان کی جو آسانی سے کھول دیتے ہیں اور ان کی جو تیرتے پھرتے ہیں پھر لپک کر آگے بڑھتے ہیں پھر (دنیا کے) کاموں کا انتظام کرتے ہیں (کہ وہ دن آ کر رہے گا) جس دن زمین کو بھونچال آئے گا پھر اس کے پیچھے اور (بھونچال) آئے گا اس دن (لوگوں) کے دل خائف ہو رہے ہوں گے اور آنکھیں جھکی ہوئی (کافر) کہتے ہیں کیا ہم الٹے پاؤں پھر لوٹ جائیں گے بھلا جب ہم کھوکھلی ہڈیاں ہو جائیں گے (تو پھر زندہ کئے جائیں گے) کہتے ہیں کہ یہ لوٹنا تو (موجب) زیاں ہے وہ تو صرف ایک ڈانٹ ہوگی اس وقت وہ (سب) میدان (حشر) میں آ جمع ہوں گے بھلا تم کو موسیٰ کی حکایت پہنچی ہے جب اُن کے پروردگار نے ان کو پاک میدان (یعنی) طویٰ میں پکارا (اور حکم دیا) کہ فرعون کے پاس جاؤ وہ سرکش ہو رہا ہے اور (اس سے) کہو کہ کیا تو چاہتا ہے کہ پاک ہو جائے؟ اور میں تجھے تیرے پروردگار کا رستہ بتاؤں تاکہ تجھ کو خوف (پیدا) ہو غرض انہوں نے اس کو بڑی نشانی دکھائی مگر اس نے جھٹلایا اور نہ مانا پھر لوٹ گیا اور تدبیریں کرنے لگا اور (لوگوں کو) اکٹھا کیا اور پکارا کہنے لگا کہ تمہارا سب سے بڑا مالک میں ہوں تو خدا نے اس کو دنیا اور آخرت (دونوں) کے عذاب میں پکڑ لیا جو شخص (خدا سے) ڈر رکھتا ہے اس کے لیے اس (قصے) میں عبرت ہے بھلا تمہارا بنانا آسان ہے یا آسمان کا؟ اسی نے اس کو بنایا اس کی چھت کو اونچا کیا اور پھر اسے برابر کر دیا اور اسی نے رات کو تاریک بنایا اور (دن کو) دھوپ نکالی اور اس کے بعد زمین کو پھیلا دیا اسی نے اس میں سے اس کا پانی نکالا اور چارا اگایا اور اس پر پہاڑوں کابوجھ رکھ دیا یہ سب کچھ تمہارے اور تمہارے چارپایوں کے فائدے کے لیے (کیا) تو جب بڑی آفت آئے گی اس دن انسان اپنے کاموں کو یاد کرے گا اور دوزخ دیکھنے والے کے سامنے نکال کر رکھ دی جائے گی تو جس نے سرکشی کی اور دنیا کی زندگی کو مقدم سمجھا اس کا ٹھکانہ دوزخ ہے اور جو اپنے پروردگار کے سامنے کھڑے ہونے سے ڈرتا اور جی کو خواہشوں سے روکتا رہا اس کا ٹھکانہ بہشت ہے (اے پیغمبر، لوگ) تم سے قیامت کے بارے میں پوچھتے ہیں کہ اس کا وقوع کب ہو گا؟ سو تم اس کے ذکر سے کس فکر میں ہو اس کا منتہا (یعنی واقع ہونے کا وقت) تمہارے پروردگار ہی کو (معلوم ہے) جو شخص اس سے ڈر رکھتا ہے تم تو اسی کو ڈر سنانے والے ہو جب وہ اس کو دیکھیں گے (تو ایسا خیال کریں گے) کہ گویا (دنیا میں صرف) ایک شام یا صبح رہے تھے',
    '{"surah": 79, "name": "An-Nazi''at", "topic": "Resurrection"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 80:1-42',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ عَبَسَ وَتَوَلَّىٰٓ  أَن جَآءَهُ ٱلْأَعْمَىٰ  وَمَا يُدْرِيكَ لَعَلَّهُۥ يَزَّكَّىٰٓ  أَوْ يَذَّكَّرُ فَتَنفَعَهُ ٱلذِّكْرَىٰٓ  أَمَّا مَنِ ٱسْتَغْنَىٰ  فَأَنتَ لَهُۥ تَصَدَّىٰ  وَمَا عَلَيْكَ أَلَّا يَزَّكَّىٰ  وَأَمَّا مَن جَآءَكَ يَسْعَىٰ  وَهُوَ يَخْشَىٰ  فَأَنتَ عَنْهُ تَلَهَّىٰ  كَلَّآ إِنَّهَا تَذْكِرَةٌۭ  فَمَن شَآءَ ذَكَرَهُۥ  فِى صُحُفٍۢ مُّكَرَّمَةٍۢ  مَّرْفُوعَةٍۢ مُّطَهَّرَةٍۭ  بِأَيْدِى سَفَرَةٍۢ  كِرَامٍۭ بَرَرَةٍۢ  قُتِلَ ٱلْإِنسَٰنُ مَآ أَكْفَرَهُۥ  مِنْ أَىِّ شَىْءٍ خَلَقَهُۥ  مِن نُّطْفَةٍ خَلَقَهُۥ فَقَدَّرَهُۥ  ثُمَّ ٱلسَّبِيلَ يَسَّرَهُۥ  ثُمَّ أَمَاتَهُۥ فَأَقْبَرَهُۥ  ثُمَّ إِذَا شَآءَ أَنشَرَهُۥ  كَلَّا لَمَّا يَقْضِ مَآ أَمَرَهُۥ  فَلْيَنظُرِ ٱلْإِنسَٰنُ إِلَىٰ طَعَامِهِۦٓ  أَنَّا صَبَبْنَا ٱلْمَآءَ صَبًّۭا  ثُمَّ شَقَقْنَا ٱلْأَرْضَ شَقًّۭا  فَأَنۢبَتْنَا فِيهَا حَبًّۭا  وَعِنَبًۭا وَقَضْبًۭا  وَزَيْتُونًۭا وَنَخْلًۭا  وَحَدَآئِقَ غُلْبًۭا  وَفَٰكِهَةًۭ وَأَبًّۭا  مَّتَٰعًۭا لَّكُمْ وَلِأَنْعَٰمِكُمْ  فَإِذَا جَآءَتِ ٱلصَّآخَّةُ  يَوْمَ يَفِرُّ ٱلْمَرْءُ مِنْ أَخِيهِ  وَأُمِّهِۦ وَأَبِيهِ  وَصَٰحِبَتِهِۦ وَبَنِيهِ  لِكُلِّ ٱمْرِئٍۢ مِّنْهُمْ يَوْمَئِذٍۢ شَأْنٌۭ يُغْنِيهِ  وُجُوهٌۭ يَوْمَئِذٍۢ مُّسْفِرَةٌۭ  ضَاحِكَةٌۭ مُّسْتَبْشِرَةٌۭ  وَوُجُوهٌۭ يَوْمَئِذٍ عَلَيْهَا غَبَرَةٌۭ  تَرْهَقُهَا قَتَرَةٌ  أُو۟لَٰٓئِكَ هُمُ ٱلْكَفَرَةُ ٱلْفَجَرَةُ',
    'The Prophet frowned and turned away Because there came to him the blind man, [interrupting]. But what would make you perceive, [O Muhammad], that perhaps he might be purified Or be reminded and the remembrance would benefit him? As for he who thinks himself without need, To him you give attention. And not upon you [is any blame] if he will not be purified. But as for he who came to you striving [for knowledge] While he fears [Allah], From him you are distracted. No! Indeed, these verses are a reminder; So whoever wills may remember it. [It is recorded] in honored sheets, Exalted and purified, [Carried] by the hands of messenger-angels, Noble and dutiful. Cursed is man; how disbelieving is he. From what substance did He create him? From a sperm-drop He created him and destined for him; Then He eased the way for him; Then He causes his death and provides a grave for him. Then when He wills, He will resurrect him. No! Man has not yet accomplished what He commanded him. Then let mankind look at his food - How We poured down water in torrents, Then We broke open the earth, splitting [it with sprouts], And caused to grow within it grain And grapes and herbage And olive and palm trees And gardens of dense shrubbery And fruit and grass - [As] enjoyment for you and your grazing livestock. But when there comes the Deafening Blast On the Day a man will flee from his brother And his mother and his father And his wife and his children, For every man, that Day, will be a matter adequate for him. [Some] faces, that Day, will be bright - Laughing, rejoicing at good news. And [other] faces, that Day, will have upon them dust. Blackness will cover them. Those are the disbelievers, the wicked ones.',
    '(محمد مصطفٰےﷺ) ترش رُو ہوئے اور منہ پھیر بیٹھے کہ ان کے پاس ایک نابینا آیا اور تم کو کیا خبر شاید وہ پاکیزگی حاصل کرتا یا سوچتا تو سمجھانا اسے فائدہ دیتا جو پروا نہیں کرتا اس کی طرف تو تم توجہ کرتے ہو حالانکہ اگر وہ نہ سنورے تو تم پر کچھ (الزام) نہیں اور جو تمہارے پاس دوڑتا ہوا آیا اور (خدا سے) ڈرتا ہے اس سے تم بےرخی کرتے ہو دیکھو یہ (قرآن) نصیحت ہے پس جو چاہے اسے یاد رکھے قابل ادب ورقوں میں (لکھا ہوا) جو بلند مقام پر رکھے ہوئے (اور) پاک ہیں لکھنے والوں کے ہاتھوں میں جو سردار اور نیکو کار ہیں انسان ہلاک ہو جائے کیسا ناشکرا ہے اُسے (خدا نے) کس چیز سے بنایا؟ نطفے سے بنایا پھر اس کا اندازہ مقرر کیا پھر اس کے لیے رستہ آسان کر دیا پھر اس کو موت دی پھر قبر میں دفن کرایا پھر جب چاہے گا اسے اٹھا کھڑا کرے گا کچھ شک نہیں کہ خدا نے اسے جو حکم دیا اس نے اس پر عمل نہ کیا تو انسان کو چاہیئے کہ اپنے کھانے کی طرف نظر کرے بے شک ہم ہی نے پانی برسایا پھر ہم ہی نے زمین کو چیرا پھاڑا پھر ہم ہی نے اس میں اناج اگایا اور انگور اور ترکاری اور زیتون اور کھجوریں اور گھنے گھنے باغ اور میوے اور چارا (یہ سب کچھ) تمہارے اور تمہارے چارپایوں کے لیے بنایا تو جب (قیامت کا) غل مچے گا اس دن آدمی اپنے بھائی سے دور بھاگے گا اور اپنی ماں اور اپنے باپ سے اور اپنی بیوی اور اپنے بیٹے سے ہر شخص اس روز ایک فکر میں ہو گا جو اسے (مصروفیت کے لیے) بس کرے گا اور کتنے منہ اس روز چمک رہے ہوں گے خنداں و شاداں (یہ مومنان نیکو کار ہیں) اور کتنے منہ ہوں گے جن پر گرد پڑ رہی ہو گی (اور) سیاہی چڑھ رہی ہو گی یہ کفار بدکردار ہیں',
    '{"surah": 80, "name": "Abasa", "topic": "The Prophet''s mission"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 81:1-29',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ إِذَا ٱلشَّمْسُ كُوِّرَتْ  وَإِذَا ٱلنُّجُومُ ٱنكَدَرَتْ  وَإِذَا ٱلْجِبَالُ سُيِّرَتْ  وَإِذَا ٱلْعِشَارُ عُطِّلَتْ  وَإِذَا ٱلْوُحُوشُ حُشِرَتْ  وَإِذَا ٱلْبِحَارُ سُجِّرَتْ  وَإِذَا ٱلنُّفُوسُ زُوِّجَتْ  وَإِذَا ٱلْمَوْءُۥدَةُ سُئِلَتْ  بِأَىِّ ذَنۢبٍۢ قُتِلَتْ  وَإِذَا ٱلصُّحُفُ نُشِرَتْ  وَإِذَا ٱلسَّمَآءُ كُشِطَتْ  وَإِذَا ٱلْجَحِيمُ سُعِّرَتْ  وَإِذَا ٱلْجَنَّةُ أُزْلِفَتْ  عَلِمَتْ نَفْسٌۭ مَّآ أَحْضَرَتْ  فَلَآ أُقْسِمُ بِٱلْخُنَّسِ  ٱلْجَوَارِ ٱلْكُنَّسِ  وَٱلَّيْلِ إِذَا عَسْعَسَ  وَٱلصُّبْحِ إِذَا تَنَفَّسَ  إِنَّهُۥ لَقَوْلُ رَسُولٍۢ كَرِيمٍۢ  ذِى قُوَّةٍ عِندَ ذِى ٱلْعَرْشِ مَكِينٍۢ  مُّطَاعٍۢ ثَمَّ أَمِينٍۢ  وَمَا صَاحِبُكُم بِمَجْنُونٍۢ  وَلَقَدْ رَءَاهُ بِٱلْأُفُقِ ٱلْمُبِينِ  وَمَا هُوَ عَلَى ٱلْغَيْبِ بِضَنِينٍۢ  وَمَا هُوَ بِقَوْلِ شَيْطَٰنٍۢ رَّجِيمٍۢ  فَأَيْنَ تَذْهَبُونَ  إِنْ هُوَ إِلَّا ذِكْرٌۭ لِّلْعَٰلَمِينَ  لِمَن شَآءَ مِنكُمْ أَن يَسْتَقِيمَ  وَمَا تَشَآءُونَ إِلَّآ أَن يَشَآءَ ٱللَّهُ رَبُّ ٱلْعَٰلَمِينَ',
    'When the sun is wrapped up [in darkness] And when the stars fall, dispersing, And when the mountains are removed And when full-term she-camels are neglected And when the wild beasts are gathered And when the seas are filled with flame And when the souls are paired And when the girl [who was] buried alive is asked For what sin she was killed And when the pages are made public And when the sky is stripped away And when Hellfire is set ablaze And when Paradise is brought near, A soul will [then] know what it has brought [with it]. So I swear by the retreating stars - Those that run [their courses] and disappear - And by the night as it closes in And by the dawn when it breathes [That] indeed, the Qur''an is a word [conveyed by] a noble messenger [Who is] possessed of power and with the Owner of the Throne, secure [in position], Obeyed there [in the heavens] and trustworthy. And your companion is not [at all] mad. And he has already seen Gabriel in the clear horizon. And Muhammad is not a withholder of [knowledge of] the unseen. And the Qur''an is not the word of a devil, expelled [from the heavens]. So where are you going? It is not except a reminder to the worlds For whoever wills among you to take a right course. And you do not will except that Allah wills - Lord of the worlds.',
    'جب سورج لپیٹ لیا جائے گا جب تارے بےنور ہو جائیں گے اور جب پہاڑ چلائے جائیں گے اور جب بیانے والی اونٹنیاں بےکار ہو جائیں گی اور جب وحشی جانور جمع اکٹھے ہو جائیں گے اور جب دریا آگ ہو جائیں گے اور جب روحیں (بدنوں سے) ملا دی جائیں گی اور جب لڑکی سے جو زندہ دفنا دی گئی ہو پوچھا جائے گا کہ وہ کس گناہ پرماری گئی اور جب (عملوں کے) دفتر کھولے جائیں گے اور جب آسمانوں کی کھال کھینچ لی جائے گی اور جب دوزخ (کی آگ) بھڑکائی جائے گی اور بہشت جب قریب لائی جائے گی تب ہر شخص معلوم کر لے گا کہ وہ کیا لے کر آیا ہے ہم کو ان ستاروں کی قسم جو پیچھے ہٹ جاتے ہیں (اور) جو سیر کرتے اور غائب ہو جاتے ہیں اور رات کی قسم جب ختم ہونے لگتی ہے اور صبح کی قسم جب نمودار ہوتی ہے کہ بےشک یہ (قرآن) فرشتہٴ عالی مقام کی زبان کا پیغام ہے جو صاحب قوت مالک عرش کے ہاں اونچے درجے والا ہے سردار (اور) امانت دار ہے اور (مکے والو) تمہارے رفیق (یعنی محمدﷺ) دیوانے نہیں ہیں بےشک انہوں نے اس (فرشتے) کو (آسمان کے کھلے یعنی) مشرقی کنارے پر دیکھا ہے اور وہ پوشیدہ باتوں (کے ظاہر کرنے) میں بخیل نہیں اور یہ شیطان مردود کا کلام نہیں پھر تم کدھر جا رہے ہو یہ تو جہان کے لوگوں کے لیے نصیحت ہے (یعنی) اس کے لیے جو تم میں سے سیدھی چال چلنا چاہے اور تم کچھ بھی نہیں چاہ سکتے مگر وہی جو خدائے رب العالمین چاہے',
    '{"surah": 81, "name": "At-Takwir", "topic": "Signs of the Last Day"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 82:1-19',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ إِذَا ٱلسَّمَآءُ ٱنفَطَرَتْ  وَإِذَا ٱلْكَوَاكِبُ ٱنتَثَرَتْ  وَإِذَا ٱلْبِحَارُ فُجِّرَتْ  وَإِذَا ٱلْقُبُورُ بُعْثِرَتْ  عَلِمَتْ نَفْسٌۭ مَّا قَدَّمَتْ وَأَخَّرَتْ  يَٰٓأَيُّهَا ٱلْإِنسَٰنُ مَا غَرَّكَ بِرَبِّكَ ٱلْكَرِيمِ  ٱلَّذِى خَلَقَكَ فَسَوَّىٰكَ فَعَدَلَكَ  فِىٓ أَىِّ صُورَةٍۢ مَّا شَآءَ رَكَّبَكَ  كَلَّا بَلْ تُكَذِّبُونَ بِٱلدِّينِ  وَإِنَّ عَلَيْكُمْ لَحَٰفِظِينَ  كِرَامًۭا كَٰتِبِينَ  يَعْلَمُونَ مَا تَفْعَلُونَ  إِنَّ ٱلْأَبْرَارَ لَفِى نَعِيمٍۢ  وَإِنَّ ٱلْفُجَّارَ لَفِى جَحِيمٍۢ  يَصْلَوْنَهَا يَوْمَ ٱلدِّينِ  وَمَا هُمْ عَنْهَا بِغَآئِبِينَ  وَمَآ أَدْرَىٰكَ مَا يَوْمُ ٱلدِّينِ  ثُمَّ مَآ أَدْرَىٰكَ مَا يَوْمُ ٱلدِّينِ  يَوْمَ لَا تَمْلِكُ نَفْسٌۭ لِّنَفْسٍۢ شَيْـًۭٔا ۖ وَٱلْأَمْرُ يَوْمَئِذٍۢ لِّلَّهِ',
    'When the sky breaks apart And when the stars fall, scattering, And when the seas are erupted And when the [contents of] graves are scattered, A soul will [then] know what it has put forth and kept back. O mankind, what has deceived you concerning your Lord, the Generous, Who created you, proportioned you, and balanced you? In whatever form He willed has He assembled you. No! But you deny the Recompense. And indeed, [appointed] over you are keepers, Noble and recording; They know whatever you do. Indeed, the righteous will be in pleasure, And indeed, the wicked will be in Hellfire. They will [enter to] burn therein on the Day of Recompense, And never therefrom will they be absent. And what can make you know what is the Day of Recompense? Then, what can make you know what is the Day of Recompense? It is the Day when a soul will not possess for another soul [power to do] a thing; and the command, that Day, is [entirely] with Allah.',
    'جب آسمان پھٹ جائے گا اور جب تارے جھڑ پڑیں گے اور جب دریا بہہ (کر ایک دوسرے سے مل) جائیں گے اور جب قبریں اکھیڑ دی جائیں گی تب ہر شخص معلوم کرلے گا کہ اس نے آگے کیا بھیجا تھا اور پیچھے کیا چھوڑا تھا اے انسان تجھ کو اپنے پروردگار کرم گستر کے باب میں کس چیز نے دھوکا دیا (وہی تو ہے) جس نے تجھے بنایا اور (تیرے اعضا کو) ٹھیک کیا اور (تیرے قامت کو) معتدل رکھا اور جس صورت میں چاہا تجھے جوڑ دیا مگر ہیہات تم لوگ جزا کو جھٹلاتے ہو حالانکہ تم پر نگہبان مقرر ہیں عالی قدر (تمہاری باتوں کے) لکھنے والے جو تم کرتے ہو وہ اسے جانتے ہیں بے شک نیکوکار نعمتوں (کی بہشت) میں ہوں گے۔ اور بدکردار دوزخ میں (یعنی) جزا کے دن اس میں داخل ہوں گے اور اس سے چھپ نہیں سکیں گے اور تمہیں کیا معلوم کہ جزا کا دن کیسا ہے؟ پھر تمہیں کیا معلوم کہ جزا کا دن کیسا ہے؟ جس روز کوئی کسی کا بھلا نہ کر سکے گا اور حکم اس روز خدا ہی کا ہو گا',
    '{"surah": 82, "name": "Al-Infitar", "topic": "The Splitting"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 83:1-36',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَيْلٌۭ لِّلْمُطَفِّفِينَ  ٱلَّذِينَ إِذَا ٱكْتَالُوا۟ عَلَى ٱلنَّاسِ يَسْتَوْفُونَ  وَإِذَا كَالُوهُمْ أَو وَّزَنُوهُمْ يُخْسِرُونَ  أَلَا يَظُنُّ أُو۟لَٰٓئِكَ أَنَّهُم مَّبْعُوثُونَ  لِيَوْمٍ عَظِيمٍۢ  يَوْمَ يَقُومُ ٱلنَّاسُ لِرَبِّٱلْعَٰلَمِينَ  كَلَّآ إِنَّ كِتَٰبَ ٱلْفُجَّارِ لَفِى سِجِّينٍۢ  وَمَآ أَدْرَىٰكَ مَا سِجِّينٌۭ  كِتَٰبٌۭ مَّرْقُومٌۭ  وَيْلٌۭ يَوْمَئِذٍۢ لِّلْمُكَذِّبِينَ  ٱلَّذِينَ يُكَذِّبُونَ بِيَوْمِ ٱلدِّينِ  وَمَا يُكَذِّبُ بِهِۦٓ إِلَّا كُلُّ مُعْتَدٍ أَثِيمٍ  إِذَا تُتْلَىٰ عَلَيْهِ ءَايَٰتُنَا قَالَ أَسَٰطِيرُ ٱلْأَوَّلِينَ  كَلَّا ۖ بَلْ ۜ رَانَ عَلَىٰ قُلُوبِهِم مَّا كَانُوا۟ يَكْسِبُونَ  كَلَّآ إِنَّهُمْ عَن رَّبِّهِمْ يَوْمَئِذٍۢ لَّمَحْجُوبُونَ  ثُمَّ إِنَّهُمْ لَصَالُوا۟ ٱلْجَحِيمِ  ثُمَّ يُقَالُ هَٰذَا ٱلَّذِى كُنتُم بِهِۦ تُكَذِّبُونَ  كَلَّآ إِنَّ كِتَٰبَ ٱلْأَبْرَارِ لَفِى عِلِّيِّينَ  وَمَآ أَدْرَىٰكَ مَا عِلِّيُّونَ  كِتَٰبٌۭ مَّرْقُومٌۭ  يَشْهَدُهُ ٱلْمُقَرَّبُونَ  إِنَّ ٱلْأَبْرَارَ لَفِى نَعِيمٍ  عَلَى ٱلْأَرَآئِكِ يَنظُرُونَ  تَعْرِفُ فِى وُجُوهِهِمْ نَضْرَةَ ٱلنَّعِيمِ  يُسْقَوْنَ مِن رَّحِيقٍۢ مَّخْتُومٍ  خِتَٰمُهُۥ مِسْكٌۭ ۚ وَفِى ذَٰلِكَ فَلْيَتَنَافَسِ ٱلْمُتَنَٰفِسُونَ  وَمِزَاجُهُۥ مِن تَسْنِيمٍ  عَيْنًۭا يَشْرَبُ بِهَا ٱلْمُقَرَّبُونَ  إِنَّ ٱلَّذِينَ أَجْرَمُوا۟ كَانُوا۟ مِنَ ٱلَّذِينَ ءَامَنُوا۟ يَضْحَكُونَ  وَإِذَا مَرُّوا۟ بِهِمْ يَتَغَامَزُونَ  وَإِذَا ٱنقَلَبُوٓا۟ إِلَىٰٓ أَهْلِهِمُ ٱنقَلَبُوا۟ فَكِهِينَ  وَإِذَا رَأَوْهُمْ قَالُوٓا۟ إِنَّ هَٰٓؤُلَآءِ لَضَآلُّونَ  وَمَآ أُرْسِلُوا۟ عَلَيْهِمْ حَٰفِظِينَ  فَٱلْيَوْمَ ٱلَّذِينَ ءَامَنُوا۟ مِنَ ٱلْكُفَّارِ يَضْحَكُونَ  عَلَى ٱلْأَرَآئِكِ يَنظُرُونَ  هَلْ ثُوِّبَ ٱلْكُفَّارُ مَا كَانُوا۟ يَفْعَلُونَ',
    'Woe to those who give less [than due], Who, when they take a measure from people, take in full. But if they give by measure or by weight to them, they cause loss. Do they not think that they will be resurrected For a tremendous Day - The Day when mankind will stand before the Lord of the worlds? No! Indeed, the record of the wicked is in sijjeen. And what can make you know what is sijjeen? It is [their destination recorded in] a register inscribed. Woe, that Day, to the deniers, Who deny the Day of Recompense. And none deny it except every sinful transgressor. When Our verses are recited to him, he says, "Legends of the former peoples." No! Rather, the stain has covered their hearts of that which they were earning. No! Indeed, from their Lord, that Day, they will be partitioned. Then indeed, they will [enter and] burn in Hellfire. Then it will be said [to them], "This is what you used to deny." No! Indeed, the record of the righteous is in ''illiyyun. And what can make you know what is ''illiyyun? It is [their destination recorded in] a register inscribed Which is witnessed by those brought near [to Allah]. Indeed, the righteous will be in pleasure On adorned couches, observing. You will recognize in their faces the radiance of pleasure. They will be given to drink [pure] wine [which was] sealed. The last of it is musk. So for this let the competitors compete. And its mixture is of Tasneem, A spring from which those near [to Allah] drink. Indeed, those who committed crimes used to laugh at those who believed. And when they passed by them, they would exchange derisive glances. And when they returned to their people, they would return jesting. And when they saw them, they would say, "Indeed, those are truly lost." But they had not been sent as guardians over them. So Today those who believed are laughing at the disbelievers, On adorned couches, observing. Have the disbelievers [not] been rewarded [this Day] for what they used to do?',
    'ناپ اور تول میں کمی کرنے والوں کے لیے خرابی ہے جو لوگوں سے ناپ کر لیں تو پورا لیں اور جب ان کو ناپ کر یا تول کر دیں تو کم کر دیں کیا یہ لوگ نہیں جانتے کہ اٹھائے بھی جائیں گے (یعنی) ایک بڑے (سخت) دن میں جس دن (تمام) لوگ رب العالمین کے سامنے کھڑے ہوں گے سن رکھو کہ بدکارروں کے اعمال سجّین میں ہیں اور تم کیا جانتے ہوں کہ سجّین کیا چیز ہے؟ ایک دفتر ہے لکھا ہوا اس دن جھٹلانے والوں کی خرابی ہے (یعنی) جو انصاف کے دن کو جھٹلاتے ہیں اور اس کو جھٹلاتا وہی ہے جو حد سے نکل جانے والا گنہگار ہے جب اس کو ہماری آیتیں سنائی جاتی ہیں تو کہتا ہے کہ یہ تو اگلے لوگوں کے افسانے ہیں دیکھو یہ جو (اعمال بد) کرتے ہیں ان کا ان کے دلوں پر زنگ بیٹھ گیا ہے بےشک یہ لوگ اس روز اپنے پروردگار (کے دیدار) سے اوٹ میں ہوں گے پھر دوزخ میں جا داخل ہوں گے پھر ان سے کہا جائے گا کہ یہ وہی چیز ہے جس کو تم جھٹلاتے تھے (یہ بھی) سن رکھو کہ نیکوکاروں کے اعمال علیین میں ہیں اور تم کو کیا معلوم کہ علیین کیا چیز ہے؟ ایک دفتر ہے لکھا ہوا جس کے پاس مقرب (فرشتے) حاضر رہتے ہیں بےشک نیک لوگ چین میں ہوں گے تختوں پر بیٹھے ہوئے نظارے کریں گے تم ان کے چہروں ہی سے راحت کی تازگی معلوم کر لو گے ان کو خالص شراب سربمہر پلائی جائے گی جس کی مہر مشک کی ہو گی تو (نعمتوں کے) شائقین کو چاہیے کہ اسی سے رغبت کریں اور اس میں تسنیم (کے پانی) کی آمیزش ہو گی وہ ایک چشمہ ہے جس میں سے (خدا کے) مقرب پیئیں گے جو گنہگار (یعنی کفار) ہیں وہ (دنیا میں) مومنوں سے ہنسی کیا کرتے تھے اور جب ان کے پاس سے گزرتے تو حقارت سے اشارے کرتے اور جب اپنے گھر کو لوٹتے تو اتراتے ہوئے لوٹتے اور جب ان (مومنوں) کو دیکھتے تو کہتے کہ یہ تو گمراہ ہیں حالانکہ وہ ان پر نگراں بنا کر نہیں بھیجے گئے تھے تو آج مومن کافروں سے ہنسی کریں گے (اور) تختوں پر (بیٹھے ہوئے ان کا حال) دیکھ رہے ہوں گے تو کافروں کو ان کے عملوں کا (پورا پورا) بدلہ مل گیا',
    '{"surah": 83, "name": "Al-Mutaffifin", "topic": "Justice in dealings"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 84:1-25',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ إِذَا ٱلسَّمَآءُ ٱنشَقَّتْ  وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ  وَإِذَا ٱلْأَرْضُ مُدَّتْ  وَأَلْقَتْ مَا فِيهَا وَتَخَلَّتْ  وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ  يَٰٓأَيُّهَا ٱلْإِنسَٰنُ إِنَّكَ كَادِحٌ إِلَىٰ رَبِّكَ كَدْحًۭا فَمُلَٰقِيهِ  فَأَمَّا مَنْ أُوتِىَ كِتَٰبَهُۥ بِيَمِينِهِۦ  فَسَوْفَ يُحَاسَبُ حِسَابًۭا يَسِيرًۭا  وَيَنقَلِبُ إِلَىٰٓ أَهْلِهِۦ مَسْرُورًۭا  وَأَمَّا مَنْ أُوتِىَ كِتَٰبَهُۥ وَرَآءَ ظَهْرِهِۦ  فَسَوْفَ يَدْعُوا۟ ثُبُورًۭا  وَيَصْلَىٰ سَعِيرًا  إِنَّهُۥ كَانَ فِىٓ أَهْلِهِۦ مَسْرُورًا  إِنَّهُۥ ظَنَّ أَن لَّن يَحُورَ  بَلَىٰٓ إِنَّ رَبَّهُۥ كَانَ بِهِۦ بَصِيرًۭا  فَلَآ أُقْسِمُ بِٱلشَّفَقِ  وَٱلَّيْلِ وَمَا وَسَقَ  وَٱلْقَمَرِ إِذَا ٱتَّسَقَ  لَتَرْكَبُنَّ طَبَقًا عَن طَبَقٍۢ  فَمَا لَهُمْ لَا يُؤْمِنُونَ  وَإِذَا قُرِئَ عَلَيْهِمُ ٱلْقُرْءَانُ لَا يَسْجُدُونَ ۩  بَلِ ٱلَّذِينَ كَفَرُوا۟ يُكَذِّبُونَ  وَٱللَّهُ أَعْلَمُ بِمَا يُوعُونَ  فَبَشِّرْهُم بِعَذَابٍ أَلِيمٍ  إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّٰلِحَٰتِ لَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۭ',
    'When the sky has split [open] And has responded to its Lord and was obligated [to do so] And when the earth has been extended And has cast out that within it and relinquished [it] And has responded to its Lord and was obligated [to do so] - O mankind, indeed you are laboring toward your Lord with [great] exertion and will meet it. Then as for he who is given his record in his right hand, He will be judged with an easy account And return to his people in happiness. But as for he who is given his record behind his back, He will cry out for destruction And [enter to] burn in a Blaze. Indeed, he had [once] been among his people in happiness; Indeed, he had thought he would never return [to Allah]. But yes! Indeed, his Lord was ever of him, Seeing. So I swear by the twilight glow And [by] the night and what it envelops And [by] the moon when it becomes full [That] you will surely experience state after state. So what is [the matter] with them [that] they do not believe, And when the Qur''an is recited to them, they do not prostrate [to Allah]? But those who have disbelieved deny, And Allah is most knowing of what they keep within themselves. So give them tidings of a painful punishment, Except for those who believe and do righteous deeds. For them is a reward uninterrupted.',
    'جب آسمان پھٹ جائے گا اور اپنے پروردگار کا فرمان بجا لائے گا اور اسے واجب بھی یہ ہی ہے اور جب زمین ہموار کر دی جائے گی جو کچھ اس میں ہے اسے نکال کر باہر ڈال دے گی اور (بالکل) خالی ہو جائے گی اور اپنے پروردگار کے ارشاد کی تعمیل کرے گی اور اس کو لازم بھی یہی ہے (تو قیامت قائم ہو جائے گی) اے انسان! تو اپنے پروردگار کی طرف (پہنچنے میں) خوب کوشِش کرتا ہے سو اس سے جا ملے گا تو جس کا نامہٴ (اعمال) اس کے داہنے ہاتھ میں دیا جائے گا اس سے حساب آسان لیا جائے گا اور وہ اپنے گھر والوں میں خوش خوش آئے گا اور جس کا نامہٴ (اعمال) اس کی پیٹھ کے پیچھے سے دیا جائے گا وہ موت کو پکارے گا اور وہ دوزخ میں داخل ہو گا یہ اپنے اہل (و عیال) میں مست رہتا تھا اور خیال کرتا تھا کہ (خدا کی طرف) پھر کر نہ جائے گا ہاں ہاں۔ اس کا پروردگار اس کو دیکھ رہا تھا ہمیں شام کی سرخی کی قسم اور رات کی اور جن چیزوں کو وہ اکٹھا کر لیتی ہے ان کی اور چاند کی جب کامل ہو جائے کہ تم درجہ بدرجہ (رتبہٴ اعلیٰ پر) چڑھو گے تو ان لوگوں کو کیا ہوا ہے کہ ایمان نہیں لاتے اور جب ان کے سامنے قرآن پڑھا جاتا ہے تو سجدہ نہیں کرتے بلکہ کافر جھٹلاتے ہیں اور خدا ان باتوں کو جو یہ اپنے دلوں میں چھپاتے ہیں خوب جانتا ہے تو ان کو دکھ دینے والے عذاب کی خبر سنا دو ہاں جو لوگ ایمان لائے اور نیک عمل کرتے رہے ان کے لیے بےانتہا اجر ہے',
    '{"surah": 84, "name": "Al-Inshiqaq", "topic": "Accountability"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 85:1-22',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلسَّمَآءِ ذَاتِ ٱلْبُرُوجِ  وَٱلْيَوْمِ ٱلْمَوْعُودِ  وَشَاهِدٍۢ وَمَشْهُودٍۢ  قُتِلَ أَصْحَٰبُ ٱلْأُخْدُودِ  ٱلنَّارِ ذَاتِ ٱلْوَقُودِ  إِذْ هُمْ عَلَيْهَا قُعُودٌۭ  وَهُمْ عَلَىٰ مَا يَفْعَلُونَ بِٱلْمُؤْمِنِينَ شُهُودٌۭ  وَمَا نَقَمُوا۟ مِنْهُمْ إِلَّآ أَن يُؤْمِنُوا۟ بِٱللَّهِ ٱلْعَزِيزِ ٱلْحَمِيدِ  ٱلَّذِى لَهُۥ مُلْكُ ٱلسَّمَٰوَٰتِ وَٱلْأَرْضِ ۚ وَٱللَّهُ عَلَىٰ كُلِّ شَىْءٍۢ شَهِيدٌ  إِنَّ ٱلَّذِينَ فَتَنُوا۟ ٱلْمُؤْمِنِينَ وَٱلْمُؤْمِنَٰتِ ثُمَّ لَمْ يَتُوبُوا۟ فَلَهُمْ عَذَابُ جَهَنَّمَ وَلَهُمْ عَذَابُ ٱلْحَرِيقِ  إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّٰلِحَٰتِ لَهُمْ جَنَّٰتٌۭ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَٰرُ ۚ ذَٰلِكَ ٱلْفَوْزُ ٱلْكَبِيرُ  إِنَّ بَطْشَ رَبِّكَ لَشَدِيدٌ  إِنَّهُۥ هُوَ يُبْدِئُ وَيُعِيدُ  وَهُوَ ٱلْغَفُورُ ٱلْوَدُودُ  ذُو ٱلْعَرْشِ ٱلْمَجِيدُ  فَعَّالٌۭ لِّمَا يُرِيدُ  هَلْ أَتَىٰكَ حَدِيثُ ٱلْجُنُودِ  فِرْعَوْنَ وَثَمُودَ  بَلِ ٱلَّذِينَ كَفَرُوا۟ فِى تَكْذِيبٍۢ  وَٱللَّهُ مِن وَرَآئِهِم مُّحِيطٌۢ  بَلْ هُوَ قُرْءَانٌۭ مَّجِيدٌۭ  فِى لَوْحٍۢ مَّحْفُوظٍۭ',
    'By the sky containing great stars And [by] the promised Day And [by] the witness and what is witnessed, Cursed were the companions of the trench [Containing] the fire full of fuel, When they were sitting near it And they, to what they were doing against the believers, were witnesses. And they resented them not except because they believed in Allah, the Exalted in Might, the Praiseworthy, To whom belongs the dominion of the heavens and the earth. And Allah, over all things, is Witness. Indeed, those who have tortured the believing men and believing women and then have not repented will have the punishment of Hell, and they will have the punishment of the Burning Fire. Indeed, those who have believed and done righteous deeds will have gardens beneath which rivers flow. That is the great attainment. Indeed, the vengeance of your Lord is severe. Indeed, it is He who originates [creation] and repeats. And He is the Forgiving, the Affectionate, Honorable Owner of the Throne, Effecter of what He intends. Has there reached you the story of the soldiers - [Those of] Pharaoh and Thamud? But they who disbelieve are in [persistent] denial, While Allah encompasses them from behind. But this is an honored Qur''an [Inscribed] in a Preserved Slate.',
    'آسمان کی قسم جس میں برج ہیں اور اس دن کی جس کا وعدہ ہے اور حاضر ہونے والے کی اور جو اس کے پاس حاضر کیا جائے اسکی کہ خندقوں (کے کھودنے) والے ہلاک کر دیئے گئے (یعنی) آگ (کی خندقیں) جس میں ایندھن (جھونک رکھا) تھا جب کہ وہ ان (کے کناروں) پر بیٹھے ہوئے تھے اور جو (سختیاں) اہل ایمان پر کر رہے تھے ان کو سامنے دیکھ رہے تھے ان کو مومنوں کی یہی بات بری لگتی تھی کہ وہ خدا پر ایمان لائے ہوئے تھے جو غالب (اور) قابل ستائش ہے وہی جس کی آسمانوں اور زمین میں بادشاہت ہے۔ اور خدا ہر چیز سے واقف ہے جن لوگوں نے مومن مردوں اور مومن عورتوں کو تکلیفیں دیں اور توبہ نہ کی ان کو دوزخ کا (اور) عذاب بھی ہوگا اور جلنے کا عذاب بھی ہوگا (اور) جو لوگ ایمان لائے اور نیک کام کرتے رہے ان کے لیے باغات ہیں جن کے نیچے نہریں بہہ رہی ہیں۔ یہ ہی بڑی کامیابی ہے بےشک تمہارے پروردگار کی پکڑ بڑی سخت ہے وہی پہلی دفعہ پیدا کرتا ہے اور وہی دوبارہ (زندہ) کرے گا اور وہ بخشنے والا اور محبت کرنے والا ہے عرش کا مالک بڑی شان والا جو چاہتا ہے کر دیتا ہے بھلا تم کو لشکروں کا حال معلوم ہوا ہے (یعنی) فرعون اور ثمود کا لیکن کافر (جان بوجھ کر) تکذیب میں (گرفتار) ہیں اور خدا (بھی) ان کو گردا گرد سے گھیرے ہوئے ہے (یہ کتاب ہزل و بطلان نہیں) بلکہ یہ قرآن عظیم الشان ہے لوح محفوظ میں (لکھا ہوا)',
    '{"surah": 85, "name": "Al-Buruj", "topic": "Steadfastness under persecution"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 86:1-17',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلسَّمَآءِ وَٱلطَّارِقِ  وَمَآ أَدْرَىٰكَ مَا ٱلطَّارِقُ  ٱلنَّجْمُ ٱلثَّاقِبُ  إِن كُلُّ نَفْسٍۢ لَّمَّا عَلَيْهَا حَافِظٌۭ  فَلْيَنظُرِ ٱلْإِنسَٰنُ مِمَّ خُلِقَ  خُلِقَ مِن مَّآءٍۢ دَافِقٍۢ  يَخْرُجُ مِنۢ بَيْنِ ٱلصُّلْبِ وَٱلتَّرَآئِبِ  إِنَّهُۥ عَلَىٰ رَجْعِهِۦ لَقَادِرٌۭ  يَوْمَ تُبْلَى ٱلسَّرَآئِرُ  فَمَا لَهُۥ مِن قُوَّةٍۢ وَلَا نَاصِرٍۢ  وَٱلسَّمَآءِ ذَاتِ ٱلرَّجْعِ  وَٱلْأَرْضِ ذَاتِ ٱلصَّدْعِ  إِنَّهُۥ لَقَوْلٌۭ فَصْلٌۭ  وَمَا هُوَ بِٱلْهَزْلِ  إِنَّهُمْ يَكِيدُونَ كَيْدًۭا  وَأَكِيدُ كَيْدًۭا  فَمَهِّلِ ٱلْكَٰفِرِينَ أَمْهِلْهُمْ رُوَيْدًۢا',
    'By the sky and the night comer - And what can make you know what is the night comer? It is the piercing star - There is no soul but that it has over it a protector. So let man observe from what he was created. He was created from a fluid, ejected, Emerging from between the backbone and the ribs. Indeed, Allah, to return him [to life], is Able. The Day when secrets will be put on trial, Then man will have no power or any helper. By the sky which returns [rain] And [by] the earth which cracks open, Indeed, the Qur''an is a decisive statement, And it is not amusement. Indeed, they are planning a plan, But I am planning a plan. So allow time for the disbelievers. Leave them awhile.',
    'آسمان اور رات کے وقت آنے والے کی قسم اور تم کو کیا معلوم کہ رات کے وقت آنے والا کیا ہے وہ تارا ہے چمکنے والا کہ کوئی متنفس نہیں جس پر نگہبان مقرر نہیں تو انسان کو دیکھنا چاہئے کہ وہ کاہے سے پیدا ہوا ہے وہ اچھلتے ہوئے پانی سے پیدا ہوا ہے جو پیٹھ اور سینے کے بیچ میں سے نکلتا ہے بےشک خدا اس کے اعادے (یعنی پھر پیدا کرنے) پر قادر ہے جس دن دلوں کے بھید جانچے جائیں گے تو انسان کی کچھ پیش نہ چل سکے گی اور نہ کوئی اس کا مددگار ہو گا آسمان کی قسم جو مینہ برساتا ہے اور زمین کی قسم جو پھٹ جاتی ہے کہ یہ کلام (حق کو باطل سے) جدا کرنے والا ہے اور بیہودہ بات نہیں ہے یہ لوگ تو اپنی تدبیروں میں لگ رہے ہیں اور ہم اپنی تدبیر کر رہے ہیں تو تم کافروں کو مہلت دو بس چند روز ہی مہلت دو',
    '{"surah": 86, "name": "At-Tariq", "topic": "The Night Star"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 87:1-19',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ سَبِّحِ ٱسْمَ رَبِّكَ ٱلْأَعْلَى  ٱلَّذِى خَلَقَ فَسَوَّىٰ  وَٱلَّذِى قَدَّرَ فَهَدَىٰ  وَٱلَّذِىٓ أَخْرَجَ ٱلْمَرْعَىٰ  فَجَعَلَهُۥ غُثَآءً أَحْوَىٰ  سَنُقْرِئُكَ فَلَا تَنسَىٰٓ  إِلَّا مَا شَآءَ ٱللَّهُ ۚ إِنَّهُۥ يَعْلَمُ ٱلْجَهْرَ وَمَا يَخْفَىٰ  وَنُيَسِّرُكَ لِلْيُسْرَىٰ  فَذَكِّرْ إِن نَّفَعَتِ ٱلذِّكْرَىٰ  سَيَذَّكَّرُ مَن يَخْشَىٰ  وَيَتَجَنَّبُهَا ٱلْأَشْقَى  ٱلَّذِى يَصْلَى ٱلنَّارَ ٱلْكُبْرَىٰ  ثُمَّ لَا يَمُوتُ فِيهَا وَلَا يَحْيَىٰ  قَدْ أَفْلَحَ مَن تَزَكَّىٰ  وَذَكَرَ ٱسْمَ رَبِّهِۦ فَصَلَّىٰ  بَلْ تُؤْثِرُونَ ٱلْحَيَوٰةَ ٱلدُّنْيَا  وَٱلْءَاخِرَةُ خَيْرٌۭ وَأَبْقَىٰٓ  إِنَّ هَٰذَا لَفِى ٱلصُّحُفِ ٱلْأُولَىٰ  صُحُفِ إِبْرَٰهِيمَ وَمُوسَىٰ',
    'Exalt the name of your Lord, the Most High, Who created and proportioned And who destined and [then] guided And who brings out the pasture And [then] makes it black stubble. We will make you recite, [O Muhammad], and you will not forget, Except what Allah should will. Indeed, He knows what is declared and what is hidden. And We will ease you toward ease. So remind, if the reminder should benefit; He who fears [Allah] will be reminded. But the wretched one will avoid it - [He] who will [enter and] burn in the greatest Fire, Neither dying therein nor living. He has certainly succeeded who purifies himself And mentions the name of his Lord and prays. But you prefer the worldly life, While the Hereafter is better and more enduring. Indeed, this is in the former scriptures, The scriptures of Abraham and Moses.',
    '(اے پیغمبر) اپنے پروردگار جلیل الشان کے نام کی تسبیح کرو جس نے (انسان کو) بنایا پھر (اس کے اعضاء کو) درست کیا اور جس نے (اس کا) اندازہ ٹہرایا (پھر اس کو) رستہ بتایا اور جس نے چارہ اگایا پھر اس کو سیاہ رنگ کا کوڑا کر دیا ہم تمہیں پڑھا دیں گے کہ تم فراموش نہ کرو گے مگر جو خدا چاہے۔ وہ کھلی بات کو بھی جانتا ہے اور چھپی کو بھی ہم تم کو آسان طریقے کی توفیق دیں گے سو جہاں تک نصیحت (کے) نافع (ہونے کی امید) ہو نصیحت کرتے رہو جو خوف رکھتا ہے وہ تو نصیحت پکڑے گا اور (بےخوف) بدبخت پہلو تہی کرے گا جو (قیامت کو) بڑی (تیز) آگ میں داخل ہو گا پھر وہاں نہ مرے گا اور نہ جئے گا بے شک وہ مراد کو پہنچ گیا جو پاک ہوا اور اپنے پروردگار کے نام کا ذکر کرتا رہا اور نماز پڑھتا رہا مگر تم لوگ تو دنیا کی زندگی کو اختیار کرتے ہو حالانکہ آخرت بہت بہتر اور پائندہ تر ہے یہ بات پہلے صحیفوں میں (مرقوم) ہے (یعنی) ابراہیم اور موسیٰ کے صحیفوں میں',
    '{"surah": 87, "name": "Al-A''la", "topic": "Glorification of Allah"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 88:1-26',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ هَلْ أَتَىٰكَ حَدِيثُ ٱلْغَٰشِيَةِ  وُجُوهٌۭ يَوْمَئِذٍ خَٰشِعَةٌ  عَامِلَةٌۭ نَّاصِبَةٌۭ  تَصْلَىٰ نَارًا حَامِيَةًۭ  تُسْقَىٰ مِنْ عَيْنٍ ءَانِيَةٍۢ  لَّيْسَ لَهُمْ طَعَامٌ إِلَّا مِن ضَرِيعٍۢ  لَّا يُسْمِنُ وَلَا يُغْنِى مِن جُوعٍۢ  وُجُوهٌۭ يَوْمَئِذٍۢ نَّاعِمَةٌۭ  لِّسَعْيِهَا رَاضِيَةٌۭ  فِى جَنَّةٍ عَالِيَةٍۢ  لَّا تَسْمَعُ فِيهَا لَٰغِيَةًۭ  فِيهَا عَيْنٌۭ جَارِيَةٌۭ  فِيهَا سُرُرٌۭ مَّرْفُوعَةٌۭ  وَأَكْوَابٌۭ مَّوْضُوعَةٌۭ  وَنَمَارِقُ مَصْفُوفَةٌۭ  وَزَرَابِىُّ مَبْثُوثَةٌ  أَفَلَا يَنظُرُونَ إِلَى ٱلْإِبِلِ كَيْفَ خُلِقَتْ  وَإِلَى ٱلسَّمَآءِ كَيْفَ رُفِعَتْ  وَإِلَى ٱلْجِبَالِ كَيْفَ نُصِبَتْ  وَإِلَى ٱلْأَرْضِ كَيْفَ سُطِحَتْ  فَذَكِّرْ إِنَّمَآ أَنتَ مُذَكِّرٌۭ  لَّسْتَ عَلَيْهِم بِمُصَيْطِرٍ  إِلَّا مَن تَوَلَّىٰ وَكَفَرَ  فَيُعَذِّبُهُ ٱللَّهُ ٱلْعَذَابَ ٱلْأَكْبَرَ  إِنَّ إِلَيْنَآ إِيَابَهُمْ  ثُمَّ إِنَّ عَلَيْنَا حِسَابَهُم',
    'Has there reached you the report of the Overwhelming [event]? [Some] faces, that Day, will be humbled, Working [hard] and exhausted. They will [enter to] burn in an intensely hot Fire. They will be given drink from a boiling spring. For them there will be no food except from a poisonous, thorny plant Which neither nourishes nor avails against hunger. [Other] faces, that Day, will show pleasure. With their effort [they are] satisfied In an elevated garden, Wherein they will hear no unsuitable speech. Within it is a flowing spring. Within it are couches raised high And cups put in place And cushions lined up And carpets spread around. Then do they not look at the camels - how they are created? And at the sky - how it is raised? And at the mountains - how they are erected? And at the earth - how it is spread out? So remind, [O Muhammad]; you are only a reminder. You are not over them a controller. However, he who turns away and disbelieves - Then Allah will punish him with the greatest punishment. Indeed, to Us is their return. Then indeed, upon Us is their account.',
    'بھلا تم کو ڈھانپ لینے والی (یعنی قیامت کا) حال معلوم ہوا ہے اس روز بہت سے منہ (والے) ذلیل ہوں گے سخت محنت کرنے والے تھکے ماندے دہکتی آگ میں داخل ہوں گے ایک کھولتے ہوئے چشمے کا ان کو پانی پلایا جائے گا اور خار دار جھاڑ کے سوا ان کے لیے کوئی کھانا نہیں (ہو گا) جو نہ فربہی لائے اور نہ بھوک میں کچھ کام آئے اور بہت سے منہ (والے) اس روز شادماں ہوں گے اپنے اعمال (کی جزا) سے خوش دل بہشت بریں میں وہاں کسی طرح کی بکواس نہیں سنیں گے اس میں چشمے بہ رہے ہوں گے وہاں تخت ہوں گے اونچے بچھے ہوئے اور آبخورے (قرینے سے) رکھے ہوئے اور گاؤ تکیے قطار کی قطار لگے ہوئے اور نفیس مسندیں بچھی ہوئی یہ لوگ اونٹوں کی طرف نہیں دیکھتے کہ کیسے (عجیب) پیدا کیے گئے ہیں اور آسمان کی طرف کہ کیسا بلند کیا گیا ہے اور پہاڑوں کی طرف کہ کس طرح کھڑے کیے گئے ہیں اور زمین کی طرف کہ کس طرح بچھائی گئی تو تم نصیحت کرتے رہو کہ تم نصیحت کرنے والے ہی ہو تم ان پر داروغہ نہیں ہو ہاں جس نے منہ پھیرا اور نہ مانا تو خدا اس کو بڑا عذاب دے گا بےشک ان کو ہمارے پاس لوٹ کر آنا ہے پھر ہم ہی کو ان سے حساب لینا ہے',
    '{"surah": 88, "name": "Al-Ghashiyah", "topic": "The Overwhelming Day"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 89:1-30',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلْفَجْرِ  وَلَيَالٍ عَشْرٍۢ  وَٱلشَّفْعِ وَٱلْوَتْرِ  وَٱلَّيْلِ إِذَا يَسْرِ  هَلْ فِى ذَٰلِكَ قَسَمٌۭ لِّذِى حِجْرٍ  أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِعَادٍ  إِرَمَ ذَاتِ ٱلْعِمَادِ  ٱلَّتِى لَمْ يُخْلَقْ مِثْلُهَا فِى ٱلْبِلَٰدِ  وَثَمُودَ ٱلَّذِينَ جَابُوا۟ ٱلصَّخْرَ بِٱلْوَادِ  وَفِرْعَوْنَ ذِى ٱلْأَوْتَادِ  ٱلَّذِينَ طَغَوْا۟ فِى ٱلْبِلَٰدِ  فَأَكْثَرُوا۟ فِيهَا ٱلْفَسَادَ  فَصَبَّ عَلَيْهِمْ رَبُّكَ سَوْطَ عَذَابٍ  إِنَّ رَبَّكَ لَبِٱلْمِرْصَادِ  فَأَمَّا ٱلْإِنسَٰنُ إِذَا مَا ٱبْتَلَىٰهُ رَبُّهُۥ فَأَكْرَمَهُۥ وَنَعَّمَهُۥ فَيَقُولُ رَبِّىٓ أَكْرَمَنِ  وَأَمَّآ إِذَا مَا ٱبْتَلَىٰهُ فَقَدَرَ عَلَيْهِ رِزْقَهُۥ فَيَقُولُ رَبِّىٓ أَهَٰنَنِ  كَلَّا ۖ بَل لَّا تُكْرِمُونَ ٱلْيَتِيمَ  وَلَا تَحَٰٓضُّونَ عَلَىٰ طَعَامِ ٱلْمِسْكِينِ  وَتَأْكُلُونَ ٱلتُّرَاثَ أَكْلًۭا لَّمًّۭا  وَتُحِبُّونَ ٱلْمَالَ حُبًّۭا جَمًّۭا  كَلَّآ إِذَا دُكَّتِ ٱلْأَرْضُ دَكًّۭا دَكًّۭا  وَجَآءَ رَبُّكَ وَٱلْمَلَكُ صَفًّۭا صَفًّۭا  وَجِا۟ىٓءَ يَوْمَئِذٍۭ بِجَهَنَّمَ ۚ يَوْمَئِذٍۢ يَتَذَكَّرُ ٱلْإِنسَٰنُ وَأَنَّىٰ لَهُ ٱلذِّكْرَىٰ  يَقُولُ يَٰلَيْتَنِى قَدَّمْتُ لِحَيَاتِى  فَيَوْمَئِذٍۢ لَّا يُعَذِّبُ عَذَابَهُۥٓ أَحَدٌۭ  وَلَا يُوثِقُ وَثَاقَهُۥٓ أَحَدٌۭ  يَٰٓأَيَّتُهَا ٱلنَّفْسُ ٱلْمُطْمَئِنَّةُ  ٱرْجِعِىٓ إِلَىٰ رَبِّكِ رَاضِيَةًۭ مَّرْضِيَّةًۭ  فَٱدْخُلِى فِى عِبَٰدِى  وَٱدْخُلِى جَنَّتِى',
    'By the dawn And [by] ten nights And [by] the even [number] and the odd And [by] the night when it passes, Is there [not] in [all] that an oath [sufficient] for one of perception? Have you not considered how your Lord dealt with ''Aad - [With] Iram - who had lofty pillars, The likes of whom had never been created in the land? And [with] Thamud, who carved out the rocks in the valley? And [with] Pharaoh, owner of the stakes? - [All of] whom oppressed within the lands And increased therein the corruption. So your Lord poured upon them a scourge of punishment. Indeed, your Lord is in observation. And as for man, when his Lord tries him and [thus] is generous to him and favors him, he says, "My Lord has honored me." But when He tries him and restricts his provision, he says, "My Lord has humiliated me." No! But you do not honor the orphan And you do not encourage one another to feed the poor. And you consume inheritance, devouring [it] altogether, And you love wealth with immense love. No! When the earth has been leveled - pounded and crushed - And your Lord has come and the angels, rank upon rank, And brought [within view], that Day, is Hell - that Day, man will remember, but what good to him will be the remembrance? He will say, "Oh, I wish I had sent ahead [some good] for my life." So on that Day, none will punish [as severely] as His punishment, And none will bind [as severely] as His binding [of the evildoers]. [To the righteous it will be said], "O reassured soul, Return to your Lord, well-pleased and pleasing [to Him], And enter among My [righteous] servants And enter My Paradise."',
    'فجر کی قسم اور دس راتوں کی اور جفت اور طاق کی اور رات کی جب جانے لگے اور بے شک یہ چیزیں عقلمندوں کے نزدیک قسم کھانے کے لائق ہیں کہ (کافروں کو ضرور عذاب ہو گا) کیا تم نے نہیں دیکھا کہ تمہارے پروردگار نے عاد کے ساتھ کیا کیا (جو) ارم (کہلاتے تھے اتنے) دراز قد کہ تمام ملک میں ایسے پیدا نہیں ہوئے تھے اور ثمود کے ساتھ (کیا کیا) جو وادئِ (قریٰ) میں پتھر تراشتے تھے (اور گھر بناتے) تھے اور فرعون کے ساتھ (کیا کیا) جو خیمے اور میخیں رکھتا تھا یہ لوگ ملکوں میں سرکش ہو رہے تھے اور ان میں بہت سی خرابیاں کرتے تھے تو تمہارے پروردگار نے ان پر عذاب کا کوڑا نازل کیا بے شک تمہارا پروردگار تاک میں ہے مگر انسان (عجیب مخلوق ہے کہ) جب اس کا پروردگار اس کو آزماتا ہے تو اسے عزت دیتا اور نعمت بخشتا ہے۔ تو کہتا ہے کہ (آہا) میرے پروردگار نے مجھے عزت بخشی اور جب (دوسری طرح) آزماتا ہے کہ اس پر روزی تنگ کر دیتا ہے تو کہتا ہے کہ (ہائے) میرے پروردگار نے مجھے ذلیل کیا نہیں بلکہ تم لوگ یتیم کی خاطر نہیں کرتے اور نہ مسکین کو کھانا کھلانے کی ترغیب دیتے ہو اور میراث کے مال سمیٹ کر کھا جاتے ہو اور مال کو بہت ہی عزیز رکھتے ہو تو جب زمین کی بلندی کوٹ کوٹ کو پست کر دی جائے گی اور تمہارا پروردگار (جلوہ فرما ہو گا) اور فرشتے قطار باندھ باندھ کر آ موجود ہوں گے اور دوزخ اس دن حاضر کی جائے گی تو انسان اس دن متنبہ ہو گا مگر تنبہ (سے) اسے (فائدہ) کہاں (مل سکے گا) کہے گا کاش میں نے اپنی زندگی (جاودانی کے لیے) کچھ آگے بھیجا ہوتا تو اس دن نہ کوئی خدا کے عذاب کی طرح کا (کسی کو) عذاب دے گا اور نہ کوئی ویسا جکڑنا جکڑے گا اے اطمینان پانے والی روح! اپنے پروردگار کی طرف لوٹ چل۔ تو اس سے راضی وہ تجھ سے راضی تو میرے (ممتاز) بندوں میں شامل ہو جا اور میری بہشت میں داخل ہو جا',
    '{"surah": 89, "name": "Al-Fajr", "topic": "Lessons from past nations"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 90:1-20',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ لَآ أُقْسِمُ بِهَٰذَا ٱلْبَلَدِ  وَأَنتَ حِلٌّۢ بِهَٰذَا ٱلْبَلَدِ  وَوَالِدٍۢ وَمَا وَلَدَ  لَقَدْ خَلَقْنَا ٱلْإِنسَٰنَ فِى كَبَدٍ  أَيَحْسَبُ أَن لَّن يَقْدِرَ عَلَيْهِ أَحَدٌۭ  يَقُولُ أَهْلَكْتُ مَالًۭا لُّبَدًا  أَيَحْسَبُ أَن لَّمْ يَرَهُۥٓ أَحَدٌ  أَلَمْ نَجْعَل لَّهُۥ عَيْنَيْنِ  وَلِسَانًۭا وَشَفَتَيْنِ  وَهَدَيْنَٰهُ ٱلنَّجْدَيْنِ  فَلَا ٱقْتَحَمَ ٱلْعَقَبَةَ  وَمَآ أَدْرَىٰكَ مَا ٱلْعَقَبَةُ  فَكُّ رَقَبَةٍ  أَوْ إِطْعَٰمٌۭ فِى يَوْمٍۢ ذِى مَسْغَبَةٍۢ  يَتِيمًۭا ذَا مَقْرَبَةٍ  أَوْ مِسْكِينًۭا ذَا مَتْرَبَةٍۢ  ثُمَّ كَانَ مِنَ ٱلَّذِينَ ءَامَنُوا۟ وَتَوَاصَوْا۟ بِٱلصَّبْرِ وَتَوَاصَوْا۟ بِٱلْمَرْحَمَةِ  أُو۟لَٰٓئِكَ أَصْحَٰبُ ٱلْمَيْمَنَةِ  وَٱلَّذِينَ كَفَرُوا۟ بِـَٔايَٰتِنَا هُمْ أَصْحَٰبُ ٱلْمَشْـَٔمَةِ  عَلَيْهِمْ نَارٌۭ مُّؤْصَدَةٌۢ',
    'I swear by this city, Makkah - And you, [O Muhammad], are free of restriction in this city - And [by] the father and that which was born [of him], We have certainly created man into hardship. Does he think that never will anyone overcome him? He says, "I have spent wealth in abundance." Does he think that no one has seen him? Have We not made for him two eyes? And a tongue and two lips? And have shown him the two ways? But he has not broken through the difficult pass. And what can make you know what is [breaking through] the difficult pass? It is the freeing of a slave Or feeding on a day of severe hunger An orphan of near relationship Or a needy person in misery And then being among those who believed and advised one another to patience and advised one another to compassion. Those are the companions of the right. But they who disbelieved in Our signs - those are the companions of the left. Over them will be fire closed in.',
    'ہمیں اس شہر (مکہ) کی قسم اور تم اسی شہر میں تو رہتے ہو اور باپ (یعنی آدم) اور اس کی اولاد کی قسم کہ ہم نے انسان کو تکلیف (کی حالت) میں (رہنے والا) بنایا ہے کیا وہ خیال رکھتا ہے کہ اس پر کوئی قابو نہ پائے گا کہتا ہے کہ میں نے بہت سا مال برباد کیا کیا اسے یہ گمان ہے کہ اس کو کسی نے دیکھا نہیں بھلا ہم نےاس کو دو آنکھیں نہیں دیں؟ اور زبان اور دو ہونٹ (نہیں دیئے) (یہ چیزیں بھی دیں) اور اس کو (خیر و شر کے) دونوں رستے بھی دکھا دیئے مگر وہ گھاٹی پر سے ہو کر نہ گزرا اور تم کیا سمجھے کہ گھاٹی کیا ہے؟ کسی (کی) گردن کا چھڑانا یا بھوک کے دن کھانا کھلانا یتیم رشتہ دار کو یا فقیر خاکسار کو پھر ان لوگوں میں بھی (داخل) ہو جو ایمان لائے اور صبر کی نصیحت اور (لوگوں پر) شفقت کرنے کی وصیت کرتے رہے یہی لوگ صاحب سعادت ہیں اور جنہوں نے ہماری آیتوں کو نہ مانا وہ بدبخت ہیں یہ لوگ آگ میں بند کر دیئے جائیں گے',
    '{"surah": 90, "name": "Al-Balad", "topic": "The steep path"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 91:1-15',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلشَّمْسِ وَضُحَىٰهَا  وَٱلْقَمَرِ إِذَا تَلَىٰهَا  وَٱلنَّهَارِ إِذَا جَلَّىٰهَا  وَٱلَّيْلِ إِذَا يَغْشَىٰهَا  وَٱلسَّمَآءِ وَمَا بَنَىٰهَا  وَٱلْأَرْضِ وَمَا طَحَىٰهَا  وَنَفْسٍۢ وَمَا سَوَّىٰهَا  فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَىٰهَا  قَدْ أَفْلَحَ مَن زَكَّىٰهَا  وَقَدْ خَابَ مَن دَسَّىٰهَا  كَذَّبَتْ ثَمُودُ بِطَغْوَىٰهَآ  إِذِ ٱنۢبَعَثَ أَشْقَىٰهَا  فَقَالَ لَهُمْ رَسُولُ ٱللَّهِ نَاقَةَ ٱللَّهِ وَسُقْيَٰهَا  فَكَذَّبُوهُ فَعَقَرُوهَا فَدَمْدَمَ عَلَيْهِمْ رَبُّهُم بِذَنۢبِهِمْ فَسَوَّىٰهَا  وَلَا يَخَافُ عُقْبَٰهَا',
    'By the sun and its brightness And [by] the moon when it follows it And [by] the day when it displays it And [by] the night when it covers it And [by] the sky and He who constructed it And [by] the earth and He who spread it And [by] the soul and He who proportioned it And inspired it [with discernment of] its wickedness and its righteousness, He has succeeded who purifies it, And he has failed who instills it [with corruption]. Thamud denied [their prophet] by reason of their transgression, When the most wretched of them was sent forth. And the messenger of Allah [Salih] said to them, "[Do not harm] the she-camel of Allah or [prevent her from] her drink." But they denied him and hamstrung her. So their Lord brought down upon them destruction for their sin and made it equal [upon all of them]. And He does not fear the consequence thereof.',
    'سورج کی قسم اور اس کی روشنی کی اور چاند کی جب اس کے پیچھے نکلے اور دن کی جب اُسے چمکا دے اور رات کی جب اُسے چھپا لے اور آسمان کی اور اس ذات کی جس نے اسے بنایا اور زمین کی اور اس کی جس نے اسے پھیلایا اور انسان کی اور اس کی جس نے اس (کے اعضا) کو برابر کیا پھر اس کو بدکاری (سے بچنے) اور پرہیزگاری کرنے کی سمجھ دی کہ جس نے (اپنے) نفس (یعنی روح) کو پاک رکھا وہ مراد کو پہنچا اور جس نے اسے خاک میں ملایا وہ خسارے میں رہا (قوم) ثمود نے اپنی سرکشی کے سبب (پیغمبر کو) جھٹلایا جب ان میں سے ایک نہایت بدبخت اٹھا تو خدا کے پیغمبر (صالح) نے ان سے کہا کہ خدا کی اونٹنی اور اس کے پانی پینے کی باری سے عذر کرو مگر انہوں نے پیغمبر کو جھٹلایا اور اونٹنی کی کونچیں کاٹ دیں تو خدا نے ان کےگناہ کے سبب ان پر عذاب نازل کیا اور سب کو (ہلاک کر کے) برابر کر دیا اور اس کو ان کے بدلہ لینے کا کچھ بھی ڈر نہیں',
    '{"surah": 91, "name": "Ash-Shams", "topic": "Purification of the soul"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 92:1-21',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلَّيْلِ إِذَا يَغْشَىٰ  وَٱلنَّهَارِ إِذَا تَجَلَّىٰ  وَمَا خَلَقَ ٱلذَّكَرَ وَٱلْأُنثَىٰٓ  إِنَّ سَعْيَكُمْ لَشَتَّىٰ  فَأَمَّا مَنْ أَعْطَىٰ وَٱتَّقَىٰ  وَصَدَّقَ بِٱلْحُسْنَىٰ  فَسَنُيَسِّرُهُۥ لِلْيُسْرَىٰ  وَأَمَّا مَنۢ بَخِلَ وَٱسْتَغْنَىٰ  وَكَذَّبَ بِٱلْحُسْنَىٰ  فَسَنُيَسِّرُهُۥ لِلْعُسْرَىٰ  وَمَا يُغْنِى عَنْهُ مَالُهُۥٓ إِذَا تَرَدَّىٰٓ  إِنَّ عَلَيْنَا لَلْهُدَىٰ  وَإِنَّ لَنَا لَلْءَاخِرَةَ وَٱلْأُولَىٰ  فَأَنذَرْتُكُمْ نَارًۭا تَلَظَّىٰ  لَا يَصْلَىٰهَآ إِلَّا ٱلْأَشْقَى  ٱلَّذِى كَذَّبَ وَتَوَلَّىٰ  وَسَيُجَنَّبُهَا ٱلْأَتْقَى  ٱلَّذِى يُؤْتِى مَالَهُۥ يَتَزَكَّىٰ  وَمَا لِأَحَدٍ عِندَهُۥ مِن نِّعْمَةٍۢ تُجْزَىٰٓ  إِلَّا ٱبْتِغَآءَ وَجْهِ رَبِّهِ ٱلْأَعْلَىٰ  وَلَسَوْفَ يَرْضَىٰ',
    'By the night when it covers And [by] the day when it appears And [by] He who created the male and female, Indeed, your efforts are diverse. As for he who gives and fears Allah And believes in the best [reward], We will ease him toward ease. But as for he who withholds and considers himself free of need And denies the best [reward], We will ease him toward difficulty. And what will his wealth avail him when he falls? Indeed, [incumbent] upon Us is guidance. And indeed, to Us belongs the Hereafter and the first [life]. So I have warned you of a Fire which is blazing. None will [enter to] burn therein except the most wretched one. Who had denied and turned away. But the righteous one will avoid it - [He] who gives [from] his wealth to purify himself And not [giving] for anyone who has [done him] a favor to be rewarded But only seeking the countenance of his Lord, Most High. And he is going to be satisfied.',
    'رات کی قسم جب (دن کو) چھپالے اور دن کی قسم جب چمک اٹھے اور اس (ذات) کی قسم جس نے نر اور مادہ پیدا کیے کہ تم لوگوں کی کوششں طرح طرح کی ہے تو جس نے (خدا کے رستے میں مال) دیا اور پرہیز گاری کی اور نیک بات کو سچ جانا اس کو ہم آسان طریقے کی توفیق دیں گے اور جس نے بخل کیا اور بےپروا بنا رہا اور نیک بات کو جھوٹ سمجھا اسے سختی میں پہنچائیں گے اور جب وہ (دوزخ کے گڑھے میں) گرے گا تو اس کا مال اس کے کچھ کام نہ آئے گا ہمیں تو راہ دکھا دینا ہے اور آخرت او ردنیا ہماری ہی چیزیں ہیں سو میں نے تم کو بھڑکتی آگ سے متنبہ کر دیا اس میں وہی داخل ہو گا جو بڑا بدبخت ہے جس نے جھٹلایا اور منہ پھیرا اور جو بڑا پرہیزگار ہے وہ (اس سے) بچا لیا جائے گا جو مال دیتا ہے تاکہ پاک ہو اور (اس لیے) نہیں (دیتا کہ) اس پر کسی کا احسان (ہے) جس کا وہ بدلہ اتارتا ہے بلکہ اپنے خداوند اعلیٰ کی رضامندی حاصل کرنے کے لیے دیتا ہے اور وہ عنقریب خوش ہو جائے گا',
    '{"surah": 92, "name": "Al-Layl", "topic": "Charity and piety"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 93:1-11',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلضُّحَىٰ  وَٱلَّيْلِ إِذَا سَجَىٰ  مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ  وَلَلْءَاخِرَةُ خَيْرٌۭ لَّكَ مِنَ ٱلْأُولَىٰ  وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰٓ  أَلَمْ يَجِدْكَ يَتِيمًۭا فَـَٔاوَىٰ  وَوَجَدَكَ ضَآلًّۭا فَهَدَىٰ  وَوَجَدَكَ عَآئِلًۭا فَأَغْنَىٰ  فَأَمَّا ٱلْيَتِيمَ فَلَا تَقْهَرْ  وَأَمَّا ٱلسَّآئِلَ فَلَا تَنْهَرْ  وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ',
    'By the morning brightness And [by] the night when it covers with darkness, Your Lord has not taken leave of you, [O Muhammad], nor has He detested [you]. And the Hereafter is better for you than the first [life]. And your Lord is going to give you, and you will be satisfied. Did He not find you an orphan and give [you] refuge? And He found you lost and guided [you], And He found you poor and made [you] self-sufficient. So as for the orphan, do not oppress [him]. And as for the petitioner, do not repel [him]. But as for the favor of your Lord, report [it].',
    'آفتاب کی روشنی کی قسم اور رات (کی تاریکی) کی جب چھا جائے کہ (اے محمدﷺ) تمہارے پروردگار نے نہ تو تم کو چھوڑا اور نہ (تم سے) ناراض ہوا اور آخرت تمہارے لیے پہلی (حالت یعنی دنیا) سے کہیں بہتر ہے اور تمہیں پروردگار عنقریب وہ کچھ عطا فرمائے گا کہ تم خوش ہو جاؤ گے بھلا اس نے تمہیں یتیم پا کر جگہ نہیں دی؟ (بےشک دی) اور رستے سے ناواقف دیکھا تو رستہ دکھایا اور تنگ دست پایا تو غنی کر دیا تو تم بھی یتیم پر ستم نہ کرنا اور مانگنے والے کو جھڑکی نہ دینا اور اپنے پروردگار کی نعمتوں کا بیان کرتے رہنا',
    '{"surah": 93, "name": "Ad-Duhaa", "topic": "Comfort to the Prophet"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 95:1-8',
    'بِّسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلتِّينِ وَٱلزَّيْتُونِ  وَطُورِ سِينِينَ  وَهَٰذَا ٱلْبَلَدِ ٱلْأَمِينِ  لَقَدْ خَلَقْنَا ٱلْإِنسَٰنَ فِىٓ أَحْسَنِ تَقْوِيمٍۢ  ثُمَّ رَدَدْنَٰهُ أَسْفَلَ سَٰفِلِينَ  إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّٰلِحَٰتِ فَلَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۢ  فَمَا يُكَذِّبُكَ بَعْدُ بِٱلدِّينِ  أَلَيْسَ ٱللَّهُ بِأَحْكَمِ ٱلْحَٰكِمِينَ',
    'By the fig and the olive And [by] Mount Sinai And [by] this secure city [Makkah], We have certainly created man in the best of stature; Then We return him to the lowest of the low, Except for those who believe and do righteous deeds, for they will have a reward uninterrupted. So what yet causes you to deny the Recompense? Is not Allah the most just of judges?',
    'انجیر کی قسم اور زیتون کی اور طور سینین کی اور اس امن والے شہر کی کہ ہم نے انسان کو بہت اچھی صورت میں پیدا کیا ہے پھر (رفتہ رفتہ) اس (کی حالت) کو (بدل کر) پست سے پست کر دیا مگر جو لوگ ایمان لائے اور نیک عمل کرتے رہے انکے لیے بےانتہا اجر ہے تو (اے آدم زاد) پھر تو جزا کے دن کو کیوں جھٹلاتا ہے؟ کیا خدا سب سے بڑا حاکم نہیں ہے؟',
    '{"surah": 95, "name": "At-Tin", "topic": "Human dignity"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 96:1-19',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ٱقْرَأْ بِٱسْمِ رَبِّكَ ٱلَّذِى خَلَقَ  خَلَقَ ٱلْإِنسَٰنَ مِنْ عَلَقٍ  ٱقْرَأْ وَرَبُّكَ ٱلْأَكْرَمُ  ٱلَّذِى عَلَّمَ بِٱلْقَلَمِ  عَلَّمَ ٱلْإِنسَٰنَ مَا لَمْ يَعْلَمْ  كَلَّآ إِنَّ ٱلْإِنسَٰنَ لَيَطْغَىٰٓ  أَن رَّءَاهُ ٱسْتَغْنَىٰٓ  إِنَّ إِلَىٰ رَبِّكَ ٱلرُّجْعَىٰٓ  أَرَءَيْتَ ٱلَّذِى يَنْهَىٰ  عَبْدًا إِذَا صَلَّىٰٓ  أَرَءَيْتَ إِن كَانَ عَلَى ٱلْهُدَىٰٓ  أَوْ أَمَرَ بِٱلتَّقْوَىٰٓ  أَرَءَيْتَ إِن كَذَّبَ وَتَوَلَّىٰٓ  أَلَمْ يَعْلَم بِأَنَّ ٱللَّهَ يَرَىٰ  كَلَّا لَئِن لَّمْ يَنتَهِ لَنَسْفَعًۢا بِٱلنَّاصِيَةِ  نَاصِيَةٍۢ كَٰذِبَةٍ خَاطِئَةٍۢ  فَلْيَدْعُ نَادِيَهُۥ  سَنَدْعُ ٱلزَّبَانِيَةَ  كَلَّا لَا تُطِعْهُ وَٱسْجُدْ وَٱقْتَرِب ۩',
    'Recite in the name of your Lord who created - Created man from a clinging substance. Recite, and your Lord is the most Generous - Who taught by the pen - Taught man that which he knew not. No! [But] indeed, man transgresses Because he sees himself self-sufficient. Indeed, to your Lord is the return. Have you seen the one who forbids A servant when he prays? Have you seen if he is upon guidance Or enjoins righteousness? Have you seen if he denies and turns away - Does he not know that Allah sees? No! If he does not desist, We will surely drag him by the forelock - A lying, sinning forelock. Then let him call his associates; We will call the angels of Hell. No! Do not obey him. But prostrate and draw near [to Allah].',
    '(اے محمدﷺ) اپنے پروردگار کا نام لے کر پڑھو جس نے (عالم کو) پیدا کیا جس نے انسان کو خون کی پھٹکی سے بنایا پڑھو اور تمہارا پروردگار بڑا کریم ہے جس نے قلم کے ذریعے سے علم سکھایا اور انسان کو وہ باتیں سکھائیں جس کا اس کو علم نہ تھا مگر انسان سرکش ہو جاتا ہے جب کہ اپنے تیئں غنی دیکھتا ہے کچھ شک نہیں کہ (اس کو) تمہارے پروردگار ہی کی طرف لوٹ کر جانا ہے بھلا تم نے اس شخص کو دیکھا جو منع کرتا ہے (یعنی) ایک بندے کو جب وہ نماز پڑھنے لگتا ہے بھلا دیکھو تو اگر یہ راہِ راست پر ہو یا پرہیز گاری کا حکم کرے (تو منع کرنا کیسا) اور دیکھو تو اگر اس نے دین حق کو جھٹلایا اور اس سے منہ موڑا (تو کیا ہوا) کیااس کو معلوم نہیں کہ خدا دیکھ رہا ہے دیکھو اگر وہ باز نہ آئے گا تو ہم (اس کی) پیشانی کے بال پکڑ گھسیٹیں گے یعنی اس جھوٹے خطاکار کی پیشانی کے بال تو وہ اپنے یاروں کی مجلس کو بلالے ہم بھی اپنے موکلانِ دوزخ کو بلا لیں گے دیکھو اس کا کہا نہ ماننا اور قربِ (خدا) حاصل کرتے رہنا',
    '{"surah": 96, "name": "Al-Alaq", "topic": "The first revelation"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 98:1-8',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ لَمْ يَكُنِ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَٰبِ وَٱلْمُشْرِكِينَ مُنفَكِّينَ حَتَّىٰ تَأْتِيَهُمُ ٱلْبَيِّنَةُ  رَسُولٌۭ مِّنَ ٱللَّهِ يَتْلُوا۟ صُحُفًۭا مُّطَهَّرَةًۭ  فِيهَا كُتُبٌۭ قَيِّمَةٌۭ  وَمَا تَفَرَّقَ ٱلَّذِينَ أُوتُوا۟ ٱلْكِتَٰبَ إِلَّا مِنۢ بَعْدِ مَا جَآءَتْهُمُ ٱلْبَيِّنَةُ  وَمَآ أُمِرُوٓا۟ إِلَّا لِيَعْبُدُوا۟ ٱللَّهَ مُخْلِصِينَ لَهُ ٱلدِّينَ حُنَفَآءَ وَيُقِيمُوا۟ ٱلصَّلَوٰةَ وَيُؤْتُوا۟ ٱلزَّكَوٰةَ ۚ وَذَٰلِكَ دِينُ ٱلْقَيِّمَةِ  إِنَّ ٱلَّذِينَ كَفَرُوا۟ مِنْ أَهْلِ ٱلْكِتَٰبِ وَٱلْمُشْرِكِينَ فِى نَارِ جَهَنَّمَ خَٰلِدِينَ فِيهَآ ۚ أُو۟لَٰٓئِكَ هُمْ شَرُّ ٱلْبَرِيَّةِ  إِنَّ ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّٰلِحَٰتِ أُو۟لَٰٓئِكَ هُمْ خَيْرُ ٱلْبَرِيَّةِ  جَزَآؤُهُمْ عِندَ رَبِّهِمْ جَنَّٰتُ عَدْنٍۢ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَٰرُ خَٰلِدِينَ فِيهَآ أَبَدًۭا ۖ رَّضِىَ ٱللَّهُ عَنْهُمْ وَرَضُوا۟ عَنْهُ ۚ ذَٰلِكَ لِمَنْ خَشِىَ رَبَّهُۥ',
    'Those who disbelieved among the People of the Scripture and the polytheists were not to be parted [from misbelief] until there came to them clear evidence - A Messenger from Allah, reciting purified scriptures Within which are correct writings. Nor did those who were given the Scripture become divided until after there had come to them clear evidence. And they were not commanded except to worship Allah, [being] sincere to Him in religion, inclining to truth, and to establish prayer and to give zakah. And that is the correct religion. Indeed, they who disbelieved among the People of the Scripture and the polytheists will be in the fire of Hell, abiding eternally therein. Those are the worst of creatures. Indeed, they who have believed and done righteous deeds - those are the best of creatures. Their reward with Allah will be gardens of perpetual residence beneath which rivers flow, wherein they will abide forever, Allah being pleased with them and they with Him. That is for whoever has feared his Lord.',
    'جو لوگ کافر ہیں (یعنی) اہل کتاب اور مشرک وہ (کفر سے) باز رہنے والے نہ تھے جب تک ان کے پاس کھلی دلیل (نہ) آتی (یعنی) خدا کے پیغمبر جو پاک اوراق پڑھتے ہیں جن میں (مستحکم) آیتیں لکھی ہوئی ہیں اور اہل کتاب جو متفرق (و مختلف) ہوئے ہیں تو دلیل واضح آنے کے بعد (ہوئے ہیں) اور ان کو حکم تو یہی ہوا تھا کہ اخلاص عمل کے ساتھ خدا کی عبادت کریں (اور) یکسو ہو کراورنماز پڑھیں اور زکوٰة دیں اور یہی سچا دین ہے جو لوگ کافر ہیں (یعنی) اہل کتاب اور مشرک وہ دوزخ کی آگ میں پڑیں گے (اور) ہمیشہ اس میں رہیں گے۔ یہ لوگ سب مخلوق سے بدتر ہیں (اور) جو لوگ ایمان لائے اور نیک عمل کرتے رہے وہ تمام خلقت سے بہتر ہیں ان کا صلہ ان کے پروردگار کے ہاں ہمیشہ رہنے کے باغ ہیں جن کے نیچے نہریں بہہ رہی ہیں ابدالاباد ان میں رہیں گے۔ خدا ان سے خوش اور وہ اس سے خوش۔ یہ (صلہ) اس کے لیے ہے جو اپنے پروردگار سے ڈرتا رہا',
    '{"surah": 98, "name": "Al-Bayyinah", "topic": "The clear proof"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 99:1-8',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ إِذَا زُلْزِلَتِ ٱلْأَرْضُ زِلْزَالَهَا  وَأَخْرَجَتِ ٱلْأَرْضُ أَثْقَالَهَا  وَقَالَ ٱلْإِنسَٰنُ مَا لَهَا  يَوْمَئِذٍۢ تُحَدِّثُ أَخْبَارَهَا  بِأَنَّ رَبَّكَ أَوْحَىٰ لَهَا  يَوْمَئِذٍۢ يَصْدُرُ ٱلنَّاسُ أَشْتَاتًۭا لِّيُرَوْا۟ أَعْمَٰلَهُمْ  فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًۭا يَرَهُۥ  وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍۢ شَرًّۭا يَرَهُۥ',
    'When the earth is shaken with its [final] earthquake And the earth discharges its burdens And man says, "What is [wrong] with it?" - That Day, it will report its news Because your Lord has commanded it. That Day, the people will depart separated [into categories] to be shown [the result of] their deeds. So whoever does an atom''s weight of good will see it, And whoever does an atom''s weight of evil will see it.',
    'جب زمین بھونچال سے ہلا دی جائے گی اور زمین اپنے (اندر) کے بوجھ نکال ڈالے گی اور انسان کہے گا کہ اس کو کیا ہوا ہے؟ اس روز وہ اپنے حالات بیان کردے گی کیونکہ تمہارے پروردگار نے اس کو حکم بھیجا (ہوگا) اس دن لوگ گروہ گروہ ہو کر آئیں گے تاکہ ان کو ان کے اعمال دکھا دیئے جائیں تو جس نے ذرہ بھر نیکی کی ہو گی وہ اس کو دیکھ لے گا اور جس نے ذرہ بھر برائی کی ہوگی وہ اسے دیکھ لے گا',
    '{"surah": 99, "name": "Az-Zalzalah", "topic": "The Earthquake"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 100:1-11',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلْعَٰدِيَٰتِ ضَبْحًۭا  فَٱلْمُورِيَٰتِ قَدْحًۭا  فَٱلْمُغِيرَٰتِ صُبْحًۭا  فَأَثَرْنَ بِهِۦ نَقْعًۭا  فَوَسَطْنَ بِهِۦ جَمْعًا  إِنَّ ٱلْإِنسَٰنَ لِرَبِّهِۦ لَكَنُودٌۭ  وَإِنَّهُۥ عَلَىٰ ذَٰلِكَ لَشَهِيدٌۭ  وَإِنَّهُۥ لِحُبِّ ٱلْخَيْرِ لَشَدِيدٌ  ۞ أَفَلَا يَعْلَمُ إِذَا بُعْثِرَ مَا فِى ٱلْقُبُورِ  وَحُصِّلَ مَا فِى ٱلصُّدُورِ  إِنَّ رَبَّهُم بِهِمْ يَوْمَئِذٍۢ لَّخَبِيرٌۢ',
    'By the racers, panting, And the producers of sparks [when] striking And the chargers at dawn, Stirring up thereby [clouds of] dust, Arriving thereby in the center collectively, Indeed mankind, to his Lord, is ungrateful. And indeed, he is to that a witness. And indeed he is, in love of wealth, intense. But does he not know that when the contents of the graves are scattered And that within the breasts is obtained, Indeed, their Lord with them, that Day, is [fully] Acquainted.',
    'ان سرپٹ دوڑنے والے گھوڑوں کی قسم جو ہانپ اٹھتےہیں پھر (پتھروں پر نعل) مار کر آگ نکالتے ہیں پھر صبح کو چھاپہ مارتے ہیں پھر اس میں گرد اٹھاتے ہیں پھر اس وقت دشمن کی فوج میں جا گھستے ہیں کہ انسان اپنے پروردگار کا احسان ناشناس (اور ناشکرا) ہے اور وہ اس سے آگاہ بھی ہے وہ تو مال سے سخت محبت کرنے والا ہے کیا وہ اس وقت کو نہیں جانتا کہ جو (مردے) قبروں میں ہیں وہ باہر نکال لیے جائیں گے اور جو (بھید) دلوں میں ہیں وہ ظاہر کر دیئے جائیں گے بےشک ان کا پروردگار اس روز ان سے خوب واقف ہوگا',
    '{"surah": 100, "name": "Al-Adiyat", "topic": "Gratitude"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 101:1-11',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ٱلْقَارِعَةُ  مَا ٱلْقَارِعَةُ  وَمَآ أَدْرَىٰكَ مَا ٱلْقَارِعَةُ  يَوْمَ يَكُونُ ٱلنَّاسُ كَٱلْفَرَاشِ ٱلْمَبْثُوثِ  وَتَكُونُ ٱلْجِبَالُ كَٱلْعِهْنِ ٱلْمَنفُوشِ  فَأَمَّا مَن ثَقُلَتْ مَوَٰزِينُهُۥ  فَهُوَ فِى عِيشَةٍۢ رَّاضِيَةٍۢ  وَأَمَّا مَنْ خَفَّتْ مَوَٰزِينُهُۥ  فَأُمُّهُۥ هَاوِيَةٌۭ  وَمَآ أَدْرَىٰكَ مَا هِيَهْ  نَارٌ حَامِيَةٌۢ',
    'The Striking Calamity - What is the Striking Calamity? And what can make you know what is the Striking Calamity? It is the Day when people will be like moths, dispersed, And the mountains will be like wool, fluffed up. Then as for one whose scales are heavy [with good deeds], He will be in a pleasant life. But as for one whose scales are light, His refuge will be an abyss. And what can make you know what that is? It is a Fire, intensely hot.',
    'کھڑ کھڑانے والی کھڑ کھڑانے والی کیا ہے؟ اور تم کیا جانوں کھڑ کھڑانے والی کیا ہے؟ (وہ قیامت ہے) جس دن لوگ ایسے ہوں گے جیسے بکھرے ہوئے پتنگے اور پہاڑ ایسے ہو جائیں گے جیسے دھنکی ہوئی رنگ برنگ کی اون تو جس کے (اعمال کے) وزن بھاری نکلیں گے وہ دل پسند عیش میں ہو گا اور جس کے وزن ہلکے نکلیں گے اس کا مرجع ہاویہ ہے اور تم کیا سمجھے کہ ہاویہ کیا چیز ہے؟ دہکتی ہوئی آگ ہے',
    '{"surah": 101, "name": "Al-Qari''ah", "topic": "The Striking Hour"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 102:1-8',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ أَلْهَىٰكُمُ ٱلتَّكَاثُرُ  حَتَّىٰ زُرْتُمُ ٱلْمَقَابِرَ  كَلَّا سَوْفَ تَعْلَمُونَ  ثُمَّ كَلَّا سَوْفَ تَعْلَمُونَ  كَلَّا لَوْ تَعْلَمُونَ عِلْمَ ٱلْيَقِينِ  لَتَرَوُنَّ ٱلْجَحِيمَ  ثُمَّ لَتَرَوُنَّهَا عَيْنَ ٱلْيَقِينِ  ثُمَّ لَتُسْـَٔلُنَّ يَوْمَئِذٍ عَنِ ٱلنَّعِيمِ',
    'Competition in [worldly] increase diverts you Until you visit the graveyards. No! You are going to know. Then no! You are going to know. No! If you only knew with knowledge of certainty... You will surely see the Hellfire. Then you will surely see it with the eye of certainty. Then you will surely be asked that Day about pleasure.',
    '(لوگو) تم کو (مال کی) بہت سی طلب نے غافل کر دیا یہاں تک کہ تم نے قبریں جا دیکھیں دیکھو تمہیں عنقریب معلوم ہو جائے گا پھر دیکھو تمہیں عنقریب معلوم ہو جائے گا دیکھو اگر تم جانتے (یعنی) علم الیقین (رکھتے تو غفلت نہ کرتے) تم ضرور دوزخ کو دیکھو گے پھر اس کو (ایسا) دیکھو گے (کہ) عین الیقین (آ جائے گا) پھر اس روز تم سے (شکر) نعمت کے بارے میں پرسش ہو گی',
    '{"surah": 102, "name": "At-Takathur", "topic": "Rivalry in worldly increase"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 103:1-3',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَٱلْعَصْرِ  إِنَّ ٱلْإِنسَٰنَ لَفِى خُسْرٍ  إِلَّا ٱلَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ ٱلصَّٰلِحَٰتِ وَتَوَاصَوْا۟ بِٱلْحَقِّ وَتَوَاصَوْا۟ بِٱلصَّبْرِ',
    'By time, Indeed, mankind is in loss, Except for those who have believed and done righteous deeds and advised each other to truth and advised each other to patience.',
    'عصر کی قسم کہ انسان نقصان میں ہے مگر وہ لوگ جو ایمان لائے اور نیک عمل کرتے رہے اور آپس میں حق (بات) کی تلقین اور صبر کی تاکید کرتے رہے',
    '{"surah": 103, "name": "Al-Asr", "topic": "Time and loss"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 104:1-9',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ وَيْلٌۭ لِّكُلِّ هُمَزَةٍۢ لُّمَزَةٍ  ٱلَّذِى جَمَعَ مَالًۭا وَعَدَّدَهُۥ  يَحْسَبُ أَنَّ مَالَهُۥٓ أَخْلَدَهُۥ  كَلَّا ۖ لَيُنۢبَذَنَّ فِى ٱلْحُطَمَةِ  وَمَآ أَدْرَىٰكَ مَا ٱلْحُطَمَةُ  نَارُ ٱللَّهِ ٱلْمُوقَدَةُ  ٱلَّتِى تَطَّلِعُ عَلَى ٱلْأَفْـِٔدَةِ  إِنَّهَا عَلَيْهِم مُّؤْصَدَةٌۭ  فِى عَمَدٍۢ مُّمَدَّدَةٍۭ',
    'Woe to every scorner and mocker Who collects wealth and [continuously] counts it. He thinks that his wealth will make him immortal. No! He will surely be thrown into the Crusher. And what can make you know what is the Crusher? It is the fire of Allah, [eternally] fueled, Which mounts directed at the hearts. Indeed, Hellfire will be closed down upon them In extended columns.',
    'ہر طعن آمیز اشارتیں کرنے والے چغل خور کی خرابی ہے جو مال جمع کرتا اور اس کو گن گن کر رکھتا ہے (اور) خیال کرتا ہے کہ اس کا مال اس کی ہمیشہ کی زندگی کا موجب ہو گا ہر گز نہیں وہ ضرور حطمہ میں ڈالا جائے گا اور تم کیا سمجھے حطمہ کیا ہے؟ وہ خدا کی بھڑکائی ہوئی آگ ہے جو دلوں پر جا لپٹے گی (اور) وہ اس میں بند کر دیئے جائیں گے (یعنی آگ کے) لمبے لمبے ستونوں میں',
    '{"surah": 104, "name": "Al-Humazah", "topic": "Slander"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 105:1-5',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ ٱلْفِيلِ  أَلَمْ يَجْعَلْ كَيْدَهُمْ فِى تَضْلِيلٍۢ  وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ  تَرْمِيهِم بِحِجَارَةٍۢ مِّن سِجِّيلٍۢ  فَجَعَلَهُمْ كَعَصْفٍۢ مَّأْكُولٍۭ',
    'Have you not considered, [O Muhammad], how your Lord dealt with the companions of the elephant? Did He not make their plan into misguidance? And He sent against them birds in flocks, Striking them with stones of hard clay, And He made them like eaten straw.',
    'کیا تم نے نہیں دیکھا کہ تمہارے پروردگار نے ہاتھی والوں کے ساتھ کیا کیا کیا ان کا داؤں غلط نہیں کیا؟ (گیا) اور ان پر جھلڑ کے جھلڑ جانور بھیجے جو ان پر کھنگر کی پتھریاں پھینکتے تھے تو ان کو ایسا کر دیا جیسے کھایا ہوا بھس',
    '{"surah": 105, "name": "Al-Fil", "topic": "The People of the Elephant"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 106:1-4',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ لِإِيلَٰفِ قُرَيْشٍ  إِۦلَٰفِهِمْ رِحْلَةَ ٱلشِّتَآءِ وَٱلصَّيْفِ  فَلْيَعْبُدُوا۟ رَبَّ هَٰذَا ٱلْبَيْتِ  ٱلَّذِىٓ أَطْعَمَهُم مِّن جُوعٍۢ وَءَامَنَهُم مِّنْ خَوْفٍۭ',
    'For the accustomed security of the Quraysh - Their accustomed security [in] the caravan of winter and summer - Let them worship the Lord of this House, Who has fed them, [saving them] from hunger and made them safe, [saving them] from fear.',
    'قریش کے مانوس کرنے کے سبب (یعنی) ان کو جاڑے اور گرمی کے سفر سے مانوس کرنے کے سبب لوگوں کو چاہیئے کہ (اس نعمت کے شکر میں) اس گھر کے مالک کی عبادت کریں جس نے ان کو بھوک میں کھانا کھلایا اور خوف سے امن بخشا',
    '{"surah": 106, "name": "Quraysh", "topic": "Blessings upon Quraysh"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 107:1-7',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ أَرَءَيْتَ ٱلَّذِى يُكَذِّبُ بِٱلدِّينِ  فَذَٰلِكَ ٱلَّذِى يَدُعُّ ٱلْيَتِيمَ  وَلَا يَحُضُّ عَلَىٰ طَعَامِ ٱلْمِسْكِينِ  فَوَيْلٌۭ لِّلْمُصَلِّينَ  ٱلَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ  ٱلَّذِينَ هُمْ يُرَآءُونَ  وَيَمْنَعُونَ ٱلْمَاعُونَ',
    'Have you seen the one who denies the Recompense? For that is the one who drives away the orphan And does not encourage the feeding of the poor. So woe to those who pray [But] who are heedless of their prayer - Those who make show [of their deeds] And withhold [simple] assistance.',
    'بھلا تم نے اس شخص کو دیکھا جو (روزِ) جزا کو جھٹلاتا ہے؟ یہ وہی (بدبخت) ہے، جو یتیم کو دھکے دیتا ہے اور فقیر کو کھانا کھلانے کے لیے (لوگوں کو) ترغیب نہیں دیتا تو ایسے نمازیوں کی خرابی ہے جو نماز کی طرف سے غافل رہتے ہیں جو ریا کاری کرتے ہیں اور برتنے کی چیزیں عاریتہً نہیں دیتے',
    '{"surah": 107, "name": "Al-Ma''un", "topic": "Small kindnesses"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 108:1-3',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ إِنَّآ أَعْطَيْنَٰكَ ٱلْكَوْثَرَ  فَصَلِّ لِرَبِّكَ وَٱنْحَرْ  إِنَّ شَانِئَكَ هُوَ ٱلْأَبْتَرُ',
    'Indeed, We have granted you, [O Muhammad], al-Kawthar. So pray to your Lord and sacrifice [to Him alone]. Indeed, your enemy is the one cut off.',
    '(اے محمدﷺ) ہم نے تم کو کوثر عطا فرمائی ہے تو اپنے پروردگار کے لیے نماز پڑھا کرو اور قربانی دیا کرو کچھ شک نہیں کہ تمہارا دشمن ہی بےاولاد رہے گا',
    '{"surah": 108, "name": "Al-Kawthar", "topic": "Abundance"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 109:1-6',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ قُلْ يَٰٓأَيُّهَا ٱلْكَٰفِرُونَ  لَآ أَعْبُدُ مَا تَعْبُدُونَ  وَلَآ أَنتُمْ عَٰبِدُونَ مَآ أَعْبُدُ  وَلَآ أَنَا۠ عَابِدٌۭ مَّا عَبَدتُّمْ  وَلَآ أَنتُمْ عَٰبِدُونَ مَآ أَعْبُدُ  لَكُمْ دِينُكُمْ وَلِىَ دِينِ',
    'Say, "O disbelievers, I do not worship what you worship. Nor are you worshippers of what I worship. Nor will I be a worshipper of what you worship. Nor will you be worshippers of what I worship. For you is your religion, and for me is my religion."',
    '(اے پیغمبر ان منکران اسلام سے) کہہ دو کہ اے کافرو! جن (بتوں) کو تم پوچتے ہو ان کو میں نہیں پوجتا اور جس (خدا) کی میں عبادت کرتا ہوں اس کی تم عبادت نہیں کرتے اور (میں پھر کہتا ہوں کہ) جن کی تم پرستش کرتے ہوں ان کی میں پرستش کرنے والا نہیں ہوں اور نہ تم اس کی بندگی کرنے والے (معلوم ہوتے) ہو جس کی میں بندگی کرتا ہوں تم اپنے دین پر میں اپنے دین پر',
    '{"surah": 109, "name": "Al-Kafirun", "topic": "Disavowal of disbelief"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 110:1-3',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ إِذَا جَآءَ نَصْرُ ٱللَّهِ وَٱلْفَتْحُ  وَرَأَيْتَ ٱلنَّاسَ يَدْخُلُونَ فِى دِينِ ٱللَّهِ أَفْوَاجًۭا  فَسَبِّحْ بِحَمْدِ رَبِّكَ وَٱسْتَغْفِرْهُ ۚ إِنَّهُۥ كَانَ تَوَّابًۢا',
    'When the victory of Allah has come and the conquest, And you see the people entering into the religion of Allah in multitudes, Then exalt [Him] with praise of your Lord and ask forgiveness of Him. Indeed, He is ever Accepting of repentance.',
    'جب خدا کی مدد آ پہنچی اور فتح (حاصل ہو گئی) اور تم نے دیکھ لیا کہ لوگ غول کے غول خدا کے دین میں داخل ہو رہے ہیں تو اپنے پروردگار کی تعریف کے ساتھ تسبیح کرو اور اس سے مغفرت مانگو، بے شک وہ معاف کرنے والا ہے',
    '{"surah": 110, "name": "An-Nasr", "topic": "Divine help and victory"}'::jsonb
  ),
  (
    'quran_juz30',
    'Quran 111:1-5',
    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ تَبَّتْ يَدَآ أَبِى لَهَبٍۢ وَتَبَّ  مَآ أَغْنَىٰ عَنْهُ مَالُهُۥ وَمَا كَسَبَ  سَيَصْلَىٰ نَارًۭا ذَاتَ لَهَبٍۢ  وَٱمْرَأَتُهُۥ حَمَّالَةَ ٱلْحَطَبِ  فِى جِيدِهَا حَبْلٌۭ مِّن مَّسَدٍۭ',
    'May the hands of Abu Lahab be ruined, and ruined is he. His wealth will not avail him or that which he gained. He will [enter to] burn in a Fire of [blazing] flame And his wife [as well] - the carrier of firewood. Around her neck is a rope of [twisted] fiber.',
    'ابولہب کے ہاتھ ٹوٹیں اور وہ ہلاک ہو نہ تو اس کا مال ہی اس کے کچھ کام آیا اور نہ وہ جو اس نے کمایا وہ جلد بھڑکتی ہوئی آگ میں داخل ہو گا اور اس کی جورو بھی جو ایندھن سر پر اٹھائے پھرتی ہے اس کے گلے میں مونج کی رسّی ہو گی',
    '{"surah": 111, "name": "Al-Masad", "topic": "Abu Lahab"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 6324',
    'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ',
    'All praise is for Allah who gave us life after having taken it from us, and unto Him is the resurrection.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے ہمیں موت کے بعد زندگی عطا کی اور اسی کی طرف اٹھ کر جانا ہے۔',
    '{"category": "Waking Up"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 5095',
    'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ',
    'In the name of Allah, I place my trust in Allah, and there is no might nor power except with Allah.',
    'اللہ کے نام سے، میں نے اللہ پر بھروسہ کیا، اور نیکی کی طاقت اور گناہ سے بچنے کی قوت صرف اللہ ہی سے ہے۔',
    '{"category": "Leaving Home"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 5096',
    'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا',
    'In the name of Allah we enter and in the name of Allah we leave, and upon our Lord we place our trust.',
    'اللہ کے نام سے ہم داخل ہوئے اور اللہ کے نام سے ہم نکلے، اور اپنے رب پر ہم نے بھروسہ کیا۔',
    '{"category": "Entering Home"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3455',
    'بِسْمِ اللَّهِ، اللَّهُمَّ بَارِكْ لَنَا فِيهِ وَأَطْعِمْنَا خَيْرًا مِنْهُ',
    'In the name of Allah. O Allah, bless it for us and feed us better than it.',
    'اللہ کے نام سے۔ اے اللہ! اس میں ہمارے لیے برکت عطا فرما اور ہمیں اس سے بہتر کھلا۔',
    '{"category": "Eating"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 4023',
    'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنِي هَذَا وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ',
    'All praise is for Allah who fed me this and provided it for me without any might or power on my part.',
    'تمام تعریفیں اللہ کے لیے ہیں جس نے مجھے یہ کھلایا اور میری کسی طاقت و قوت کے بغیر مجھے یہ رزق دیا۔',
    '{"category": "Eating"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 466',
    'أَعُوذُ بِاللَّهِ الْعَظِيمِ وَبِوَجْهِهِ الْكَرِيمِ وَسُلْطَانِهِ الْقَدِيمِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    'I seek refuge with Allah, the Supreme, His Noble Face, and His eternal authority, from Satan the accursed.',
    'میں اللہ عظیم، اس کے کریم چہرے اور اس کی قدیم بادشاہت کی پناہ مانگتا ہوں شیطان مردود سے۔',
    '{"category": "Masjid"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 713',
    'بِسْمِ اللَّهِ وَالصَّلَاةُ وَالسَّلَامُ عَلَى رَسُولِ اللَّهِ، اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ',
    'In the name of Allah, and peace and blessings be upon the Messenger of Allah. O Allah, I ask You of Your bounty.',
    'اللہ کے نام سے، اور درود و سلام ہو اللہ کے رسول پر۔ اے اللہ! میں تجھ سے تیرے فضل کا سوال کرتا ہوں۔',
    '{"category": "Masjid"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 6324',
    'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
    'In Your name, O Allah, I die and I live.',
    'تیرے نام سے اے اللہ! میں مرتا ہوں اور جیتا ہوں۔',
    '{"category": "Sleep"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 1154',
    'لَا إِلَهَ إِلَّا اللَّهُ الْوَاحِدُ الْقَهَّارُ، رَبُّ السَّمَاوَاتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا الْعَزِيزُ الْغَفَّارُ',
    'There is no deity but Allah, the One, the Irresistible, Lord of the heavens and the earth and all between them, the Exalted in Might, the Forgiving.',
    'اللہ کے سوا کوئی معبود نہیں، وہ ایک ہے، زبردست ہے، آسمانوں اور زمین اور ان کے درمیان کی ہر چیز کا رب ہے، غالب ہے، بخشنے والا ہے۔',
    '{"category": "Sleep"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 1517',
    'أَسْتَغْفِرُ اللَّهَ الْعَظِيمَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ',
    'I seek Allah''s forgiveness, the Great, whom there is no deity but Him, the Ever-Living, the Sustainer, and I repent to Him.',
    'میں اللہ عظیم سے بخشش مانگتا ہوں جس کے سوا کوئی معبود نہیں، وہ زندہ ہے، قائم رکھنے والا ہے، اور میں اس کی طرف توبہ کرتا ہوں۔',
    '{"category": "Repentance"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 6306',
    'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ بِذَنْبِي فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ',
    'O Allah, You are my Lord, there is no deity but You. You created me and I am Your servant, and I abide by Your covenant and promise as best I can. I seek refuge in You from the evil of what I have done. I acknowledge Your favor upon me and I acknowledge my sin, so forgive me, for none forgives sins but You. (Sayyid al-Istighfar)',
    'اے اللہ! تو میرا رب ہے، تیرے سوا کوئی معبود نہیں۔ تو نے مجھے پیدا کیا اور میں تیرا بندہ ہوں، اور میں اپنی استطاعت کے مطابق تیرے عہد و وعدے پر قائم ہوں۔ میں اپنے کیے کے شر سے تیری پناہ مانگتا ہوں۔ میں تیرے احسان کا اقرار کرتا ہوں اور اپنے گناہ کا اعتراف کرتا ہوں، پس مجھے بخش دے، کیونکہ تیرے سوا کوئی گناہوں کو بخشنے والا نہیں۔ (سید الاستغفار)',
    '{"category": "Repentance"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3505',
    'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ',
    'There is no deity except You; glory be to You. Indeed, I have been of the wrongdoers. (Dua of Yunus)',
    'تیرے سوا کوئی معبود نہیں، تو پاک ہے۔ بے شک میں ظالموں میں سے ہو گیا۔ (دعائے یونس)',
    '{"category": "Distress"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3563',
    'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ',
    'O Allah, suffice me with what You have made lawful against what You have made unlawful, and enrich me by Your bounty over all others.',
    'اے اللہ! مجھے اپنے حلال سے اپنے حرام سے بے نیاز کر دے اور اپنے فضل سے اپنے سوا سب سے بے نیاز کر دے۔',
    '{"category": "Provision"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 1555; Sahih al-Bukhari 6363',
    'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ وَالْعَجْزِ وَالْكَسَلِ وَالْبُخْلِ وَالْجُبْنِ وَضَلَعِ الدَّيْنِ وَغَلَبَةِ الرِّجَالِ',
    'O Allah, I seek refuge in You from anxiety and sorrow, weakness and laziness, miserliness and cowardice, the burden of debts and from being overpowered by men.',
    'اے اللہ! میں تیری پناہ مانگتا ہوں فکر و غم سے، عاجزی و سستی سے، بخل و بزدلی سے، قرض کے بوجھ سے اور لوگوں کے غلبے سے۔',
    '{"category": "Anxiety"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 3282',
    'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ',
    'I seek refuge with Allah from Satan, the accursed. (Said when angry)',
    'میں اللہ کی پناہ مانگتا ہوں شیطان مردود سے۔ (غصے کے وقت)',
    '{"category": "Character"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 1537',
    'اللَّهُمَّ إِنَّا نَجْعَلُكَ فِي نُحُورِهِمْ وَنَعُوذُ بِكَ مِنْ شُرُورِهِمْ',
    'O Allah, we place You before them and seek refuge in You from their evil.',
    'اے اللہ! ہم تجھے ان کے سامنے کرتے ہیں اور ان کے شر سے تیری پناہ مانگتے ہیں۔',
    '{"category": "Fear"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 5743',
    'أَذْهِبِ الْبَأْسَ رَبَّ النَّاسِ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا',
    'Remove the harm, Lord of mankind, and heal, for You are the Healer; there is no healing but Your healing, a healing that leaves no illness.',
    'تکلیف دور کر دے اے لوگوں کے رب! شفا عطا فرما، تو ہی شفا دینے والا ہے۔ تیری شفا کے سوا کوئی شفا نہیں، ایسی شفا جو کوئی بیماری نہ چھوڑے۔',
    '{"category": "Healing"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 2202',
    'بِسْمِ اللَّهِ (ثلاثًا)، أَعُوذُ بِاللَّهِ وَقُدْرَتِهِ مِنْ شَرِّ مَا أَجِدُ وَأُحَاذِرُ (سبعًا)',
    'In the name of Allah (three times). I seek refuge with Allah and His power from the evil of what I feel and fear (seven times). (Place hand on the painful area)',
    'اللہ کے نام سے (تین بار)۔ میں اللہ اور اس کی قدرت کی پناہ مانگتا ہوں اس تکلیف کے شر سے جو میں محسوس کرتا ہوں اور جس سے ڈرتا ہوں (سات بار)۔',
    '{"category": "Healing"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 963',
    'اللَّهُمَّ اغْفِرْ لَهُ وَارْحَمْهُ وَعَافِهِ وَاعْفُ عَنْهُ وَأَكْرِمْ نُزُلَهُ وَوَسِّعْ مُدْخَلَهُ',
    'O Allah, forgive him, have mercy on him, grant him ease and pardon him, honor his resting place and expand his entrance.',
    'اے اللہ! اسے بخش دے، اس پر رحم فرما، اسے عافیت دے اور اسے معاف فرما، اس کی مہمانی کو عزت دے اور اس کے داخلے کو وسیع فرما۔',
    '{"category": "Funeral"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 975',
    'السَّلَامُ عَلَيْكُمْ أَهْلَ الدِّيَارِ مِنَ الْمُؤْمِنِينَ وَالْمُسْلِمِينَ، وَإِنَّا إِنْ شَاءَ اللَّهُ بِكُمْ لَاحِقُونَ، أَسْأَلُ اللَّهَ لَنَا وَلَكُمُ الْعَافِيَةَ',
    'Peace be upon you, O dwellers of the graves, believers and Muslims. We will, Allah willing, join you. I ask Allah for well-being for us and for you.',
    'تم پر سلام ہو اے قبروں والو! مومنو اور مسلمانو! اور ہم ان شاء اللہ تم سے ملنے والے ہیں۔ میں اللہ سے اپنے اور تمہارے لیے عافیت مانگتا ہوں۔',
    '{"category": "Funeral"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 1032',
    'اللَّهُمَّ صَيِّبًا نَافِعًا',
    'O Allah, [bring] beneficial rain.',
    'اے اللہ! نفع بخش بارش برسا۔',
    '{"category": "Weather"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 899',
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا وَخَيْرَ مَا فِيهَا وَخَيْرَ مَا أُرْسِلَتْ بِهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا وَشَرِّ مَا فِيهَا وَشَرِّ مَا أُرْسِلَتْ بِهِ',
    'O Allah, I ask You for its good, the good within it, and the good it was sent with; and I seek refuge in You from its evil, the evil within it, and the evil it was sent with.',
    'اے اللہ! میں تجھ سے اس کی بھلائی، اس کے اندر کی بھلائی اور جس بھلائی کے ساتھ یہ بھیجی گئی ہے اس کا سوال کرتا ہوں، اور اس کے شر، اس کے اندر کے شر اور جس شر کے ساتھ یہ بھیجی گئی ہے اس سے تیری پناہ مانگتا ہوں۔',
    '{"category": "Weather"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3513',
    'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي',
    'O Allah, You are Pardoning and love pardon, so pardon me. (Dua for Laylat al-Qadr)',
    'اے اللہ! تو معاف کرنے والا ہے، معافی کو پسند کرتا ہے، پس مجھے معاف فرما۔ (لیلۃ القدر کی دعا)',
    '{"category": "Worship"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 596',
    'سُبْحَانَ اللَّهِ (٣٣)، الْحَمْدُ لِلَّهِ (٣٣)، اللَّهُ أَكْبَرُ (٣٤)',
    'Glory be to Allah (33 times), praise be to Allah (33 times), Allah is Greatest (34 times). (After each obligatory prayer)',
    'سبحان اللہ (33 بار)، الحمد للہ (33 بار)، اللہ اکبر (34 بار)۔ (ہر فرض نماز کے بعد)',
    '{"category": "After Prayer"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 588',
    'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنْ عَذَابِ جَهَنَّمَ وَمِنْ عَذَابِ الْقَبْرِ وَمِنْ فِتْنَةِ الْمَحْيَا وَالْمَمَاتِ وَمِنْ شَرِّ فِتْنَةِ الْمَسِيحِ الدَّجَّالِ',
    'O Allah, I seek refuge in You from the punishment of Hell, the punishment of the grave, the trials of life and death, and the evil of the trial of the False Messiah.',
    'اے اللہ! میں تیری پناہ مانگتا ہوں جہنم کے عذاب سے، قبر کے عذاب سے، زندگی اور موت کے فتنے سے، اور مسیح دجال کے فتنے کے شر سے۔',
    '{"category": "Prayer"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 1425',
    'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ',
    'O Allah, guide me among those You have guided, grant me well-being among those You have granted well-being, take me into Your care among those You have taken into Your care, bless for me what You have given, and protect me from the evil of what You have decreed. (Dua al-Qunut)',
    'اے اللہ! مجھے ہدایت دے ان میں جنہیں تو نے ہدایت دی، مجھے عافیت دے ان میں جنہیں تو نے عافیت دی، میری سرپرستی فرما ان میں جن کی تو نے سرپرستی فرمائی، جو تو نے مجھے دیا اس میں برکت دے، اور مجھے اس کے شر سے بچا جو تو نے مقدر کیا۔ (دعائے قنوت)',
    '{"category": "Prayer"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Ibn Majah 925',
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا وَعَمَلًا مُتَقَبَّلًا',
    'O Allah, I ask You for beneficial knowledge, wholesome provision, and accepted deeds.',
    'اے اللہ! میں تجھ سے نفع بخش علم، پاکیزہ رزق اور مقبول عمل کا سوال کرتا ہوں۔',
    '{"category": "Knowledge"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Quran 17:24',
    'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا',
    'My Lord, have mercy upon them (my parents) as they raised me when I was small.',
    'اے میرے رب! ان دونوں (والدین) پر رحم فرما جیسے انہوں نے بچپن میں میری پرورش کی۔',
    '{"category": "Family"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Quran 25:74',
    'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا',
    'Our Lord, grant us from among our spouses and offspring comfort to our eyes, and make us leaders of the righteous.',
    'اے ہمارے رب! ہمیں ہماری بیویوں اور اولاد سے آنکھوں کی ٹھنڈک عطا فرما اور ہمیں پرہیزگاروں کا امام بنا۔',
    '{"category": "Family"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Quran 28:24',
    'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ',
    'My Lord, indeed I am in need of whatever good You send down to me. (Dua of Musa)',
    'اے میرے رب! جو بھلائی بھی تو مجھ پر نازل فرمائے، میں اس کا محتاج ہوں۔ (دعائے موسیٰ)',
    '{"category": "Provision"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3428',
    'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، يُحْيِي وَيُمِيتُ، وَهُوَ حَيٌّ لَا يَمُوتُ، بِيَدِهِ الْخَيْرُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'There is no deity but Allah, alone, without partner. His is the dominion and His is the praise. He gives life and causes death, and He is Living and does not die. In His hand is all good, and He is capable of all things. (Said upon entering the marketplace)',
    'اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں۔ اسی کی بادشاہت ہے اور اسی کی تعریف ہے۔ وہ زندہ کرتا ہے اور موت دیتا ہے، وہ زندہ ہے کبھی مرے گا نہیں۔ اس کے ہاتھ میں بھلائی ہے اور وہ ہر چیز پر قادر ہے۔ (بازار میں داخل ہوتے وقت)',
    '{"category": "Daily"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 4020',
    'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ، أَسْأَلُكَ مِنْ خَيْرِهِ وَخَيْرِ مَا صُنِعَ لَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ',
    'O Allah, praise be to You; You have clothed me with it. I ask You for its good and the good for which it was made, and I seek refuge in You from its evil and the evil for which it was made. (When wearing new clothes)',
    'اے اللہ! تیرے لیے تعریف ہے، تو نے مجھے یہ پہنایا۔ میں تجھ سے اس کی بھلائی اور جس بھلائی کے لیے یہ بنایا گیا ہے اس کا سوال کرتا ہوں، اور اس کے شر اور جس شر کے لیے یہ بنایا گیا ہے اس سے تیری پناہ مانگتا ہوں۔',
    '{"category": "Daily"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 234',
    'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ',
    'I bear witness that there is no deity but Allah, alone, without partner, and I bear witness that Muhammad is His servant and Messenger. (After wudu — the eight gates of Paradise are opened for him)',
    'میں گواہی دیتا ہوں کہ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اور میں گواہی دیتا ہوں کہ محمد اس کے بندے اور رسول ہیں۔ (وضو کے بعد)',
    '{"category": "Purification"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 2358',
    'اللَّهُمَّ لَكَ صُمْتُ وَعَلَى رِزْقِكَ أَفْطَرْتُ',
    'O Allah, for You I fasted and with Your provision I break my fast.',
    'اے اللہ! تیرے لیے میں نے روزہ رکھا اور تیرے رزق سے افطار کرتا ہوں۔',
    '{"category": "Fasting"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3522',
    'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ',
    'O Turner of hearts, make my heart firm upon Your religion.',
    'اے دلوں کو پھیرنے والے! میرے دل کو اپنے دین پر ثابت رکھ۔',
    '{"category": "Faith"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan Abi Dawud 5072',
    'رَضِيتُ بِاللَّهِ رَبًّا وَبِالْإِسْلَامِ دِينًا وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا',
    'I am pleased with Allah as Lord, Islam as religion, and Muhammad (peace be upon him) as Prophet. (Whoever says it morning and evening, Allah will please him on the Day of Resurrection)',
    'میں اللہ کے رب ہونے، اسلام کے دین ہونے اور محمد ﷺ کے نبی ہونے پر راضی ہوں۔',
    '{"category": "Morning & Evening"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sunan al-Tirmidhi 3388',
    'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ',
    'In the name of Allah, with whose name nothing on earth or in heaven can cause harm, and He is the All-Hearing, the All-Knowing. (Three times morning and evening)',
    'اللہ کے نام سے جس کے نام سے زمین و آسمان میں کوئی چیز نقصان نہیں پہنچا سکتی، اور وہ سننے والا، جاننے والا ہے۔ (صبح و شام تین بار)',
    '{"category": "Protection"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 4:103',
    'إِنَّ الصَّلَاةَ كَانَتْ عَلَى الْمُؤْمِنِينَ كِتَابًا مَوْقُوتًا',
    'Q: Why do Muslims pray five times a day? A: The five daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha) are obligatory for every adult Muslim. Allah says: ''Indeed, prayer has been decreed upon the believers a decree of specified times'' [Quran 4:103]. They were made obligatory during the Prophet''s Night Journey (Al-Isra wal-Mi''raj) [Sahih al-Bukhari 349].',
    'سوال: مسلمان دن میں پانچ بار نماز کیوں پڑھتے ہیں؟ جواب: پانچوں نمازیں ہر بالغ مسلمان پر فرض ہیں۔ اللہ فرماتا ہے: ''بے شک نماز مومنوں پر مقررہ وقتوں میں فرض کی گئی ہے'' [القرآن 4:103]۔',
    '{"topic": "Five Daily Prayers", "category": "Ibadah"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 135',
    NULL,
    'Q: What breaks wudu? A: The agreed-upon nullifiers of wudu are: (1) anything exiting the private parts (urine, stool, wind), (2) deep sleep in which one loses awareness, (3) loss of consciousness or insanity. The Prophet (pbuh) said: ''Allah does not accept the prayer of one who has lost his wudu until he performs wudu again'' [Sahih al-Bukhari 135]. Touching one''s spouse or vomiting are differed upon between madhabs.',
    'سوال: وضو کن چیزوں سے ٹوٹتا ہے؟ جواب: پیشاب، پاخانہ، ہوا کا خارج ہونا، گہری نیند اور بے ہوشی سے وضو ٹوٹ جاتا ہے۔',
    '{"topic": "Wudu Nullifiers", "category": "Purification"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 248',
    NULL,
    'Q: How do I perform ghusl (ritual bath)? A: (1) Make intention (niyyah). (2) Wash hands and private parts. (3) Perform wudu as for prayer. (4) Pour water over the head three times, rubbing it to reach the roots. (5) Pour water over the entire body, starting with the right side. Aisha (RA) described the Prophet''s ghusl in this manner [Sahih al-Bukhari 248]. Ghusl is obligatory after janabah, menstruation, and postpartum bleeding.',
    'سوال: غسل کا صحیح طریقہ کیا ہے؟ جواب: نیت کریں، ہاتھ اور شرمگاہ دھوئیں، نماز جیسا وضو کریں، پھر سر پر تین بار پانی ڈالیں اور پورے بدن پر پانی بہائیں۔',
    '{"topic": "Ghusl Method", "category": "Purification"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 2:184',
    'فَمَنْ كَانَ مِنْكُمْ مَرِيضًا أَوْ عَلَى سَفَرٍ فَعِدَّةٌ مِنْ أَيَّامٍ أُخَرَ',
    'Q: I missed fasts in Ramadan due to illness/travel. What now? A: Make them up (qada) before the next Ramadan. Allah says: ''...whoever is ill or on a journey, then an equal number of other days'' [Quran 2:184]. If one cannot fast at all due to chronic illness or old age, feed one poor person per missed day (fidyah).',
    'سوال: بیماری یا سفر کی وجہ سے روزے چھوٹ گئے تو کیا کروں؟ جواب: اگلے رمضان سے پہلے قضا رکھیں۔ دائمی بیماری کی صورت میں فی مسکین فدیہ دیں۔ [القرآن 2:184]',
    '{"topic": "Missed Fasts", "category": "Fasting"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih Muslim 728',
    NULL,
    'Q: What are the Sunnah Rawatib prayers? A: The twelve emphasized voluntary rak''ahs attached to the obligatory prayers: 2 before Fajr, 4 before Dhuhr + 2 after, 2 after Maghrib, 2 after Isha. The Prophet (pbuh) said whoever prays twelve rak''ahs voluntarily in a day and night, Allah will build for him a house in Paradise [Sahih Muslim 728].',
    'سوال: سنن رواتب کیا ہیں؟ جواب: فرض نمازوں کے ساتھ بارہ رکعت سنت مؤکدہ: فجر سے پہلے 2، ظہر سے پہلے 4 اور بعد میں 2، مغرب کے بعد 2، عشاء کے بعد 2۔',
    '{"topic": "Sunnah Rawatib", "category": "Prayer"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 5:6',
    'فَلَمْ تَجِدُوا مَاءً فَتَيَمَّمُوا صَعِيدًا طَيِّبًا',
    'Q: How do I do tayammum (dry ablution)? A: When water is unavailable or harmful to use: (1) Make intention. (2) Strike clean earth/dust with both palms once. (3) Wipe the face. (4) Wipe both hands up to the wrists. Allah says: ''...and find no water, then seek clean earth and wipe over your faces and hands with it'' [Quran 5:6]. One strike suffices according to the majority.',
    'سوال: تیمم کیسے کریں؟ جواب: پانی نہ ملے تو نیت کر کے پاک مٹی پر ہاتھ ماریں، چہرے اور کہنیوں تک ہاتھوں کا مسح کریں۔ [القرآن 5:6]',
    '{"topic": "Tayammum", "category": "Purification"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 24:31',
    'وَقُلْ لِلْمُؤْمِنَاتِ يَغْضُضْنَ مِنْ أَبْصَارِهِنَّ وَيَحْفَظْنَ فُرُوجَهُنَّ',
    'Q: What is the Islamic evidence for hijab? A: Allah commands believing women: ''...to lower their gaze and guard their private parts and not expose their adornment except that which appears thereof, and to draw their headcovers over their chests'' [Quran 24:31], and ''O Prophet, tell your wives and daughters and the women of the believers to bring down over themselves part of their outer garments'' [Quran 33:59].',
    'سوال: حجاب کی شرعی دلیل کیا ہے؟ جواب: اللہ کا حکم ہے کہ مومن عورتیں اپنی نظریں نیچی رکھیں اور اپنی اوڑھنیاں اپنے سینوں پر ڈالیں۔ [القرآن 24:31، 33:59]',
    '{"topic": "Hijab Evidence", "category": "Aqeedah & Practice"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 2766',
    NULL,
    'Q: What are the major sins in Islam? A: The Prophet (pbuh) warned against the seven destructive sins: associating partners with Allah, magic, killing a soul unjustly, consuming riba (usury), consuming an orphan''s wealth, fleeing from battle, and slandering chaste believing women [Sahih al-Bukhari 2766]. Major sins require sincere repentance (tawbah).',
    'سوال: کبیرہ گناہ کون سے ہیں؟ جواب: شرک، جادو، ناحق قتل، سود، یتیم کا مال، میدان جنگ سے فرار، پاکدامن عورت پر تہمت — یہ سات ہلاک کرنے والے گناہ ہیں۔',
    '{"topic": "Major Sins", "category": "Aqeedah"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 2017',
    'تَحَرَّوْا لَيْلَةَ الْقَدْرِ فِي الْوِتْرِ مِنَ الْعَشْرِ الْأَوَاخِرِ مِنْ رَمَضَانَ',
    'Q: When is Laylat al-Qadr? A: Seek it in the odd nights of the last ten nights of Ramadan (21st, 23rd, 25th, 27th, 29th). The Prophet (pbuh) said: ''Seek Laylat al-Qadr in the odd nights of the last ten of Ramadan'' [Sahih al-Bukhari 2017]. It is better than a thousand months [Quran 97:3].',
    'سوال: لیلۃ القدر کب ہوتی ہے؟ جواب: رمضان کے آخری عشرے کی طاق راتوں (21، 23، 25، 27، 29) میں تلاش کریں۔',
    '{"topic": "Laylat al-Qadr Timing", "category": "Worship"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 71:10-12',
    'فَقُلْتُ اسْتَغْفِرُوا رَبَّكُمْ إِنَّهُ كَانَ غَفَّارًا',
    'Q: What is the virtue of seeking forgiveness (istighfar)? A: Allah promises worldly and spiritual blessings for istighfar. Nuh (AS) told his people: ''Ask forgiveness of your Lord. Indeed, He is ever a Perpetual Forgiver. He will send rain from the sky upon you in showers and give you increase in wealth and children'' [Quran 71:10-12]. Sayyid al-Istighfar said morning and evening guarantees Paradise for the sincere [Sahih al-Bukhari 6306].',
    'سوال: استغفار کی فضیلت کیا ہے؟ جواب: استغفار سے گناہ معاف ہوتے ہیں، رزق میں برکت اور اولاد ملتی ہے۔ [القرآن 71:10-12]',
    '{"topic": "Virtue of Istighfar", "category": "Repentance"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih Muslim 720',
    NULL,
    'Q: What is Salat al-Duha? A: The voluntary forenoon prayer, prayed after sunrise (about 15-20 minutes after) until just before Dhuhr. Minimum 2 rak''ahs; the Prophet (pbuh) sometimes prayed 8. It suffices as charity for every joint of the body [Sahih Muslim 720].',
    'سوال: نماز چاشت کیا ہے؟ جواب: طلوع آفتاب کے بعد سے ظہر سے پہلے تک پڑھی جانے والی نفلی نماز، کم از کم 2 رکعت۔',
    '{"topic": "Duha Prayer", "category": "Prayer"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 1335',
    NULL,
    'Q: How is the Janazah (funeral) prayer performed? A: (1) First takbir, then recite Al-Fatiha. (2) Second takbir, then send salutations on the Prophet ( durood-e-Ibrahim). (3) Third takbir, then make sincere dua for the deceased. (4) Fourth takbir, then taslim to the right. There is no ruku or sujood in Janazah [Sahih al-Bukhari 1335].',
    'سوال: نماز جنازہ کیسے پڑھیں؟ جواب: چار تکبیریں — پہلی کے بعد سورۃ فاتحہ، دوسری کے بعد درود ابراہیمی، تیسری کے بعد میت کے لیے دعا، چوتھی کے بعد سلام۔',
    '{"topic": "Janazah Prayer", "category": "Fiqh"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sunan Abi Dawud 1488',
    NULL,
    'Q: What are the etiquettes of making dua? A: (1) Begin with praise of Allah and salawat on the Prophet. (2) Raise the hands. (3) Ask with conviction and persistence. (4) Choose blessed times (last third of night, between adhan and iqamah, while fasting, on Fridays). The Prophet (pbuh) said: ''Allah is Shy and Generous; He is shy to turn away empty the hands of a servant when he raises them to Him'' [Sunan Abi Dawud 1488].',
    'سوال: دعا کے آداب کیا ہیں؟ جواب: اللہ کی حمد و ثنا اور درود سے شروع کریں، ہاتھ اٹھائیں، یقین سے مانگیں اور قبولیت کے اوقات (تہجد، اذان و اقامت کے درمیان) کا اہتمام کریں۔',
    '{"topic": "Etiquettes of Dua", "category": "Worship"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sunan al-Tirmidhi 3747',
    NULL,
    'Q: Who are the Ashara Mubashara (ten promised Paradise)? A: The ten companions given glad tidings of Paradise by the Prophet (pbuh): Abu Bakr, Umar, Uthman, Ali, Talha, Zubayr, Abdur-Rahman ibn Awf, Sa''d ibn Abi Waqqas, Sa''id ibn Zayd, and Abu Ubaydah ibn al-Jarrah (may Allah be pleased with them all) [Sunan al-Tirmidhi 3747].',
    'سوال: عشرہ مبشرہ کون ہیں؟ جواب: وہ دس صحابہ جنہیں نبی ﷺ نے جنت کی بشارت دی: ابوبکر، عمر، عثمان، علی، طلحہ، زبیر، عبدالرحمن بن عوف، سعد بن ابی وقاص، سعید بن زید، ابوعبیدہ بن الجراح رضی اللہ عنہم۔',
    '{"topic": "Ashara Mubashara", "category": "Seerah"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 8:9',
    'إِذْ تَسْتَغِيثُونَ رَبَّكُمْ فَاسْتَجَابَ لَكُمْ',
    'Q: What happened at the Battle of Badr? A: The first major battle of Islam, fought on 17 Ramadan 2 AH. 313 poorly-equipped Muslims faced ~1000 Quraysh. Allah sent angels to aid the believers: ''When you sought help of your Lord, He answered you'' [Quran 8:9]. The victory established the Muslim community in Madinah.',
    'سوال: غزوہ بدر میں کیا ہوا؟ جواب: 17 رمضان 2ھ کو 313 مسلمانوں نے 1000 کفار کو شکست دی۔ اللہ نے فرشتوں سے مدد فرمائی۔ [القرآن 8:9]',
    '{"topic": "Battle of Badr", "category": "Seerah"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 2:152',
    'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    'Q: Why is dhikr (remembrance of Allah) important? A: Allah says: ''So remember Me; I will remember you. Be grateful to Me and do not deny Me'' [Quran 2:152]. The Prophet (pbuh) said the comparison of one who remembers Allah and one who does not is like the living and the dead [Sahih al-Bukhari 6407]. Morning and evening adhkar protect the believer through the day.',
    'سوال: ذکر کی اہمیت کیا ہے؟ جواب: اللہ فرماتا ہے: ''تم مجھے یاد کرو میں تمہیں یاد کروں گا'' [القرآن 2:152]۔ ذکر کرنے والا زندہ کی طرح ہے اور نہ کرنے والا مردہ کی طرح۔',
    '{"topic": "Dhikr Virtue", "category": "Worship"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 6015',
    NULL,
    'Q: What are the rights of neighbors in Islam? A: The Prophet (pbuh) said: ''Jibril kept advising me about the neighbor until I thought he would make him an heir'' [Sahih al-Bukhari 6015]. Rights include: not harming them, sharing food, helping in need, and visiting the sick. ''He is not a believer whose neighbor is not safe from his harm'' [Sahih al-Bukhari 6016].',
    'سوال: پڑوسیوں کے حقوق کیا ہیں؟ جواب: پڑوسی کو تکلیف نہ دیں، کھانا بانٹیں، ضرورت میں مدد کریں۔ ''وہ مومن نہیں جس کے شر سے اس کا پڑوسی محفوظ نہ ہو۔''',
    '{"topic": "Rights of Neighbors", "category": "Character"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Quran 2:183',
    'يَا أَيُّهَا الَّذِينَ آمَنُوا كُتِبَ عَلَيْكُمُ الصِّيَامُ كَمَا كُتِبَ عَلَى الَّذِينَ مِنْ قَبْلِكُمْ لَعَلَّكُمْ تَتَّقُونَ',
    'Q: What is the purpose of fasting in Ramadan? A: Fasting was prescribed to develop taqwa (God-consciousness): ''O you who believe, fasting is prescribed for you as it was prescribed for those before you, that you may become righteous'' [Quran 2:183]. It trains self-discipline, empathy for the poor, and gratitude. The Prophet (pbuh) said whoever fasts Ramadan with faith and hope for reward, his past sins are forgiven [Sahih al-Bukhari 38].',
    'سوال: روزے کا مقصد کیا ہے؟ جواب: تقویٰ پیدا کرنا۔ ''اے ایمان والو! تم پر روزے فرض کیے گئے جیسے تم سے پہلوں پر فرض کیے گئے تھے تاکہ تم پرہیزگار بنو'' [القرآن 2:183]۔',
    '{"topic": "Purpose of Fasting", "category": "Fasting"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih al-Bukhari 1224',
    NULL,
    'Q: What is Sujood al-Sahw (prostration of forgetfulness)? A: Two extra prostrations to compensate for mistakes in prayer — e.g., forgetting the first tashahhud or adding an extra rak''ah. The Prophet (pbuh) performed them after taslim when he prayed five rak''ahs of Dhuhr by mistake [Sahih al-Bukhari 1224]. If the mistake is before taslim in some cases, they are done before it — scholars differ on details.',
    'سوال: سجدہ سہو کیا ہے؟ جواب: نماز میں بھول چوک (مثلاً قعدہ اولیٰ چھوٹ جانا) کی تلافی کے لیے دو سجدے۔',
    '{"topic": "Sujood al-Sahw", "category": "Prayer"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih Muslim 82',
    NULL,
    'Q: What is the ruling on deliberately missing prayers? A: Scholars differ seriously here. One view (Ahmad and others): deliberately abandoning prayer is disbelief, based on ''Between a man and disbelief is abandoning prayer'' [Sahih Muslim 82]. The majority (Hanafi, Maliki, Shafi''i): it is a major sin but not disbelief as long as one affirms its obligation. All agree it is among the gravest sins — one must repent and make up missed prayers.',
    'سوال: جان بوجھ کر نماز چھوڑنے کا حکم کیا ہے؟ جواب: بعض علماء کے نزدیک کفر ہے، جمہور کے نزدیک کبیرہ گناہ۔ سب متفق ہیں کہ یہ سنگین گناہ ہے، توبہ اور قضا لازم ہے۔',
    '{"topic": "Missing Prayer", "category": "Fiqh Differences"}'::jsonb
  );

-- ==============================================================================
-- v3 EXPANSION (2026-10-07): +13 docs from the citation-verified v1.1 draft
-- (8 key Quranic verses incl. Al-Fatiha & Ayat al-Kursi, 2 duas, 3 FAQs).
-- Duplicates/subsets of v2 already skipped. NOTE: run AFTER v1+v2 seeds above.
-- ==============================================================================

insert into public.corpus_documents
(collection, reference, content_arabic, content_english, content_urdu, metadata)
values
  (
    'quran',
    'Quran 1:1-7',
    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ  الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ  الرَّحْمَٰنِ الرَّحِيمِ  مَالِكِ يَوْمِ الدِّينِ  إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ  اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ  صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    'In the name of Allah, the Most Gracious, the Most Merciful. All praise is due to Allah, Lord of the worlds - the Most Gracious, the Most Merciful, Master of the Day of Judgment. You alone we worship, and You alone we ask for help. Guide us along the Straight Path - the path of those You have blessed, not of those who earned Your anger, nor of those who went astray.',
    'اللہ کے نام سے جو بڑا مہربان نہایت رحم والا ہے۔ تمام تعریفیں اللہ کے لیے ہیں جو تمام جہانوں کا رب ہے، بڑا مہربان نہایت رحم والا، روزِ جزا کا مالک۔ ہم صرف تیری ہی عبادت کرتے ہیں اور صرف تجھ ہی سے مدد مانگتے ہیں۔ ہمیں سیدھے راستے پر چلا، ان لوگوں کے راستے پر جن پر تو نے انعام کیا، نہ ان کے جن پر تیرا غضب ہوا اور نہ گمراہوں کے راستے پر۔',
    '{"surah": 1, "topic": "Al-Fatihah"}'::jsonb
  ),
  (
    'quran',
    'Quran 2:255',
    'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَّهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَن ذَا الَّذِي يَشْفَعُ عِندَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِّنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضِ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ',
    'Allah - there is no deity except Him, the Ever-Living, the Sustainer of existence. Neither drowsiness overtakes Him nor sleep. To Him belongs whatever is in the heavens and whatever is on the earth. Who is it that can intercede with Him except by His permission? He knows what is before them and what will be after them, and they encompass not a thing of His knowledge except for what He wills. His Kursi extends over the heavens and the earth, and their preservation tires Him not. And He is the Most High, the Most Great.',
    'اللہ، اس کے سوا کوئی معبود نہیں، وہ زندہ ہے، سب کو قائم رکھنے والا ہے۔ نہ اسے اونگھ آتی ہے اور نہ نیند۔ اسی کا ہے جو کچھ آسمانوں میں ہے اور جو کچھ زمین میں ہے۔ کون ہے جو اس کی اجازت کے بغیر اس کے پاس سفارش کر سکے؟ وہ جانتا ہے جو ان کے سامنے ہے اور جو ان کے پیچھے ہے، اور وہ اس کے علم میں سے کسی چیز کا احاطہ نہیں کر سکتے مگر جتنا وہ چاہے۔ اس کی کرسی آسمانوں اور زمین کو گھیرے ہوئے ہے، اور ان کی حفاظت اسے تھکاتی نہیں۔ اور وہ بلند و بالا، عظمت والا ہے۔',
    '{"surah": 2, "topic": "Ayat al-Kursi"}'::jsonb
  ),
  (
    'quran',
    'Quran 2:152',
    'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ',
    'So remember Me; I will remember you. Be grateful to Me and do not deny Me.',
    'پس تم مجھے یاد کرو، میں تمہیں یاد کروں گا، اور میرا شکر ادا کرو اور میری ناشکری نہ کرو۔',
    '{"surah": 2, "topic": "Remembrance of Allah"}'::jsonb
  ),
  (
    'quran',
    'Quran 2:286',
    'لَا يُكَلِّفُ اللَّهُ نَفْسًا إِلَّا وُسْعَهَا ۚ لَهَا مَا كَسَبَتْ وَعَلَيْهَا مَا اكْتَسَبَتْ ۗ رَبَّنَا لَا تُؤَاخِذْنَا إِن نَّسِينَا أَوْ أَخْطَأْنَا ۚ رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِن قَبْلِنَا ۚ رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ ۖ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا ۚ أَنتَ مَوْلَانَا فَانصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ',
    'Allah does not burden a soul beyond that it can bear. It will have the consequence of what good it has gained, and it will bear the consequence of what evil it has earned. Our Lord, do not impose blame upon us if we have forgotten or erred. Our Lord, and lay not upon us a burden like that which You laid upon those before us. Our Lord, and burden us not with that which we have no ability to bear. And pardon us; and forgive us; and have mercy upon us. You are our protector, so give us victory over the disbelieving people.',
    'اللہ کسی جان کو اس کی طاقت سے زیادہ بوجھ نہیں ڈالتا۔ اسے ملے گا جو اس نے کمایا اور اس پر ہوگا جو اس نے برا کمایا۔ اے ہمارے رب! اگر ہم بھول جائیں یا غلطی کریں تو ہماری پکڑ نہ کر۔ اے ہمارے رب! ہم پر وہ بوجھ نہ ڈال جیسا تو نے ہم سے پہلوں پر ڈالا تھا۔ اے ہمارے رب! ہم پر وہ بوجھ نہ ڈال جس کی ہمیں طاقت نہیں۔ اور ہمیں معاف کر، ہمیں بخش دے، ہم پر رحم کر۔ تو ہمارا مولا ہے، پس کافر قوم پر ہمیں فتح عطا فرما۔',
    '{"surah": 2, "topic": "Ease in religion"}'::jsonb
  ),
  (
    'quran',
    'Quran 2:153',
    'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ ۚ إِنَّ اللَّهَ مَعَ الصَّابِرِينَ',
    'O you who have believed, seek help through patience and prayer. Indeed, Allah is with the patient.',
    'اے ایمان والو! صبر اور نماز سے مدد مانگو۔ بے شک اللہ صبر کرنے والوں کے ساتھ ہے۔',
    '{"surah": 2, "topic": "Patience and prayer"}'::jsonb
  ),
  (
    'quran',
    'Quran 13:28',
    'الَّذِينَ آمَنُوا وَتَطْمَئِنُّ قُلُوبُهُم بِذِكْرِ اللَّهِ ۗ أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ',
    'Those who have believed and whose hearts are assured by the remembrance of Allah. Unquestionably, by the remembrance of Allah hearts are assured.',
    'جو ایمان لائے اور جن کے دل اللہ کے ذکر سے مطمئن ہوتے ہیں۔ خبردار! اللہ کے ذکر ہی سے دل مطمئن ہوتے ہیں۔',
    '{"surah": 13, "topic": "Peace of heart"}'::jsonb
  ),
  (
    'quran',
    'Quran 39:53',
    'قُلْ يَا عِبَادِيَ الَّذِينَ أَسْرَفُوا عَلَىٰ أَنفُسِهِمْ لَا تَقْنَطُوا مِن رَّحْمَةِ اللَّهِ ۚ إِنَّ اللَّهَ يَغْفِرُ الذُّنُوبَ جَمِيعًا ۚ إِنَّهُ هُوَ الْغَفُورُ الرَّحِيمُ',
    'Say, "O My servants who have transgressed against themselves [by sinning], do not despair of the mercy of Allah. Indeed, Allah forgives all sins. Indeed, it is He who is the Forgiving, the Merciful."',
    'کہہ دیجئے: اے میرے بندو جنہوں نے اپنی جانوں پر زیادتی کی ہے، اللہ کی رحمت سے مایوس نہ ہو۔ بے شک اللہ تمام گناہ معاف کر دیتا ہے۔ بے شک وہی بخشنے والا، رحم کرنے والا ہے۔',
    '{"surah": 39, "topic": "Hope and repentance"}'::jsonb
  ),
  (
    'quran',
    'Quran 65:3',
    'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ ۚ إِنَّ اللَّهَ بَالِغُ أَمْرِهِ ۚ قَدْ جَعَلَ اللَّهُ لِكُلِّ شَيْءٍ قَدْرًا',
    'And whoever relies upon Allah - then He is sufficient for him. Indeed, Allah will accomplish His purpose. Allah has already set for everything a [decreed] extent.',
    'اور جو اللہ پر توکل کرے تو وہ اس کے لیے کافی ہے۔ بے شک اللہ اپنا کام پورا کرنے والا ہے۔ اللہ نے ہر چیز کے لیے ایک اندازہ مقرر کر رکھا ہے۔',
    '{"surah": 65, "topic": "Tawakkul"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih Muslim 2723',
    'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'We have entered the morning and with it all dominion belongs to Allah, praise be to Allah. None has the right to be worshipped but Allah alone, without partner. To Him belongs dominion and to Him belongs praise, and He is over all things competent.',
    'ہم نے صبح کی اور بادشاہی اللہ کے لیے ہے، اور تمام تعریفیں اللہ کے لیے ہیں۔ اللہ کے سوا کوئی معبود نہیں، وہ اکیلا ہے، اس کا کوئی شریک نہیں، اسی کی بادشاہی ہے اور اسی کے لیے حمد ہے، اور وہ ہر چیز پر قادر ہے۔',
    '{"category": "Morning & Evening Adhkar"}'::jsonb
  ),
  (
    'duas_hisnul_muslim',
    'Sahih al-Bukhari 834',
    'اللَّهُمَّ إِنِّي ظَلَمْتُ نَفْسِي ظُلْمًا كَثِيرًا، وَلَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ، فَاغْفِرْ لِي مَغْفِرَةً مِنْ عِنْدِكَ، وَارْحَمْنِي إِنَّكَ أَنْتَ الْغَفُورُ الرَّحِيمُ',
    'O Allah, I have wronged myself greatly, and none forgives sins except You. So forgive me with a forgiveness from You, and have mercy on me. Indeed, You are the Forgiving, the Merciful.',
    'اے اللہ! میں نے اپنی جان پر بہت ظلم کیا، اور تیرے سوا کوئی گناہ معاف نہیں کرتا، پس مجھے اپنی طرف سے بخشش عطا فرما، اور مجھ پر رحم کر۔ بے شک تو ہی بخشنے والا، رحم کرنے والا ہے۔',
    '{"category": "Seeking Forgiveness"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih Muslim 752',
    'صَلَاةُ اللَّيْلِ مَثْنَى مَثْنَى، فَإِذَا خَشِيَ أَحَدُكُمُ الصُّبْحَ صَلَّى رَكْعَةً وَاحِدَةً تُوتِرُ لَهُ مَا قَدْ صَلَّى',
    'Witr is prayed in odd numbers (1, 3, 5 or more rakats). The night prayer is prayed two by two, then one rakah of witr at the end [Sahih Muslim 752]. Madhab practice differs: Hanafi - 3 rakats prayed as wajib in one specific form; Shafi''i/Maliki/Hanbali - minimum 1 rakah, up to 11, in the two-by-two form.',
    'وتر طاق عدد میں پڑھی جاتی ہے (1، 3، 5 یا زیادہ رکعات)۔ رات کی نماز دو دو رکعت کر کے پڑھی جاتی ہے، پھر آخر میں ایک رکعت وتر [Sahih Muslim 752]۔ فقہی عمل میں فرق: حنفی - 3 رکعت واجب کی ایک مخصوص صورت میں؛ شافعی/مالکی/حنبلی - کم از کم 1 رکعت، زیادہ سے زیادہ 11، دو دو رکعت کی صورت میں۔',
    '{"category": "Fiqh Differences", "topic": "Witr"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih Muslim 571',
    'إِذَا شَكَّ أَحَدُكُمْ فِي صَلَاتِهِ فَلَمْ يَدْرِ كَمْ صَلَّى ثَلَاثًا أَمْ أَرْبَعًا فَلْيَطْرَحِ الشَّكَّ وَلْيَبْنِ عَلَى مَا اسْتَيْقَنَ ثُمَّ يَسْجُدُ سَجْدَتَيْنِ قَبْلَ أَنْ يُسَلِّمَ',
    'If you are unsure in prayer whether you prayed 3 or 4 rakats, build on what you are certain of, then perform two prostrations of forgetfulness (sujud al-sahw) before the salam [Sahih Muslim 571].',
    'اگر نماز میں شک ہو کہ 3 رکعت پڑھی ہیں یا 4، تو جس پر یقین ہو اسی پر بنیاد رکھیں، پھر سلام سے پہلے سہو کے دو سجدے کریں [Sahih Muslim 571]۔',
    '{"category": "Prayer Practice", "topic": "Sujud al-Sahw"}'::jsonb
  ),
  (
    'faqs_corpus',
    'Sahih Muslim 1162; Jami at-Tirmidhi 747',
    'ذَاكَ يَوْمٌ وُلِدْتُ فِيهِ، وَيَوْمٌ بُعِثْتُ أَوْ أُنْزِلَ عَلَيَّ فِيهِ',
    'Fasting Mondays: the Prophet (pbuh) fasted on Mondays, saying "that is the day I was born and the day revelation was sent down to me" [Sahih Muslim 1162]. Deeds are presented to Allah on Mondays and Thursdays [Jami'' at-Tirmidhi 747], which is why fasting those days is recommended.',
    'پیر کے روزے: رسول اللہ ﷺ پیر کو روزہ رکھتے تھے، فرمایا: "یہ وہ دن ہے جس میں میں پیدا ہوا اور جس میں مجھ پر وحی نازل ہوئی" [Sahih Muslim 1162]۔ اعمال پیر اور جمعرات کو اللہ کے سامنے پیش کیے جاتے ہیں [Jami at-Tirmidhi 747]، اس لیے ان دنوں روزہ رکھنا مستحب ہے۔',
    '{"category": "Fasting", "topic": "Monday and Thursday fasts"}'::jsonb
  );
