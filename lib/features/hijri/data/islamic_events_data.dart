import 'package:muslim_ultra/features/hijri/domain/models/hijri_event.dart';

/// Islamic events dataset and date rule matchers
class IslamicEventsData {
  static const List<HijriEvent> predefinedEvents = [
    // 1 Muharram
    HijriEvent(
      id: 'islamic_new_year',
      hijriMonth: 1,
      hijriDay: 1,
      nameEn: 'Islamic New Year',
      nameAr: 'رأس السنة الهجرية',
      nameUr: 'اسلامی نیا سال',
      descriptionEn: 'First day of the Hijri year and the sacred month of Muharram.',
      descriptionAr: 'بداية السنة الهجرية الجديدة وشهر محرم الحرام المبارك.',
      descriptionUr: 'نئے اسلامی سال اور حرمت والے مہینے محرم کا بابرکت آغاز۔',
      isMajor: true,
    ),

    // 10 Muharram
    HijriEvent(
      id: 'day_of_ashura',
      hijriMonth: 1,
      hijriDay: 10,
      nameEn: 'Day of Ashura',
      nameAr: 'يوم عاشوراء',
      nameUr: 'یوم عاشورہ',
      descriptionEn: 'A sacred day of voluntary fasting, commemorating Prophet Musa (AS) being saved.',
      descriptionAr: 'يوم مبارك يُسن صيامه، وفيه نجّى الله تعالى نبيّه موسى عليه السلام.',
      descriptionUr: 'مبارک دن اور سنت روزہ، جس میں اللہ تعالیٰ نے حضرت موسیٰ علیہ السلام کو نجات عطا فرمائی۔',
      isMajor: true,
    ),

    // 12 Rabi al-Awwal
    HijriEvent(
      id: 'mawlid_an_nabi',
      hijriMonth: 3,
      hijriDay: 12,
      nameEn: 'Mawlid an-Nabi ﷺ',
      nameAr: 'المولد النبوي الشريف ﷺ',
      nameUr: 'میلاد النبی ﷺ',
      descriptionEn: 'Birth of Prophet Muhammad ﷺ, sent as a mercy to all creation.',
      descriptionAr: 'ذكرى مولد خاتم الأنبياء والمرسلين وسيد الخلق نبينا محمد ﷺ.',
      descriptionUr: 'رحمت للعالمین اور خاتم النبیین حضرت محمد مصطفیٰ ﷺ کی ولادت باسعادت۔',
      isMajor: true,
    ),

    // 27 Rajab
    HijriEvent(
      id: 'isra_wal_miraj',
      hijriMonth: 7,
      hijriDay: 27,
      nameEn: 'Isra wal-Mi\'raj',
      nameAr: 'الإسراء والمعراج',
      nameUr: 'شب معراج',
      descriptionEn: 'The miraculous night journey and ascension of Prophet Muhammad ﷺ to the heavens.',
      descriptionAr: 'ذكرى الإسراء من المسجد الحرام إلى المسجد الأقصى والمعراج إلى السماوات العلى.',
      descriptionUr: 'نبی کریم ﷺ کا مسجد حرام سے مسجد اقصیٰ اور آسمانوں کا معجزاتی سفر۔',
      isMajor: true,
    ),

    // 15 Sha'ban
    HijriEvent(
      id: 'shab_e_barat',
      hijriMonth: 8,
      hijriDay: 15,
      nameEn: 'Shab-e-Barat (Laylat al-Bara\'ah)',
      nameAr: 'ليلة البراءة (نصف شعبان)',
      nameUr: 'شب برات (لیلتہ البراءۃ)',
      descriptionEn: 'The 15th night of Sha\'ban, observed for worship, prayer, and seeking divine forgiveness.',
      descriptionAr: 'ليلة النصف من شعبان المباركة، ليلة يستحب فيها الدعاء والاستغفار وقيام الليل.',
      descriptionUr: 'پندرہویں شعبان کی مبارک رات، جس میں مغفرت، دعا اور شب بیداری کی خاص فضیلت ہے۔',
      isMajor: true,
    ),

    // 1 Ramadan
    HijriEvent(
      id: 'start_of_ramadan',
      hijriMonth: 9,
      hijriDay: 1,
      nameEn: 'Start of Ramadan',
      nameAr: 'بداية شهر رمضان المبارك',
      nameUr: 'آغاز رمضان المبارک',
      descriptionEn: 'First day of the holy month of fasting, Qur\'an revelation, and spiritual renewal.',
      descriptionAr: 'أول أيام شهر رمضان المبارك، شهر الصيام والقرآن والرحمة والمغفرة والعتق من النيران.',
      descriptionUr: 'ماہ صیام، نزول قرآن، رحمت اور بخشش کے مقدس مہینے کا پہلا دن۔',
      isMajor: true,
    ),

    // Laylat al-Qadr (Last 10 odd nights)
    HijriEvent(
      id: 'laylat_al_qadr_21',
      hijriMonth: 9,
      hijriDay: 21,
      nameEn: 'Laylat al-Qadr (21st Night)',
      nameAr: 'ليلة القدر (ليلة 21 رمضان)',
      nameUr: 'شب قدر (اکیسویں رات)',
      descriptionEn: 'One of the odd nights in the last ten days of Ramadan, sought for the Night of Decree.',
      descriptionAr: 'إحدى الليالي الوترية من العشر الأواخر من رمضان لتحري ليلة القدر.',
      descriptionUr: 'رمضان المبارک کے آخری عشرے کی طاق راتوں میں سے پہلی رات۔',
      isMajor: false,
    ),
    HijriEvent(
      id: 'laylat_al_qadr_23',
      hijriMonth: 9,
      hijriDay: 23,
      nameEn: 'Laylat al-Qadr (23rd Night)',
      nameAr: 'ليلة القدر (ليلة 23 رمضان)',
      nameUr: 'شب قدر (تیئسویں رات)',
      descriptionEn: 'One of the odd nights in the last ten days of Ramadan, sought for the Night of Decree.',
      descriptionAr: 'إحدى الليالي الوترية من العشر الأواخر من رمضان لتحري ليلة القدر.',
      descriptionUr: 'رمضان المبارک کے آخری عشرے کی دوسری مبارک طاق رات۔',
      isMajor: false,
    ),
    HijriEvent(
      id: 'laylat_al_qadr_25',
      hijriMonth: 9,
      hijriDay: 25,
      nameEn: 'Laylat al-Qadr (25th Night)',
      nameAr: 'ليلة القدر (ليلة 25 رمضان)',
      nameUr: 'شب قدر (پچیسویں رات)',
      descriptionEn: 'One of the odd nights in the last ten days of Ramadan, sought for the Night of Decree.',
      descriptionAr: 'إحدى الليالي الوترية من العشر الأواخر من رمضان لتحري ليلة القدر.',
      descriptionUr: 'رمضان المبارک کے آخری عشرے کی تیسری مبارک طاق رات۔',
      isMajor: false,
    ),
    HijriEvent(
      id: 'laylat_al_qadr_27',
      hijriMonth: 9,
      hijriDay: 27,
      nameEn: 'Laylat al-Qadr (27th Night)',
      nameAr: 'ليلة القدر (ليلة 27 رمضان)',
      nameUr: 'شب قدر (ستائیسویں رات)',
      descriptionEn: 'The Night of Decree, widely observed as better than a thousand months (Surah Al-Qadr).',
      descriptionAr: 'ليلة القدر المباركة، خير من ألف شهر، تنزل الملائكة والروح فيها بإذن ربهم.',
      descriptionUr: 'ہزار مہینوں سے افضل بابرکت رات، رحمت و برکت اور نزول قرآن کی رات۔',
      isMajor: true,
    ),
    HijriEvent(
      id: 'laylat_al_qadr_29',
      hijriMonth: 9,
      hijriDay: 29,
      nameEn: 'Laylat al-Qadr (29th Night)',
      nameAr: 'ليلة القدر (ليلة 29 رمضان)',
      nameUr: 'شب قدر (انتیسویں رات)',
      descriptionEn: 'One of the odd nights in the last ten days of Ramadan, concluding the search for Laylat al-Qadr.',
      descriptionAr: 'آخر الليالي الوترية من شهر رمضان المبارك لتحري ليلة القدر.',
      descriptionUr: 'رمضان المبارک کے آخری عشرے کی آخری طاق رات۔',
      isMajor: false,
    ),

    // 1 Shawwal
    HijriEvent(
      id: 'eid_al_fitr',
      hijriMonth: 10,
      hijriDay: 1,
      nameEn: 'Eid al-Fitr',
      nameAr: 'عيد الفطر المبارك',
      nameUr: 'عید الفطر',
      descriptionEn: 'Celebration of gratitude marking the blessed completion of Ramadan fasting.',
      descriptionAr: 'يوم الجائزة والفرح والسرور بتمام صيام شهر رمضان المبارك.',
      descriptionUr: 'رمضان المبارک کے روزوں کی تکمیل پر مسلمانوں کا جشن شکر و مسرت۔',
      isMajor: true,
    ),

    // Days of Hajj (8–13 Dhul-Hijjah)
    HijriEvent(
      id: 'day_of_tarwiyah',
      hijriMonth: 12,
      hijriDay: 8,
      nameEn: 'Day of Tarwiyah (Hajj Begins)',
      nameAr: 'يوم التروية (بداية الحج)',
      nameUr: 'یوم الترویہ (آغاز حج)',
      descriptionEn: 'Pilgrims depart for Mina, marking the official beginning of the sacred Hajj rituals.',
      descriptionAr: 'توجه الحجيج إلى مشعر منى وبدء مناسك الحج المباركة.',
      descriptionUr: 'حجاج کرام کا منیٰ روانگی کے ساتھ مناسک حج کا باقاعدہ آغاز۔',
      isMajor: false,
    ),
    HijriEvent(
      id: 'day_of_arafah',
      hijriMonth: 12,
      hijriDay: 9,
      nameEn: 'Day of Arafah',
      nameAr: 'يوم عرفة',
      nameUr: 'یوم عرفہ',
      descriptionEn: 'The supreme pillar of Hajj at Mount Arafat; fasting expiates the previous and coming year.',
      descriptionAr: 'ركن الحج الأعظم في صعيد عرفات، وصيامه لغير الحاج يكفر سنة ماضية وباقية.',
      descriptionUr: 'حج کا سب سے عظیم رکن اور نفلی روزے کا با برکت دن۔',
      isMajor: true,
    ),
    HijriEvent(
      id: 'eid_al_adha',
      hijriMonth: 12,
      hijriDay: 10,
      nameEn: 'Eid al-Adha',
      nameAr: 'عيد الأضحى المبارك',
      nameUr: 'عید الاضحیٰ',
      descriptionEn: 'Feast of Sacrifice commemorating the devotion and obedience of Prophet Ibrahim (AS).',
      descriptionAr: 'يوم النحر والتقرب إلى الله تعالى بالأضاحي وإتمام مناسك الحج الكبرى.',
      descriptionUr: 'سنت ابراہیمی کی یاد میں قربانی اور شکر گزاری کی عظیم عید۔',
      isMajor: true,
    ),
    HijriEvent(
      id: 'tashreeq_day_1',
      hijriMonth: 12,
      hijriDay: 11,
      nameEn: 'Days of Tashreeq (Day 1)',
      nameAr: 'أيام التشريق (اليوم الأول)',
      nameUr: 'ایام تشریق (پہلا دن)',
      descriptionEn: 'Days of eating, drinking, remembering Allah (dhikr), and stoning the Jamarat in Mina.',
      descriptionAr: 'أيام أكل وشرب وذكر لله تعالى وتكبير ورمي الجمرات بمنى.',
      descriptionUr: 'کھانے پینے، ذکر الٰہی اور رمی جمرات کے مبارک ایام۔',
      isMajor: false,
    ),
    HijriEvent(
      id: 'tashreeq_day_2',
      hijriMonth: 12,
      hijriDay: 12,
      nameEn: 'Days of Tashreeq (Day 2)',
      nameAr: 'أيام التشريق (اليوم الثاني)',
      nameUr: 'ایام تشریق (دوسرا دن)',
      descriptionEn: 'Continuing the sacred days of Tashreeq and Jamarat stoning in Mina.',
      descriptionAr: 'متابعة أيام التشريق المباركة ورمي الجمرات بمشعر منى.',
      descriptionUr: 'ایام تشریق کا دوسرا دن اور رمی جمرات کا تسلسل۔',
      isMajor: false,
    ),
    HijriEvent(
      id: 'tashreeq_day_3',
      hijriMonth: 12,
      hijriDay: 13,
      nameEn: 'Days of Tashreeq (Day 3)',
      nameAr: 'أيام التشريق (اليوم الثالث)',
      nameUr: 'ایام تشریق (تیسرا دن)',
      descriptionEn: 'Final day of Tashreeq concluding the Hajj pilgrimage rites in Makkah.',
      descriptionAr: 'ختام أيام التشريق ومناسك الحج المبارك وطواف الوداع.',
      descriptionUr: 'ایام تشریق کا آخری دن اور مناسک حج کی تکمیل۔',
      isMajor: false,
    ),
  ];

  /// Returns all events occurring on a specific Hijri month and day
  static List<HijriEvent> getEventsFor(int month, int day) {
    final list = <HijriEvent>[];

    // Find predefined events
    for (final event in predefinedEvents) {
      if (event.hijriMonth == month && event.hijriDay == day) {
        list.add(event);
      }
    }

    // 1st of every month is a "New Hijri Month" marker if no major holiday (e.g. not 1 Muharram / 1 Shawwal / 1 Ramadan)
    if (day == 1 && month != 1 && month != 9 && month != 10) {
      list.add(const HijriEvent(
        id: 'new_hijri_month',
        hijriMonth: 0,
        hijriDay: 1,
        nameEn: 'New Hijri Month',
        nameAr: 'غرة الشهر الهجري',
        nameUr: 'نیا اسلامی مہینہ',
        descriptionEn: 'First day of the new Islamic lunar month.',
        descriptionAr: 'بداية غرة الشهر الهجري الجديد المبارك.',
        descriptionUr: 'نئے اسلامی قمری مہینے کا پہلا دن۔',
        isMajor: false,
        isNewMonthMarker: true,
      ));
    }

    return list;
  }
}
