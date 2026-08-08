import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/achievements/providers/achievement_providers.dart';
import 'package:ascend/features/analytics/providers/analytics_providers.dart';
import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:ascend/features/boss/providers/boss_providers.dart';
import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/missions/data/local_mission_repository.dart';
import 'package:ascend/features/missions/domain/mission_domain.dart';
import 'package:ascend/features/missions/services/mission_catalog_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end check of the cross-feature pipeline: completing a mission must
/// fan out (through core events only) into character XP, boss pressure,
/// achievement counters and analytics — no feature touching another's state.
void main() {
  final monday = DateTime(2026, 8, 3, 9);
  late InMemorySecureStorageService storage;
  late ProviderContainer container;
  late MissionCatalogService missions;

  setUp(() {
    storage = InMemorySecureStorageService();
    container = ProviderContainer(
      overrides: <Override>[
        secureStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(container.dispose);
    final bus = container.read(domainEventBusProvider);
    missions = MissionCatalogService(
      repository: LocalMissionRepository(storage: storage),
      events: bus,
    );
    container.read(characterProgressionRelayProvider);
    container.read(bossMissionRelayProvider);
    container.read(achievementsRelayProvider);
    container.read(analyticsRelayProvider);
  });

  Future<void> settle() async {
    for (var i = 0; i < 10; i++) {
      await container.pump();
    }
  }

  Future<List<Map<String, Object?>>> analytics() async {
    return (await container.read(bufferedEventsProvider.future))
        .map((event) => event.toJson())
        .toList();
  }

  Future<String> firstMissionId([DateTime? day]) async {
    final roster = await missions.curatedDaily(day ?? monday);
    return roster.first.id;
  }

  group('mission completion pipeline', () {
    test('awards XP, unlocks the first trophy and records telemetry', () async {
      await container.read(characterProfileProvider.future);
      await container.read(achievementsProvider.future);

      await missions.complete(await firstMissionId(), now: monday);
      await settle();

      final profile = container.read(characterProfileProvider).valueOrNull;
      expect(profile, isNotNull);
      expect(profile!.xp, MissionRules.dailyXpReward);
      expect(
        profile.level,
        LevelCurve.levelAt(MissionRules.dailyXpReward),
      );

      final trophies = container.read(achievementsProvider).valueOrNull!;
      final firstStep = trophies.firstWhere((t) => t.id == 'first_step');
      expect(firstStep.isUnlocked, isTrue);
      expect(firstStep.current, isPositive);

      final buffered = await analytics();
      expect(buffered, hasLength(1));
      expect(buffered.single['name'], 'mission_completed');
      expect(
        buffered.single['parameters'],
        <String, Object?>{'weekly': false, 'xp': MissionRules.dailyXpReward},
      );
    });

    test('second completion of the same mission never double-counts',
        () async {
          await container.read(characterProfileProvider.future);
          await container.read(achievementsProvider.future);

          final id = await firstMissionId();
          await missions.complete(id, now: monday);
          await missions.complete(id, now: monday);
          await settle();

          final profile = container.read(characterProfileProvider).valueOrNull!;
          expect(profile.xp, MissionRules.dailyXpReward);

          final trophies = container.read(achievementsProvider).valueOrNull!;
          expect(
            trophies.firstWhere((t) => t.id == 'first_step').current,
            1,
          );

          expect(await analytics(), hasLength(1));
        });

    test('a dormant boss ignores missions entirely', () async {
      await container.read(bossStateProvider.future);

      await missions.complete(await firstMissionId(), now: monday);
      await settle();

      final boss = container.read(bossStateProvider).valueOrNull!;
      expect(boss.phase, BossPhase.dormant);
      expect(boss.health, BossRules.maxHealth);
      expect(boss.strikes, 0);
    });
  });

  group('boss defeat pipeline', () {
    test('missions pressure an active boss; a defeat emits exactly once',
        () async {
      await container.read(characterProfileProvider.future);
      await container.read(bossStateProvider.future);
      await container.read(achievementsProvider.future);

      final bossNotifier = container.read(bossStateProvider.notifier);
      for (var i = 0; i < 4; i++) {
        await bossNotifier.strike(now: monday);
      }
      expect(
        container.read(bossStateProvider).valueOrNull!.phase,
        isNot(BossPhase.dormant),
      );

      final roster = await missions.curatedDaily(monday);
      for (final mission in roster.take(3)) {
        await missions.complete(mission.id, now: monday);
      }
      await settle();

      final after = container.read(bossStateProvider).valueOrNull!;
      expect(after.isDefeated, isTrue);
      expect(after.strikes, 7);

      final nextDay = await firstMissionId(monday.add(const Duration(days: 1)));
      final before = after.strikes;
      await missions.complete(nextDay, now: monday.add(const Duration(days: 1)));
      await settle();
      expect(
        container.read(bossStateProvider).valueOrNull!.strikes,
        before,
        reason: 'a defeated boss ignores further missions',
      );

      final trophies = container.read(achievementsProvider).valueOrNull!;
      expect(
        trophies.firstWhere((t) => t.id == 'boss_slayer').isUnlocked,
        isTrue,
      );

      final buffered = await analytics();
      final names = buffered.map((event) => event['name']).toList();
      expect(names.where((n) => n == 'boss_defeated'), hasLength(1));
      expect(
        names.where((n) => n == 'mission_completed').length,
        4,
      );
    });
  });
}