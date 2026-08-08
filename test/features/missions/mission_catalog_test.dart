import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/missions/data/local_mission_repository.dart';
import 'package:ascend/features/missions/domain/mission_domain.dart';
import 'package:ascend/features/missions/services/mission_catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySecureStorageService storage;
  late LocalMissionRepository repository;
  late MissionCatalogService service;
  final monday = DateTime(2026, 8, 3, 9, 30);

  setUp(() {
    storage = InMemorySecureStorageService();
    repository = LocalMissionRepository(storage: storage);
    service = MissionCatalogService(repository: repository);
  });

  group('curatedDaily', () {
    test('mints exactly maxDaily missions for a fresh day', () async {
      final missions = await service.curatedDaily(monday);

      expect(missions, hasLength(MissionRules.maxDaily));
      expect(missions.every((m) => m.kind == MissionKind.daily), isTrue);
      expect(missions.every((m) => m.status == MissionStatus.open), isTrue);
    });

    test('rotation is deterministic for the same local day', () async {
      final first = (await service.curatedDaily(monday))
          .map((m) => m.id)
          .toList();
      final second = (await service.curatedDaily(monday))
          .map((m) => m.id)
          .toList();

      expect(first, second);
    });

    test('a different day yields a different roster', () async {
      final tuesday = monday.add(const Duration(days: 1));
      final idsMonday = (await service.curatedDaily(monday))
          .map((m) => m.id)
          .toList();
      final idsTuesday = (await service.curatedDaily(tuesday))
          .map((m) => m.id)
          .toList();

      expect(idsMonday, isNot(equals(idsTuesday)));
    });

    test('keeps completed missions across curator calls', () async {
      final missions = await service.curatedDaily(monday);
      await service.complete(missions.first.id, now: monday);

      final again = await service.curatedDaily(monday);
      final completed = again
          .where((mission) => mission.status == MissionStatus.completed);

      expect(completed, hasLength(1));
      expect(
        again.where((m) => m.status == MissionStatus.open).length,
        MissionRules.maxDaily - 1,
      );
    });
  });

  group('complete/skip', () {
    test('complete marks status and stamps time', () async {
      final missions = await service.curatedDaily(monday);
      await service.complete(missions.first.id, now: monday);

      final stored = await repository.findById(missions.first.id);
      expect(stored.status, MissionStatus.completed);
      expect(stored.completedAt, monday);
    });

    test('complete is idempotent', () async {
      final missions = await service.curatedDaily(monday);
      await service.complete(missions.first.id, now: monday);
      await service.complete(missions.first.id, now: monday);

      final stored = await repository.findById(missions.first.id);
      expect(stored.completedAt, monday);
    });

    test('skip moves the mission to skipped', () async {
      final missions = await service.curatedDaily(monday);
      await service.skip(missions.last.id);

      final stored = await repository.findById(missions.last.id);
      expect(stored.status, MissionStatus.skipped);
    });
  });

  group('repository', () {
    test('findById throws when mission is missing', () async {
      expect(
        () => repository.findById('does-not-exist'),
        throwsA(isA<MissionNotFoundException>()),
      );
    });

    test('persists across repository instances', () async {
      await service.curatedDaily(monday);

      final fresh = LocalMissionRepository(storage: storage);
      final missions = await fresh.findAll();

      expect(missions, hasLength(MissionRules.maxDaily));
    });

    test('corrupt payload hydrates to an empty catalog', () async {
      final broken = InMemorySecureStorageService();
      await broken.write('feature.missions.v1', 'not json');
      final repo = LocalMissionRepository(storage: broken);

      expect(await repo.findAll(), isEmpty);
    });
  });

  group('completion events', () {
    test('complete announces an event with the mission payload', () async {
      final bus = DomainEventBus();
      final emitter = MissionCatalogService(repository: repository, events: bus);
      final received = <MissionCompletedEvent>[];
      bus.events().listen((event) {
        if (event is MissionCompletedEvent) {
          received.add(event);
        }
      });

      final missions = await emitter.curatedDaily(monday);
      await emitter.complete(missions.first.id, now: monday);

      expect(received, hasLength(1));
      final event = received.single;
      expect(event.missionId, missions.first.id);
      expect(event.missionTitle, missions.first.title);
      expect(event.xpReward, MissionRules.dailyXpReward);
      expect(event.isWeekly, isFalse);
      expect(event.completedAt, monday);
    });

    test('a repeated complete never replays the event', () async {
      final bus = DomainEventBus();
      final emitter = MissionCatalogService(repository: repository, events: bus);
      var emissions = 0;
      bus.events().listen((_) => emissions++);

      final missions = await emitter.curatedDaily(monday);
      await emitter.complete(missions.first.id, now: monday);
      await emitter.complete(missions.first.id, now: monday);

      expect(emissions, 1);
    });

    test('skip emits nothing on the bus', () async {
      final bus = DomainEventBus();
      final emitter = MissionCatalogService(repository: repository, events: bus);
      var emissions = 0;
      bus.events().listen((_) => emissions++);

      final missions = await emitter.curatedDaily(monday);
      await emitter.skip(missions.last.id);

      expect(emissions, 0);
    });
  });
}