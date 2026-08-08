/// Achievements domain: kinds, thresholds and seeded catalog.
library;

/// The single metric an achievement tracks.
enum AchievementKind { missionsCompleted, totalXp, bossesDefeated, goalsCompleted }

/// Hard rules the achievements feature honors.
abstract final class AchievementRules {
  /// Progress recorded past an achievement's target is clamped.
  static const int minProgress = 0;

  /// First completed mission.
  static const int firstStepTarget = 1;

  /// A quarter of the roster lived (25 missions).
  static const int weeklyRosterTarget = 25;

  /// Momentum: 500 earned XP.
  static const int xpMomentumTarget = 500;

  /// One boss laid low.
  static const int bossSlayerTarget = 1;

  /// First goal seen through completion.
  static const int firstGoalTarget = 1;

  /// A hallway of finished goals.
  static const int goalArchitectTarget = 5;
}