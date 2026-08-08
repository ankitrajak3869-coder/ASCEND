import 'package:ascend/features/achievements/domain/achievement_domain.dart';
import 'package:flutter/foundation.dart';

/// An immutable achievement trophy with clamped 0..target progress.
@immutable
final class AchievementModel {
  const AchievementModel({
    required this.id,
    required this.title,
    required this.description,
    required this.kind,
    required this.target,
    this.current = AchievementRules.minProgress,
    this.unlockedAt,
  });

  factory AchievementModel.fromJson(Map<String, Object?> json) =>
      AchievementModel(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        kind: _kind(json['kind']),
        target: (json['target'] as num).toInt(),
        current: (json['current'] as num?)?.toInt() ??
            AchievementRules.minProgress,
        unlockedAt: json['unlockedAt'] == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(json['unlockedAt'] as int),
      );

  final String id;
  final String title;
  final String description;
  final AchievementKind kind;
  final int target;
  final int current;
  final DateTime? unlockedAt;

  bool get isUnlocked =>
      unlockedAt != null || current >= target;

  double get progress => (current / target).clamp(0, 1);

  AchievementModel copyWith({
    String? id,
    String? title,
    String? description,
    AchievementKind? kind,
    int? target,
    int? current,
    DateTime? unlockedAt,
  }) {
    return AchievementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      kind: kind ?? this.kind,
      target: target ?? this.target,
      current: current ?? this.current,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'description': description,
    'kind': kind.name,
    'target': target,
    'current': current,
    'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
  };

  @override
  String toString() => 'AchievementModel($id, $current/$target)';
}

AchievementKind _kind(Object? raw) {
  for (final kind in AchievementKind.values) {
    if (kind.name == raw) {
      return kind;
    }
  }
  return AchievementKind.missionsCompleted;
}