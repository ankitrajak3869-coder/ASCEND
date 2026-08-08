/// Goals domain: lifecycle, active cap, milestones and plan rules.
library;

enum GoalStatus { active, done }

/// A milestone's lifecycle inside a goal.
enum MilestoneStatus { active, done }

/// Hard rules the goals feature honors.
abstract final class GoalRules {
  static const int maxActive = 3;

  static const double minProgress = 0;
  static const double maxProgress = 1;

  /// Every goal is decomposed into exactly this many milestones. The count
  /// is fixed so goal progress stays deterministic.
  static const int milestonesPerGoal = 3;

  /// XP granted by a milestone mission. Own constant: the goals feature
  /// must not import the missions feature.
  static const int milestoneXpReward = 60;

  /// Phase labels in unlock order (deterministic for every goal).
  static const List<String> milestonePhaseTitles = <String>[
    'Foundation',
    'Momentum',
    'Finish',
  ];
}

/// Raised when creating a goal would exceed [GoalRules.maxActive].
final class GoalQuotaReachedException implements Exception {
  const GoalQuotaReachedException(this.activeCount);

  final int activeCount;

  @override
  String toString() =>
      'GoalQuotaReachedException($activeCount active goals)';
}

/// Raised when a goal id is unknown.
final class GoalNotFoundException implements Exception {
  const GoalNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'GoalNotFoundException($id)';
}