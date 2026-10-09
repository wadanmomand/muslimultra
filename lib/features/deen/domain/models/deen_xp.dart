import 'package:flutter/foundation.dart';

/// Available Deen spiritual growth levels
enum DeenLevel {
  beginner(0, 'Beginner', 100),
  learner(100, 'Learner', 250),
  practitioner(250, 'Practitioner', 500),
  devoted(500, 'Devoted', 1000),
  steadfast(1000, 'Steadfast', 2000),
  exemplar(2000, 'Exemplar', null);

  final int minXp;
  final String title;
  final int? nextLevelMinXp;

  const DeenLevel(this.minXp, this.title, this.nextLevelMinXp);

  /// Computes the current level for a given total XP
  static DeenLevel levelFor(int xp) {
    if (xp >= 2000) return DeenLevel.exemplar;
    if (xp >= 1000) return DeenLevel.steadfast;
    if (xp >= 500) return DeenLevel.devoted;
    if (xp >= 250) return DeenLevel.practitioner;
    if (xp >= 100) return DeenLevel.learner;
    return DeenLevel.beginner;
  }

  /// Returns XP required to reach next level from current level baseline
  int get xpSpanForLevel {
    if (nextLevelMinXp == null) return 1000; // Cap for max level
    return nextLevelMinXp! - minXp;
  }

  /// Calculates progress fraction (0.0 to 1.0) towards next level
  double progressFraction(int totalXp) {
    if (nextLevelMinXp == null) return 1.0;
    final currentProgress = (totalXp - minXp).clamp(0, xpSpanForLevel);
    return currentProgress / xpSpanForLevel;
  }

  /// Returns remaining XP needed to level up
  int remainingXpToNext(int totalXp) {
    if (nextLevelMinXp == null) return 0;
    final needed = nextLevelMinXp! - totalXp;
    return needed > 0 ? needed : 0;
  }

  /// Returns the next DeenLevel or null if already max level
  DeenLevel? get nextLevel {
    switch (this) {
      case DeenLevel.beginner:
        return DeenLevel.learner;
      case DeenLevel.learner:
        return DeenLevel.practitioner;
      case DeenLevel.practitioner:
        return DeenLevel.devoted;
      case DeenLevel.devoted:
        return DeenLevel.steadfast;
      case DeenLevel.steadfast:
        return DeenLevel.exemplar;
      case DeenLevel.exemplar:
        return null;
    }
  }
}

/// Represents the user's current XP and level state
@immutable
class DeenXp {
  final int totalXp;

  const DeenXp({this.totalXp = 0});

  DeenLevel get level => DeenLevel.levelFor(totalXp);
  double get progressFraction => level.progressFraction(totalXp);
  int get remainingToNext => level.remainingXpToNext(totalXp);

  factory DeenXp.fromJson(Map<String, dynamic> json) {
    return DeenXp(
      totalXp: (json['totalXp'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalXp': totalXp,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeenXp && runtimeType == other.runtimeType && totalXp == other.totalXp;

  @override
  int get hashCode => totalXp.hashCode;

  @override
  String toString() => 'DeenXp(totalXp: $totalXp, level: ${level.title})';
}
