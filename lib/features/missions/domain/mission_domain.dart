/// Missions domain: lifecycle states, kinds and hard rules.
library;

/// A mission's lifecycle.
enum MissionStatus { open, completed, skipped }

/// Mission cadence.
enum MissionKind { daily, weekly, goal }

/// Hard rules the catalog honors.
abstract final class MissionRules {
  static const int maxDaily = 3;
  static const int maxWeekly = 2;
  static const int dailyXpReward = 50;
  static const int weeklyXpReward = 200;
}

/// Raised when a mission id cannot be found in a repository.
final class MissionNotFoundException implements Exception {
  const MissionNotFoundException(this.id);

  final String id;

  @override
  String toString() => 'MissionNotFoundException($id)';
}