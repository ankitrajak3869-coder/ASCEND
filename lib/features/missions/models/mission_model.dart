import 'package:ascend/features/missions/domain/mission_domain.dart';
import 'package:flutter/foundation.dart';

/// An immutable mission instance. Serializable for local persistence.
@immutable
final class MissionModel {
  const MissionModel({
    required this.id,
    required this.kind,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.createdAt,
    this.status = MissionStatus.open,
    this.completedAt,
    this.goalId,
    this.milestoneIndex,
  });

  factory MissionModel.fromJson(Map<String, Object?> json) => MissionModel(
    id: json['id'] as String,
    kind: _kind(json['kind']),
    title: json['title'] as String,
    description: json['description'] as String,
    xpReward: json['xpReward'] as int,
    status: _status(json['status']),
    createdAt: DateTime.fromMillisecondsSinceEpoch(
      json['createdAt'] as int,
    ),
    completedAt: json['completedAt'] == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int),
    goalId: json['goalId'] as String?,
    milestoneIndex: json['milestoneIndex'] as int?,
  );

  final String id;
  final MissionKind kind;
  final String title;
  final String description;
  final int xpReward;
  final MissionStatus status;
  final DateTime createdAt;
  final DateTime? completedAt;

  /// Set when the goal engine minted this mission for a goal.
  final String? goalId;

  /// Index of the goal milestone this mission was minted for.
  final int? milestoneIndex;

  bool get isDone => status == MissionStatus.completed;

  bool get isIncomplete => !isDone;

  bool get isGoalMission => goalId != null && milestoneIndex != null;

  MissionModel copyWith({
    String? id,
    MissionKind? kind,
    String? title,
    String? description,
    int? xpReward,
    MissionStatus? status,
    DateTime? createdAt,
    DateTime? completedAt,
    String? goalId,
    int? milestoneIndex,
  }) {
    return MissionModel(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      title: title ?? this.title,
      description: description ?? this.description,
      xpReward: xpReward ?? this.xpReward,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      goalId: goalId ?? this.goalId,
      milestoneIndex: milestoneIndex ?? this.milestoneIndex,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'kind': kind.name,
    'title': title,
    'description': description,
    'xpReward': xpReward,
    'status': status.name,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'completedAt': completedAt?.millisecondsSinceEpoch,
    'goalId': goalId,
    'milestoneIndex': milestoneIndex,
  };

  @override
  String toString() => 'MissionModel($id, ${status.name})';
}

MissionKind _kind(Object? raw) {
  for (final kind in MissionKind.values) {
    if (kind.name == raw) {
      return kind;
    }
  }
  return MissionKind.daily;
}

MissionStatus _status(Object? raw) {
  for (final status in MissionStatus.values) {
    if (status.name == raw) {
      return status;
    }
  }
  return MissionStatus.open;
}