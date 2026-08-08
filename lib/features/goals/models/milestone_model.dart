import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:flutter/foundation.dart';

/// One immutable stage of a goal. Plans are generated deterministically by
/// the goal engine: a milestone is identified by its [index] within a goal.
@immutable
final class GoalMilestone {
  const GoalMilestone({
    required this.index,
    required this.title,
    this.status = MilestoneStatus.active,
  });

  factory GoalMilestone.fromJson(Map<String, Object?> json) => GoalMilestone(
    index: (json['index'] as num).toInt(),
    title: json['title'] as String,
    status: _status(json['status']),
  );

  final int index;
  final String title;
  final MilestoneStatus status;

  bool get isDone => status == MilestoneStatus.done;

  GoalMilestone copyWith({
    int? index,
    String? title,
    MilestoneStatus? status,
  }) {
    return GoalMilestone(
      index: index ?? this.index,
      title: title ?? this.title,
      status: status ?? this.status,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'index': index,
    'title': title,
    'status': status.name,
  };

  @override
  String toString() => 'GoalMilestone($index, ${status.name})';
}

MilestoneStatus _status(Object? raw) {
  for (final status in MilestoneStatus.values) {
    if (status.name == raw) {
      return status;
    }
  }
  return MilestoneStatus.active;
}