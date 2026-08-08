/// Character domain: level rules, stats and deterministic progression.
library;

import 'dart:math' as math;

import 'package:ascend/core/models/stat_kind.dart';

/// Deterministic level thresholds: a configurable ascending list of
/// cumulative XP boundaries (not hardcoded in UI). Level is always derived
/// from total XP, so storage never trusts a stale level.
final class LevelRules {
  const LevelRules({required this.levelUpThresholds, this.startingLevel = 1});

  /// The default, tuned curve used by the app: 0–999 XP → level 1,
  /// 1000–2499 → level 2, 2500–4999 → level 3 and so on, slower as you rise.
  static const LevelRules live = LevelRules(
    levelUpThresholds: <int>[
      1000, 2500, 5000, 8000, 12000, 18000, 26000, 36000, 48000, 64000,
    ],
  );

  /// Cumulative XP at which each level-up happens (ascending).
  final List<int> levelUpThresholds;

  /// The level before any XP has been earned.
  final int startingLevel;

  /// The level a player with [totalXp] belongs to. Deterministic and cheap —
  /// a pure function of the thresholds, recomputable on every save.
  int levelAt(int totalXp) {
    var level = startingLevel;
    for (final threshold in levelUpThresholds) {
      if (totalXp < threshold) {
        break;
      }
      level += 1;
    }
    return level;
  }

  /// XP already earned inside [totalXp]'s current level.
  int xpIntoLevel(int totalXp) {
    var base = 0;
    for (final threshold in levelUpThresholds) {
      if (totalXp < threshold) {
        break;
      }
      base = threshold;
    }
    return totalXp - base;
  }
}

/// Immutable snapshot of the character's seven stats.
///
/// Zero-valued stats are absent from the map. Building on a map keeps the
/// model trivially extensible when `StatKind` grows.
final class CharacterStats {
  /// Public only via default values and factories; the map is never mutated
  /// after construction (all mutations go through [apply]).
  const CharacterStats(this._values);

  /// All-zero stats for a new adventurer.
  factory CharacterStats.fresh() => const CharacterStats(<StatKind, int>{});

  final Map<StatKind, int> _values;

  /// Current value of [kind] (0 when untouched).
  int valueOf(StatKind kind) => _values[kind] ?? 0;

  /// Unmodifiable snapshot of the underlying values.
  Map<StatKind, int> get values => Map<StatKind, int>.unmodifiable(_values);

  /// Applies [gains], clamping at zero. Deterministic: same input, same
  /// output, no ordering dependence.
  CharacterStats apply(Iterable<StatGain> gains) {
    final next = Map<StatKind, int>.of(_values);
    for (final gain in gains) {
      final current = next[gain.kind] ?? 0;
      next[gain.kind] = math.max(0, current + gain.amount);
    }
    return CharacterStats(next);
  }

  factory CharacterStats.fromJson(Object? json) {
    if (json is! Map) {
      return CharacterStats.fresh();
    }
    final values = <StatKind, int>{};
    for (final kind in StatKind.values) {
      final raw = json[kind.name];
      if (raw is int) {
        values[kind] = raw;
      }
    }
    return CharacterStats(values);
  }

  Map<String, Object?> toJson() => <String, Object?>{
    for (final entry in _values.entries) entry.key.name: entry.value,
  };
}