import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/boss/data/local_boss_repository.dart';
import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:ascend/features/boss/models/boss_model.dart';
import 'package:ascend/features/boss/services/boss_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late BossService service;
  late LocalBossRepository repository;
  final monday = DateTime(2026, 8, 3, 9);

  setUp(() {
    repository = LocalBossRepository(storage: InMemorySecureStorageService());
    service = BossService(repository: repository);
  });

  Future<BossModel> strikes(int count, DateTime on) async {
    var boss = BossModel.fresh();
    for (var i = 0; i < count; i++) {
      boss = await service.strike(now: on);
    }
    return boss;
  }

  group('strike', () {
    test('first strike wakes the boss into rumbling', () async {
      final boss = await service.strike(now: monday);
      expect(boss.phase, BossPhase.rumbling);
      expect(boss.combo, 1);
      expect(boss.health, BossRules.maxHealth - BossRules.baseDamage);
    });

    test('same-day repeats stack combo and add bonus damage', () async {
      final first = await service.strike(now: monday);
      expect(first.combo, 1);

      final second = await service.strike(now: monday.add(const Duration(hours: 5)));
      expect(second.combo, 2);
      expect(
        second.health,
        first.health - (BossRules.baseDamage + BossRules.streakBonus),
      );
    });

    test('a skipped day resets the combo', () async {
      await service.strike(now: monday);
      final wednesday = await service.strike(
        now: monday.add(const Duration(days: 2)),
      );
      expect(wednesday.combo, 1);
    });

    test('enrages at the threshold and defeats at zero HP', () async {
      final enraged = await strikes(5, monday);
      expect(enraged.phase, BossPhase.enraged);
      expect(enraged.health, lessThanOrEqualTo(BossRules.enrageThreshold));

      final defeated = await strikes(7, monday);
      expect(defeated.phase, BossPhase.defeated);
      expect(defeated.health, 0);
    });

    test('striking a defeated boss does nothing', () async {
      final defeated = await strikes(10, monday);
      final again = await service.strike(now: monday);
      expect(again.strikes, defeated.strikes);
      expect(again.phase, BossPhase.defeated);
    });
  });

  group('revive', () {
    test('restores a fresh dormant boss at full health', () async {
      await strikes(10, monday);
      final fresh = await service.revive();
      expect(fresh.phase, BossPhase.dormant);
      expect(fresh.health, BossRules.maxHealth);
      expect(fresh.combo, 0);
    });
  });

  group('awaken', () {
    test('unlocks a dormant boss into an active fight at full health', () async {
      final awake = await service.awaken();

      expect(awake.phase, BossPhase.rumbling);
      expect(awake.health, BossRules.maxHealth);
      expect(awake.combo, 0);
    });

    test('active or defeated bosses are left untouched', () async {
      await service.strike(now: monday);
      final afterStrike = await service.awaken();
      expect(afterStrike.strikes, 1);

      final defeated = await strikes(7, monday);
      final afterDefeat = await service.awaken();
      expect(afterDefeat.phase, BossPhase.defeated);
      expect(afterDefeat.strikes, defeated.strikes);
    });
  });

  test('a boss persists and reloads across repository instances', () async {
    final storage = InMemorySecureStorageService();
    final repo = LocalBossRepository(storage: storage);
    final first = BossService(repository: repo);
    await first.strike(now: monday);

    final second = BossService(repository: LocalBossRepository(storage: storage));
    final reloaded = await second.loadOrFresh();
    expect(reloaded.strikes, 1);
    expect(reloaded.phase, BossPhase.rumbling);
  });

  group('applyMissionCompletion', () {
    MissionCompletedEvent completed(DateTime at) => MissionCompletedEvent(
      missionId: 'm1',
      missionTitle: 'Run',
      xpReward: 50,
      isWeekly: false,
      completedAt: at,
    );

    test('a dormant boss ignores missions', () async {
      final boss = await service.applyMissionCompletion(
        mission: completed(monday),
      );

      expect(boss.strikes, 0);
      expect(boss.phase, BossPhase.dormant);
    });

    test('missions strike an engaged boss with the same streak math', () async {
      await service.strike(now: monday);

      final afterMission = await service.applyMissionCompletion(
        mission: completed(monday),
      );
      expect(afterMission.combo, 2);
      expect(
        afterMission.health,
        BossRules.maxHealth -
            BossRules.baseDamage -
            (BossRules.baseDamage + BossRules.streakBonus),
      );
    });

    test('a defeat via mission emits one BossDefeatedEvent', () async {
      final bus = DomainEventBus();
      final eventful = BossService(
        repository: LocalBossRepository(storage: InMemorySecureStorageService()),
        events: bus,
      );
      var defeats = 0;
      bus.events().listen((event) {
        if (event is BossDefeatedEvent) {
          defeats++;
        }
      });

      for (var i = 0; i < 4; i++) {
        await eventful.strike(now: monday);
      }
      await eventful.applyMissionCompletion(mission: completed(monday));
      await eventful.applyMissionCompletion(mission: completed(monday));
      await eventful.applyMissionCompletion(
        mission: completed(monday.add(const Duration(hours: 2))),
      );

      expect(defeats, 1);

      await eventful.applyMissionCompletion(mission: completed(monday));
      expect(defeats, 1, reason: 'a defeated boss cannot be re-defeated');
    });
  });
}