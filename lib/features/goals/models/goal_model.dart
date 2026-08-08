import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/models/milestone_model.dart';
import 'package:flutter/foundation.dart';

/// An immutable life goal with 0..1 progress and a deterministic milestone
/// plan.
@immutable
final class GoalModel {
  const GoalModel({
    required this.id,
    required this.title,
    required this.createdAt,
    this.status = GoalStatus.active,
    this.progress = GoalRules.minProgress,
    this.milestones = const <GoalMilestone>[],
  });

  factory GoalModel.fromJson(Map<String, Object?> json) => GoalModel(
    id: json['id'] as String,
    title: json['title'] as String,
    status: _status(json['status']),
    progress: (json['progress'] as num).toDouble(),
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    milestones: (json['milestones'] as List<Object?>?)
        ?.cast<Map<String, Object?>>()
        .map(GoalMilestone.fromJson)
        .toList() ??
        const <GoalMilestone>[],
  );

  final String id;
  final String title;
  final GoalStatus status;
  final double progress;
  final DateTime createdAt;
  final List<GoalMilestone> milestones;

  bool get isDone => status == GoalStatus.done;

  int get doneMilestones => milestones.where((ms) => ms.isDone).length;

  bool get isFullyPlanned =>
      milestones.isNotEmpty && doneMilestones == milestones.length;

  GoalModel copyWith({
    String? id,
    String? title,
    GoalStatus? status,
    double? progress,
    DateTime? createdAt,
    List<GoalMilestone>? milestones,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      milestones: milestones ?? this.milestones,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'title': title,
    'status': status.name,
    'progress': progress,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'milestones': milestones.map((ms) => ms.toJson()).toList(),
  };

  @override
  String toString() =>
      'GoalModel($id, ${status.name}, ${progress.toStringAsFixed(1)})';
}

GoalStatus _status(Object? raw) {
  for (final status in GoalStatus.values) {
    if (status.name == raw) {
      return status;
    }
  }
  return GoalStatus.active;
}