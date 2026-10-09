class AcademyProgram {
  final String id;
  final String title;
  final String slug;
  final String description;
  final String monthlyFee;
  final String duration;
  final String scheduleFlexibility;
  final bool isActive;
  final int displayOrder;

  const AcademyProgram({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.monthlyFee,
    required this.duration,
    required this.scheduleFlexibility,
    this.isActive = true,
    this.displayOrder = 0,
  });

  factory AcademyProgram.fromJson(Map<String, dynamic> json) {
    return AcademyProgram(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
      monthlyFee: json['monthly_fee'] as String? ?? '',
      duration: json['duration'] as String? ?? '',
      scheduleFlexibility: json['schedule_flexibility'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      displayOrder: json['display_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'slug': slug,
      'description': description,
      'monthly_fee': monthlyFee,
      'duration': duration,
      'schedule_flexibility': scheduleFlexibility,
      'is_active': isActive,
      'display_order': displayOrder,
    };
  }
}
