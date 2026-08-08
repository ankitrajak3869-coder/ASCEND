import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/missions/data/local_mission_repository.dart';
import 'package:ascend/features/missions/domain/mission_domain.dart';
import 'package:ascend/features/missions/services/mission_catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySecureStorageService storage;
  late LocalMissionRepository repository;
  final monday = DateTime(2026, 8, 3, 9);

  const seed = MissionSeed(
    missionId: 'gm-a-0',
    goalId: 'a',
    milestoneIndex: 0,
    title: 'Foundation: Write a book',
    description: 'Step 1 of Write a book.',
    xpReward: GoalRules.milestoneXpReward,
  );

  setUp(() {
    storage = InMemorySecureStorageService();
    repository = LocalMissionRepository(storage: storage);
  });

  MissionCatalogService catalog({
    List<MissionSeed> seeds = const <MissionSeed>[],
  }) {
    return MissionCatalogService(repository: repository, seeds: seeds);
  }

  group('applySeeds', () {
    test('mints goal missions with deterministic ids and payloads', () async {
      final missions = await catalog(
        seeds: const <MissionSeed>[seed],
      ).applySeeds(now: monday);

      expect(missions, hasLength(1));
      final mission = missions.single;
      expect(mission.id, 'gm-a-0');
      expect(mission.kind, MissionKind.goal);
      expect(mission.goalId, 'a');
      expect(mission.milestoneIndex, 0);
      expect(mission.xpReward, GoalRules.milestoneXpReward);
    });

    test('re-running the seed never duplicates missions', () async {
      final service = catalog(seeds: const <MissionSeed>[seed]);
      await service.applySeeds(now: monday);
      await service.applySeeds(now: monday);

      expect(await repository.findAll(), hasLength(1));
    });

    test('goal missions survive repository reloads', () async {
      await catalog(seeds: const <MissionSeed>[seed]).applySeeds(now: monday);

      final reloaded = LocalMissionRepository(storage: storage);
      final missions = await reloaded.findAll();

      expect(missions.single.goalId, 'a');
      expect(missions.single.isGoalMission, isTrue);
    });
  });

  group('complete', () {
    test('carries the goal fields on the event', () async {
      final bus = DomainEventBus();
      final events = <MissionCompletedEvent>[];
      bus.events().listen((event) {
        if (event is MissionCompletedEvent) {
          events.add(event);
        }
      });
      final service = MissionCatalogService(
        repository: repository,
        events: bus,
        seeds: const <MissionSeed>[seed],
      );

      await service.applySeeds(now: monday);
      await service.complete('gm-a-0', now: monday);

      expect(events, hasLength(1));
      final event = events.single;
      expect(event.goalId, 'a');
      expect(event.milestoneIndex, 0);
      expect(event.xpReward, GoalRules.milestoneXpReward);
    });
  });
}