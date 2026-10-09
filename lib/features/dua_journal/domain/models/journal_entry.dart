import 'package:flutter/foundation.dart';

@immutable
class JournalEntry {
  final String id;
  final String text;
  final DateTime createdAt;
  final DateTime? answeredAt;

  const JournalEntry({
    required this.id,
    required this.text,
    required this.createdAt,
    this.answeredAt,
  });

  bool get isAnswered => answeredAt != null;

  JournalEntry copyWith({
    String? id,
    String? text,
    DateTime? createdAt,
    DateTime? answeredAt,
    bool clearAnsweredAt = false,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      answeredAt: clearAnsweredAt ? null : (answeredAt ?? this.answeredAt),
    );
  }

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: (json['id'] as String?) ?? '',
      text: (json['text'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      answeredAt: json['answeredAt'] != null
          ? DateTime.parse(json['answeredAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'createdAt': createdAt.toIso8601String(),
      if (answeredAt != null) 'answeredAt': answeredAt!.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          text == other.text &&
          createdAt == other.createdAt &&
          answeredAt == other.answeredAt;

  @override
  int get hashCode =>
      id.hashCode ^ text.hashCode ^ createdAt.hashCode ^ answeredAt.hashCode;
}
