class BookProgress {
  final String bookId;
  final int lastPage;
  final int totalPages;
  final DateTime lastReadAt;

  const BookProgress({
    required this.bookId,
    required this.lastPage,
    required this.totalPages,
    required this.lastReadAt,
  });

  factory BookProgress.fromJson(Map<String, dynamic> json) {
    return BookProgress(
      bookId: json['book_id'] as String? ?? '',
      lastPage: (json['last_page'] as num?)?.toInt() ?? 1,
      totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
      lastReadAt: json['last_read_at'] != null
          ? DateTime.tryParse(json['last_read_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'last_page': lastPage,
      'total_pages': totalPages,
      'last_read_at': lastReadAt.toIso8601String(),
    };
  }
}
