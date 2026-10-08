/// Domain model for Dhikr presets
class DhikrPreset {
  final String id;
  final String arabic;
  final String transliteration;
  final String translationKey;
  final int defaultTarget;

  const DhikrPreset({
    required this.id,
    required this.arabic,
    required this.transliteration,
    required this.translationKey,
    required this.defaultTarget,
  });

  static const List<DhikrPreset> defaultPresets = [
    DhikrPreset(
      id: 'subhanallah',
      arabic: 'سُبْحَانَ اللَّهِ',
      transliteration: 'SubhanAllah',
      translationKey: 'dhikr_subhanallah_trans',
      defaultTarget: 33,
    ),
    DhikrPreset(
      id: 'alhamdulillah',
      arabic: 'الْحَمْدُ لِلَّهِ',
      transliteration: 'Alhamdulillah',
      translationKey: 'dhikr_alhamdulillah_trans',
      defaultTarget: 33,
    ),
    DhikrPreset(
      id: 'allahu_akbar',
      arabic: 'اللَّهُ أَكْبَرُ',
      transliteration: 'Allahu Akbar',
      translationKey: 'dhikr_allahuakbar_trans',
      defaultTarget: 34,
    ),
    DhikrPreset(
      id: 'la_ilaha_illa_allah',
      arabic: 'لَا إِلٰهَ إِلَّا اللَّهُ',
      transliteration: 'La ilaha illa Allah',
      translationKey: 'dhikr_lailahaillallah_trans',
      defaultTarget: 100,
    ),
    DhikrPreset(
      id: 'astaghfirullah',
      arabic: 'أَسْتَغْفِرُ اللَّهَ',
      transliteration: 'Astaghfirullah',
      translationKey: 'dhikr_astaghfirullah_trans',
      defaultTarget: 100,
    ),
    DhikrPreset(
      id: 'subhanallahi_wa_bihamdihi',
      arabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ',
      transliteration: 'SubhanAllahi wa bihamdihi',
      translationKey: 'dhikr_subhanallah_bihamdihi_trans',
      defaultTarget: 100,
    ),
  ];
}
