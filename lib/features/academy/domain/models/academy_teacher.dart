class AcademyTeacher {
  final String id;
  final String name;
  final String qualification;
  final String experience;
  final String photoUrl;
  final String bio;
  final bool isActive;
  final int displayOrder;

  const AcademyTeacher({
    required this.id,
    required this.name,
    required this.qualification,
    required this.experience,
    required this.photoUrl,
    required this.bio,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory AcademyTeacher.fromJson(Map<String, dynamic> json) {
    final rawPhoto = json['photo_url'] as String? ?? '';
    final formattedPhoto = rawPhoto.startsWith('http')
        ? rawPhoto
        : (rawPhoto.isNotEmpty ? 'https://muslimultra-website.vercel.app/$rawPhoto' : '');

    return AcademyTeacher(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      qualification: json['qualification'] as String? ?? '',
      experience: json['experience'] as String? ?? '',
      photoUrl: formattedPhoto,
      bio: json['bio'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'qualification': qualification,
      'experience': experience,
      'photo_url': photoUrl,
      'bio': bio,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }

  /// Initial letter for fallback avatar
  String get initial {
    final clean = name.replaceAll(RegExp(r'^(Qari|Ustadh|Ustadha|Sheikh|Hafiz)\s+', caseSensitive: false), '').trim();
    if (clean.isNotEmpty) {
      return clean[0].toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'T';
  }
}
