import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/core/models/stat_kind.dart';
import 'package:ascend/core/utils/day_key.dart';
import 'package:ascend/features/missions/domain/mission_domain.dart';
import 'package:ascend/features/missions/models/mission_model.dart';
import 'package:ascend/features/missions/repositories/mission_repository.dart';
import 'package:flutter/foundation.dart';

/// A candidate mission definition used to mint daily missions.
@immutable
final class MissionTemplate {
  const MissionTemplate({
    required this.title,
    required this.description,
    required this.xpReward,
    this.statGains = const <StatGain>[],
  });

  final String title;
  final String description;
  final int xpReward;

  /// Character stats this template grows on completion.
  final List<StatGain> statGains;
}

/// Domain service: curates the day's missions and drives lifecycle changes.
///
/// The rotation is deterministic — the same local date always yields the
/// same three missions, so restarts never reshuffle the player's day.
final class MissionCatalogService {
  const MissionCatalogService({
    required this.repository,
    this.events,
    this.seeds = const <MissionSeed>[],
  });

  final MissionRepository repository;

  /// Event bus to announce completions on. Optional so callers that never
  /// want cross-feature flows (or old tests) can omit it.
  final DomainEventBus? events;

  /// Planned (goal-driven) mission requests the catalog honors. Empty by
  /// default; the app composition root injects the goal engine's seeds.
  final List<MissionSeed> seeds;

  static const List<MissionTemplate> _pool = <MissionTemplate>[
    MissionTemplate(
      title: 'Strength training',
      description: 'Twenty minutes in the ring of iron.',
      xpReward: MissionRules.dailyXpReward,
      statGains: <StatGain>[
        StatGain(StatKind.health, 2),
        StatGain(StatKind.strength, 3),
        StatGain(StatKind.discipline, 1),
      ],
    ),
    MissionTemplate(
      title: 'Deep reading',
      description: 'Ten pages of a good book.',
      xpReward: MissionRules.dailyXpReward,
      statGains: <StatGain>[
        StatGain(StatKind.knowledge, 2),
        StatGain(StatKind.discipline, 1),
      ],
    ),
    MissionTemplate(
      title: 'Hard connection',
      description: 'Call someone who matters.',
      xpReward: MissionRules.dailyXpReward,
      statGains: <StatGain>[
        StatGain(StatKind.confidence, 2),
        StatGain(StatKind.creativity, 1),
        StatGain(StatKind.discipline, 1),
      ],
    ),
    MissionTemplate(
      title: 'Zero-sugar day',
      description: 'Skip the sweets from breakfast to bed.',
      xpReward: MissionRules.dailyXpReward,
      statGains: <StatGain>[
        StatGain(StatKind.finance, 3),
        StatGain(StatKind.discipline, 1),
      ],
    ),
    MissionTemplate(
      title: 'Finish the project task',
      description: 'One real step on the plan you chose.',
      xpReward: MissionRules.dailyXpReward,
      statGains: <StatGain>[
        StatGain(StatKind.knowledge, 3),
        StatGain(StatKind.discipline, 1),
      ],
    ),
  ];

  /// Curates the missions minted for [today], creating any missing.
  ///
  /// Completed/skipped missions are kept, never re-minted.
  Future<List<MissionModel>> curatedDaily(DateTime today) async {
    final key = DayKey.dayKey(today);
    final prefix = 'mission-$key-';
    final existing = await repository.findAll();
    final todays = existing
        .where((mission) => mission.id.startsWith(prefix))
        .toList();

    if (todays.length >= MissionRules.maxDaily) {
      return todays..sort((a, b) => a.id.compareTo(b.id));
    }

    final base = today.year * 366 + _dayOfYear(today);
    final created = <MissionModel>[];
    for (var i = 0; i < MissionRules.maxDaily; i++) {
      final slot = (base + i * 2) % _pool.length;
      final template = _pool[slot];
      final id = '$prefix${i + 1}';
      if (todays.any((mission) => mission.id == id)) {
        continue;
      }
      final mission = MissionModel(
        id: id,
        kind: MissionKind.daily,
        title: template.title,
        description: template.description,
        xpReward: template.xpReward,
        statGains: template.statGains,
        createdAt: DateTime(today.year, today.month, today.day, 12),
      );
      await repository.save(mission);
      created.add(mission);
    }

    final merged = <MissionModel>[...todays, ...created]
        .take(MissionRules.maxDaily)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    return merged;
  }

  /// Mints (or returns if already stored) the mission for every [seeds]
  /// entry. Planned missions are deterministic: a seed id always maps to the
  /// same mission, so re-running never duplicates or re-rolls rewards.
  Future<List<MissionModel>> applySeeds({DateTime? now}) async {
    final existing = await repository.findAll();
    final clock = now ?? DateTime.now();
    final stamped = DateTime(clock.year, clock.month, clock.day, 12);
    final applied = <MissionModel>[];
    for (final seed in seeds) {
      MissionModel? stored;
      for (final candidate in existing) {
        if (candidate.id == seed.missionId) {
          stored = candidate;
          break;
        }
      }
      if (stored == null) {
        stored = MissionModel(
          id: seed.missionId,
          kind: MissionKind.goal,
          title: seed.title,
          description: seed.description,
          xpReward: seed.xpReward,
          createdAt: stamped,
          goalId: seed.goalId,
          milestoneIndex: seed.milestoneIndex,
        );
        await repository.save(stored);
      }
      applied.add(stored);
    }
    return applied;
  }

  /// Marks a mission completed, stamps the completion time and announces
  /// [MissionCompletedEvent] on the bus. Idempotent: a completed mission
  /// never emits twice, so rewards are granted exactly once.
  Future<void> complete(String missionId, {DateTime? now}) async {
    final mission = await repository.findById(missionId);
    if (mission.isDone) {
      return;
    }
    final stamped = now ?? DateTime.now();
    await repository.save(
      mission.copyWith(status: MissionStatus.completed, completedAt: stamped),
    );
    events?.emit(
      MissionCompletedEvent(
        missionId: mission.id,
        missionTitle: mission.title,
        xpReward: mission.xpReward,
        statGains: mission.statGains,
        isWeekly: mission.kind == MissionKind.weekly,
        completedAt: stamped,
        goalId: mission.goalId,
        milestoneIndex: mission.milestoneIndex,
      ),
    );
  }

  /// Marks skipped, but never re-mints.
  Future<void> skip(String missionId) async {
    final mission = await repository.findById(missionId);
    if (mission.isDone) {
      return;
    }
    await repository.save(mission.copyWith(status: MissionStatus.skipped));
  }

  static int _dayOfYear(DateTime date) =>
      date.difference(DateTime(date.year, 1, 1)).inDays;
}