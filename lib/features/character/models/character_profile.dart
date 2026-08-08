import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/models/character_history.dart';
import 'package:flutter/foundation.dart';

/// The player avatar: identity, progression counters, stats and history.
@immutable
final class CharacterProfile {
  const CharacterProfile({
    required this.name,
    required this.level,
    required this.xp,
    required this.joinedAt,
    this.stats = const CharacterStats(<StatKind, int>{}),
    this.history = const CharacterHistory(<CharacterHistoryRecord>[]),
  });

  factory CharacterProfile.fromJson(Map<String, Object?> json) =>
      CharacterProfile(
        name: json['name'] as String,
        level: json['level'] as int,
        xp: json['xp'] as int,
        joinedAt: DateTime.fromMillisecondsSinceEpoch(
          json['joinedAt'] as int,
        ),
        stats: CharacterStats.fromJson(json['stats']),
        history: CharacterHistory.fromJson(json['history']),
      );

  /// A brand-new adventurer.
  factory CharacterProfile.fresh() => CharacterProfile(
    name: 'Rookie',
    level: 1,
    xp: 0,
    joinedAt: DateTime.now(),
  );

  final String name;
  final int level;

  /// Total cumulative XP; the level is always derived from it.
  final int xp;
  final DateTime joinedAt;

  /// Personal development stats (never trusted from storage — recomputed).
  final CharacterStats stats;

  /// History of every reward granted, newest last.
  final CharacterHistory history;

  CharacterProfile copyWith({
    String? name,
    int? level,
    int? xp,
    CharacterStats? stats,
    CharacterHistory? history,
  }) {
    return CharacterProfile(
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      joinedAt: joinedAt,
      stats: stats ?? this.stats,
      history: history ?? this.history,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'level': level,
    'xp': xp,
    'joinedAt': joinedAt.millisecondsSinceEpoch,
    'stats': stats.toJson(),
    'history': history.toJson(),
  };

  @override
  String toString() => 'CharacterProfile($name, level $level, $xp xp)';
}