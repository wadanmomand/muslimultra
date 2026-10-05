class DuaItemModel {
  final String id;
  final String category;
  final String title;
  final String arabic;
  final String translation;
  final String? reference;

  const DuaItemModel({
    required this.id,
    required this.category,
    required this.title,
    required this.arabic,
    required this.translation,
    this.reference,
  });
}
