import 'package:ascend/core/models/stat_kind.dart';
import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/models/character_history.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CharacterStats', () {
    test('a fresh adventurer starts every stat at zero', () {
      final stats = CharacterStats.fresh();
      for (final kind in StatKind.values) {
        expect(stats.valueOf(kind), 0);
      }
    });

    test('apply accumulates the declared gains', () {
      final stats = CharacterStats.fresh().apply(const <StatGain>[
        StatGain(StatKind.strength, 3),
        StatGain(StatKind.discipline, 1),
      ]);
      expect(stats.valueOf(StatKind.strength), 3);
      expect(stats.valueOf(StatKind.discipline), 1);
      expect(stats.valueOf(StatKind.health), 0);
    });

    test('apply is deterministic regardless of gain order', () {
      const a = <StatGain>[StatGain(StatKind.health, 2), StatGain(StatKind.strength, 3)];
      const b = <StatGain>[StatGain(StatKind.strength, 3), StatGain(StatKind.health, 2)];
      final first = CharacterStats.fresh().apply(a);
      final second = CharacterStats.fresh().apply(b);
      for (final kind in StatKind.values) {
        expect(first.valueOf(kind), second.valueOf(kind));
      }
    });

    test('apply never produces negative stats', () {
      final stats = CharacterStats.fresh().apply(const <StatGain>[
        StatGain(StatKind.finance, -5),
      ]);
      expect(stats.valueOf(StatKind.finance), 0);
    });

    test('round-trips through json, unknown kinds are ignored', () {
      final stats = CharacterStats.fresh().apply(const <StatGain>[
        StatGain(StatKind.knowledge, 4),
        StatGain(StatKind.confidence, 2),
      ]);
      final decoded = CharacterStats.fromJson(
        <String, Object?>{...stats.toJson(), 'future_kind': 99},
      );
      expect(decoded.valueOf(StatKind.knowledge), 4);
      expect(decoded.valueOf(StatKind.confidence), 2);
      expect(decoded.valueOf(StatKind.finance), 0);
    });
  });

  group('LevelRules', () {
    test('live curve: 0–999 is level 1, 1000+ is level 2', () {
      expect(LevelRules.live.levelAt(0), 1);
      expect(LevelRules.live.levelAt(999), 1);
      expect(LevelRules.live.levelAt(1000), 2);
    });

    test('live curve honors every threshold boundary', () {
      expect(LevelRules.live.levelAt(2499), 2);
      expect(LevelRules.live.levelAt(2500), 3);
      expect(LevelRules.live.levelAt(4999), 3);
      expect(LevelRules.live.levelAt(5000), 4);
    });

    test('custom thresholds are honored', () {
      const rules = LevelRules(levelUpThresholds: <int>[100, 300]);
      expect(rules.levelAt(50), 1);
      expect(rules.levelAt(100), 2);
      expect(rules.levelAt(299), 2);
      expect(rules.levelAt(300), 3);
      expect(rules.levelAt(10_000), 3);
    });

    test('xpIntoLevel measures progress inside the current level', () {
      expect(LevelRules.live.xpIntoLevel(500), 500);
      expect(LevelRules.live.xpIntoLevel(1000), 0);
      expect(LevelRules.live.xpIntoLevel(1333), 333);
    });
  });

  group('CharacterHistory', () {
    CharacterHistoryRecord record(String id, {int xp = 50}) =>
        CharacterHistoryRecord(
          missionId: id,
          missionTitle: 'M-$id',
          awardedAt: DateTime(2026, 8, 3, 12),
          xp: xp,
          statGains: const <StatGain>[StatGain(StatKind.discipline, 1)],
        );

    test('detects duplicate mission ids', () {
      final history = const CharacterHistory(<CharacterHistoryRecord>[])
          .append(record('a'));
      expect(history.contains('a'), isTrue);
      expect(history.contains('b'), isFalse);
    });

    test('append keeps newest records and trims beyond the cap', () {
      var history = const CharacterHistory(<CharacterHistoryRecord>[]);
      for (var i = 0; i < CharacterHistory.maxRecords + 5; i++) {
        history = history.append(record('m-$i'));
      }
      expect(history.records.length, CharacterHistory.maxRecords);
      expect(history.contains('m-0'), isFalse, reason: 'oldest trimmed');
      expect(history.contains('m-${CharacterHistory.maxRecords + 4}'), isTrue);
    });

    test('round-trips through json with gains intact', () {
      final history = const CharacterHistory(<CharacterHistoryRecord>[])
          .append(record('a'));
      final decoded = CharacterHistory.fromJson(history.toJson());
      expect(decoded.records, hasLength(1));
      expect(decoded.records.single.missionId, 'a');
      expect(decoded.records.single.xp, 50);
      expect(decoded.records.single.statGains, hasLength(1));
      expect(
        decoded.records.single.statGains.single.kind,
        StatKind.discipline,
      );
    });

    test('tolerates payloads without a history section', () {
      expect(
        CharacterHistory.fromJson(null).records,
        isEmpty,
      );
    });
  });
}