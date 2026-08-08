/// Boss domain: phases, stat wiring and strike math.
library;

/// Where the boss sits on the attention curve.
enum BossPhase {
  dormant,
  rumbling,
  enraged,
  defeated,
}

/// Numeric wiring for the boss encounter.
abstract final class BossRules {
  /// Starting hit points.
  static const int maxHealth = 100;

  /// Flat damage per strike.
  static const int baseDamage = 10;

  /// Bonus damage when the player brings a streak into the fight.
  static const int streakBonus = 6;

  /// Strikes below this HP push the boss into [BossPhase.enraged].
  static const int enrageThreshold = 30;
}

/// The player has no boss battle to fight.
final class BossNeverStartedException implements Exception {
  const BossNeverStartedException();

  @override
  String toString() => 'BossNeverStartedException';
}