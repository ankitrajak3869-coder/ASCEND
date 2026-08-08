import 'package:flutter/foundation.dart';

/// The player avatar: identity plus progression counters.
@immutable
final class CharacterProfile {
  const CharacterProfile({
    required this.name,
    required this.level,
    required this.xp,
    required this.joinedAt,
  });

  factory CharacterProfile.fromJson(Map<String, Object?> json) =>
      CharacterProfile(
        name: json['name'] as String,
        level: json['level'] as int,
        xp: json['xp'] as int,
        joinedAt: DateTime.fromMillisecondsSinceEpoch(
          json['joinedAt'] as int,
        ),
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
  final int xp;
  final DateTime joinedAt;

  CharacterProfile copyWith({String? name, int? level, int? xp}) {
    return CharacterProfile(
      name: name ?? this.name,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      joinedAt: joinedAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'level': level,
    'xp': xp,
    'joinedAt': joinedAt.millisecondsSinceEpoch,
  };

  @override
  String toString() => 'CharacterProfile($name, level $level, $xp xp)';
}