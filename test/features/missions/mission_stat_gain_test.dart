import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/models/stat_kind.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/missions/data/local_mission_repository.dart';
import 'package:ascend/features/missions/services/mission_catalog_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// The missions feature independently owns its stat contributions: every
/// minted mission declares gains, all seven stats are reachable, and the
/// gains survive persistence and reach the completion event.
void main() {
  final monday = DateTime(2026, 8, 3, 9);
  late InMemorySecureStorageService storage;
  late MissionCatalogService missions;

  setUp(() {
    storage = InMemorySecureStorageService();
    missions = MissionCatalogService(
      repository: LocalMissionRepository(storage: storage),
    );
  });

  test('every curated daily mission carries positive stat gains', () async {
    final roster = await missions.curatedDaily(monday);
    expect(roster, hasLength(MissionRules.maxDaily));
    for (final mission in roster) {
      expect(mission.statGains, isNotEmpty, reason: mission.title);
      for (final gain in mission.statGains) {
        expect(gain.amount, greaterThan(0));
      }
    }
  });

  test('the rotation covers every stat kind across days', () async {
    final covered = <StatKind>{};
    for (var day = 0; day < 5; day++) {
      final roster = await missions.curatedDaily(
        monday.add(Duration(days: day)),
      );
      for (final mission in roster) {
        covered.addAll(mission.statGains.map((gain) => gain.kind));
      }
    }
    expect(covered, containsAll(StatKind.values));
  });

  test('stat gains survive a save/load round trip', () async {
    final roster = await missions.curatedDaily(monday);
    final one = roster.first;

    await missions.complete(one.id, now: monday);
    final stored = await missions.repository.findById(one.id);

    expect(stored.statGains, one.statGains);
  });

  test('the completion event carries the mission stat gains', () async {
    final bus = DomainEventBus();
    final seen = <MissionCompletedEvent>[];
    bus.events().listen((event) {
      if (event is MissionCompletedEvent) {
        seen.add(event);
      }
    });
    missions = MissionCatalogService(
      repository: LocalMissionRepository(storage: storage),
      events: bus,
    );

    final roster = await missions.curatedDaily(monday);
    await missions.complete(roster.first.id, now: monday);

    expect(seen, hasLength(1));
    expect(seen.single.statGains, roster.first.statGains);
  });
}