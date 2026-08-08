import 'package:ascend/core/models/stat_kind.dart';
import 'package:flutter/foundation.dart';

/// One entry of the character's progress history. Kept so the Progress
/// Timeline (a later milestone) can render what happened and when, and so
/// duplicate events stay detectable.
@immutable
final class CharacterHistoryRecord {
  const CharacterHistoryRecord({
    required this.missionId,
    required this.missionTitle,
    required this.awardedAt,
    required this.xp,
    this.statGains = const <StatGain>[],
  });

  factory CharacterHistoryRecord.fromJson(Map<String, Object?> json) =>
      CharacterHistoryRecord(
        missionId: json['missionId'] as String,
        missionTitle: json['missionTitle'] as String,
        awardedAt: DateTime.fromMillisecondsSinceEpoch(
          json['awardedAt'] as int,
        ),
        xp: json['xp'] as int,
        statGains: _statGains(json['statGains']),
      );

  static List<StatGain> _statGains(Object? raw) {
    if (raw is! List) {
      return const <StatGain>[];
    }
    final gains = <StatGain>[];
    for (final entry in raw) {
      if (entry is! Map) {
        continue;
      }
      StatKind? kind;
      for (final candidate in StatKind.values) {
        if (candidate.name == entry['kind']) {
          kind = candidate;
          break;
        }
      }
      final amount = entry['amount'];
      if (kind != null && amount is int) {
        gains.add(StatGain(kind, amount));
      }
    }
    return gains;
  }

  final String missionId;
  final String missionTitle;
  final DateTime awardedAt;
  final int xp;
  final List<StatGain> statGains;

  Map<String, Object?> toJson() => <String, Object?>{
    'missionId': missionId,
    'missionTitle': missionTitle,
    'awardedAt': awardedAt.millisecondsSinceEpoch,
    'xp': xp,
    'statGains': <Object?>[
      for (final gain in statGains)
        <String, Object?>{'kind': gain.kind.name, 'amount': gain.amount},
    ],
  };
}

/// The full progress history of the character, newest entry last.
///
/// Immutable list-style collection so awarding can never double-apply: a
/// mission id appears at most once.
@immutable
class CharacterHistory {
  const CharacterHistory(this.records);

  factory CharacterHistory.fromJson(Object? json) {
    final raw = json is Map ? json['records'] : json;
    if (raw is! List) {
      return const CharacterHistory(<CharacterHistoryRecord>[]);
    }
    final records = <CharacterHistoryRecord>[];
    for (final entry in raw) {
      if (entry is Map) {
        records.add(CharacterHistoryRecord.fromJson(<String, Object?>{
          for (final key in entry.keys) key as String: entry[key],
        }));
      }
    }
    return CharacterHistory(records);
  }

  /// Hard cap so a very long career cannot bloat storage. The newest
  /// records survive; old ones are trimmed once the cap is exceeded.
  static const int maxRecords = 1000;

  final List<CharacterHistoryRecord> records;

  bool contains(String missionId) =>
      records.any((record) => record.missionId == missionId);

  /// Appends [record], trimming the oldest once [maxRecords] is exceeded.
  CharacterHistory append(CharacterHistoryRecord record) {
    final next = <CharacterHistoryRecord>[...records, record];
    if (next.length > maxRecords) {
      next.removeRange(0, next.length - maxRecords);
    }
    return CharacterHistory(next);
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'records': <Object?>[
      for (final record in records) record.toJson(),
    ],
  };
}