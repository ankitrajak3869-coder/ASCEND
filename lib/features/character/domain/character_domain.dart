/// Character domain: progression curve shared by leveling and rewards.
library;

import 'dart:math' as math;

/// Determines level from cumulative XP.
///
/// XP needed for level N: `120 * N^1.35` — slow early growth, geometric
/// later. Maintained independently so storage never trusts a stale level.
abstract final class LevelCurve {

  /// XP required to advance from [level] to [level] + 1.
  static int xpForLevel(int level) =>
      (120 * math.pow(level.toDouble(), 1.35)).round();

  /// The level a player with [totalXp] belongs to.
  static int levelAt(int totalXp) {
    var level = 1;
    while (totalXp >= xpForLevel(level)) {
      totalXp -= xpForLevel(level);
      level += 1;
    }
    return level;
  }
}