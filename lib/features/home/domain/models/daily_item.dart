class DailyItem {
  final String id;
  final String title;
  final bool isCompleted;

  const DailyItem({
    required this.id,
    required this.title,
    this.isCompleted = false,
  });
}
