import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:flutter/foundation.dart';

/// Immutable snapshot of the boss encounter.
@immutable
final class BossModel {
  const BossModel({
    required this.phase,
    required this.health,
    required this.maxHealth,
    required this.strikes,
    required this.combo,
    required this.lastStruckKey,
  });

  factory BossModel.fromJson(Map<String, Object?> json) => BossModel(
    phase: _phase(json['phase']),
    health: json['health'] as int,
    maxHealth: json['maxHealth'] as int,
    strikes: json['strikes'] as int,
    combo: json['combo'] as int,
    lastStruckKey: json['lastStruckKey'] as String?,
  );

  /// A brand-new boss encounter, dormant at full health.
  factory BossModel.fresh() => const BossModel(
    phase: BossPhase.dormant,
    health: BossRules.maxHealth,
    maxHealth: BossRules.maxHealth,
    strikes: 0,
    combo: 0,
    lastStruckKey: null,
  );

  final BossPhase phase;
  final int health;
  final int maxHealth;
  final int strikes;
  final int combo;

  /// Day key of the player's most recent strike (see [DayKey]).
  final String? lastStruckKey;

  bool get isDefeated => phase == BossPhase.defeated;

  double get healthRatio => maxHealth <= 0 ? 0 : health / maxHealth;

  BossModel copyWith({
    BossPhase? phase,
    int? health,
    int? strikes,
    int? combo,
    String? lastStruckKey,
    bool clearStruckKey = false,
  }) {
    return BossModel(
      phase: phase ?? this.phase,
      health: health ?? this.health,
      maxHealth: maxHealth,
      strikes: strikes ?? this.strikes,
      combo: combo ?? this.combo,
      lastStruckKey: clearStruckKey ? null : (lastStruckKey ?? this.lastStruckKey),
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'phase': phase.name,
    'health': health,
    'maxHealth': maxHealth,
    'strikes': strikes,
    'combo': combo,
    'lastStruckKey': lastStruckKey,
  };

  @override
  String toString() =>
      'BossModel(${phase.name}, $health/$maxHealth, combo $combo)';
}

BossPhase _phase(Object? raw) {
  for (final phase in BossPhase.values) {
    if (phase.name == raw) {
      return phase;
    }
  }
  return BossPhase.dormant;
}