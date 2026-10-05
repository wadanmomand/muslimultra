/// Reciter configuration for EveryAyah CDN (Spec §3 M2)
class ReciterModel {
  final String id;
  final String name;
  final String subpath;
  final String bitrate;

  const ReciterModel({
    required this.id,
    required this.name,
    required this.subpath,
    required this.bitrate,
  });

  static const List<ReciterModel> availableReciters = [
    ReciterModel(
      id: 'alafasy',
      name: 'Mishary Rashid Alafasy',
      subpath: 'Alafasy_128kbps',
      bitrate: '128 kbps',
    ),
    ReciterModel(
      id: 'abdul_basit',
      name: 'Abdul Basit (Murattal)',
      subpath: 'Abdul_Basit_Murattal_192kbps',
      bitrate: '192 kbps',
    ),
    ReciterModel(
      id: 'husary',
      name: 'Mahmoud Khalil Al-Husary',
      subpath: 'Husary_128kbps',
      bitrate: '128 kbps',
    ),
    ReciterModel(
      id: 'minshawy',
      name: 'Mohamed Siddiq Al-Minshawi',
      subpath: 'Minshawy_Murattal_128kbps',
      bitrate: '128 kbps',
    ),
    ReciterModel(
      id: 'ghamadi',
      name: 'Saad Al-Ghamdi',
      subpath: 'Ghamadi_40kbps',
      bitrate: '40 kbps',
    ),
    ReciterModel(
      id: 'shatri',
      name: 'Abu Bakr Ash-Shatri',
      subpath: 'Abu_Bakr_Ash-Shatri_128kbps',
      bitrate: '128 kbps',
    ),
  ];

  static ReciterModel get defaultReciter => availableReciters[0];
}
