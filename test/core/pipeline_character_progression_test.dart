import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/models/stat_kind.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/achievements/providers/achievement_providers.dart';
import 'package:ascend/features/analytics/providers/analytics_providers.dart';
import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:ascend/features/boss/providers/boss_providers.dart';
import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/missions/data/local_mission_repository.dart';
import 'package:ascend/features/missions/services/mission_catalog_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// End-to-end check of the character evolution engine through the pipeline:
/// a completed mission must award XP (+ level), stat gains and one history
/// record — exactly once, forever, without the character feature touching
/// the missions feature.
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

  test('completing the day awards XP, stats and history once each',
      () async {
    await container.read(characterProfileProvider.future);
    final roster = await missions.curatedDaily(monday);

    for (final mission in roster) {
      await missions.complete(mission.id, now: monday);
    }
    await settle();

    final profile = container.read(characterProfileProvider).valueOrNull!;
    expect(profile.xp, MissionRules.dailyXpReward * roster.length);
    expect(profile.level, LevelRules.live.levelAt(profile.xp));

    var expected = CharacterStats.fresh();
    for (final mission in roster) {
      expected = expected.apply(mission.statGains);
    }
    for (final kind in StatKind.values) {
      expect(
        profile.stats.valueOf(kind),
        expected.valueOf(kind),
      );
    }

    expect(profile.history.records, hasLength(roster.length));
    for (final mission in roster) {
      expect(
        profile.history.contains(mission.id),
        isTrue,
        reason: '${mission.id} must be recorded',
      );
    }
    expect(
      profile.history.records.first.xp,
      MissionRules.dailyXpReward,
    );
  });

  test('replayed completions and repeated events never double-award',
      () async {
    await container.read(characterProfileProvider.future);
    final roster = await missions.curatedDaily(monday);
    await missions.complete(roster.first.id, now: monday);
    await settle();

    final notifier = container.read(characterProfileProvider.notifier);
    final first = roster.first;
    final replay = MissionCompletedEvent(
      missionId: first.id,
      missionTitle: first.title,
      xpReward: first.xpReward,
      statGains: first.statGains,
      isWeekly: false,
      completedAt: monday,
    );

    await notifier.applyMissionResult(replay);
    await missions.complete(first.id, now: monday);
    await settle();

    final after = container.read(characterProfileProvider).valueOrNull!;
    expect(after.xp, MissionRules.dailyXpReward, reason: 'only one award');
    expect(after.history.records, hasLength(1));
    for (final kind in StatKind.values) {
      expect(
        after.stats.valueOf(kind),
        roster.first.statGains
            .where((gain) => gain.kind == kind)
            .fold<int>(0, (sum, gain) => sum + gain.amount),
      );
    }
  });

  test('a completion can push the adventurer over a level threshold',
      () async {
    await container.read(characterProfileProvider.future);
    final notifier = container.read(characterProfileProvider.notifier);
    final before = await notifier.awardXp(LevelRules.live.levelUpThresholds.first - 1);
    expect(before.level, 1);

    final roster = await missions.curatedDaily(monday);
    await missions.complete(roster.first.id, now: monday);
    await settle();

    final after = container.read(characterProfileProvider).valueOrNull!;
    expect(after.level, 2);
    expect(
      after.xp,
      LevelRules.live.levelUpThresholds.first - 1 + MissionRules.dailyXpReward,
    );
    expect(after.history.records, hasLength(1));
  });

  test('persisted profile survives a fresh container without replaying',
      () async {
    await container.read(characterProfileProvider.future);
    final roster = await missions.curatedDaily(monday);
    for (final mission in roster) {
      await missions.complete(mission.id, now: monday);
    }
    await settle();
    final first = container.read(characterProfileProvider).valueOrNull!;

    final second = ProviderContainer(
      overrides: <Override>[
        secureStorageProvider.overrideWithValue(storage),
      ],
    );
    addTearDown(second.dispose);
    final loaded =
        await second.read(characterProfileProvider.future);

    expect(loaded.xp, first.xp);
    expect(loaded.history.records, hasLength(first.history.records.length));
    for (final kind in StatKind.values) {
      expect(loaded.stats.valueOf(kind), first.stats.valueOf(kind));
    }

    second.read(characterProgressionRelayProvider);
    final reloaded = await second.read(characterProfileProvider.notifier)
        .applyMissionResult(
          MissionCompletedEvent(
            missionId: roster.first.id,
            missionTitle: roster.first.title,
            xpReward: roster.first.xpReward,
            statGains: roster.first.statGains,
            isWeekly: false,
            completedAt: monday,
          ),
        );
    expect(reloaded.xp, first.xp, reason: 'stored history blocks the replay');
  });

  test('stats also flow into achievements and telemetry', () async {
    await container.read(characterProfileProvider.future);
    await container.read(achievementsProvider.future);

    final roster = await missions.curatedDaily(monday);
    for (final mission in roster) {
      await missions.complete(mission.id, now: monday);
    }
    await settle();

    final trophies = container.read(achievementsProvider).valueOrNull!;
    expect(trophies.firstWhere((t) => t.id == 'first_step').isUnlocked, isTrue);

    final buffered = (await container.read(bufferedEventsProvider.future))
        .map((event) => event.toJson())
        .toList();
    expect(
      buffered.where((e) => e['name'] == 'mission_completed'),
      hasLength(roster.length),
    );

    final boss = container.read(bossStateProvider).valueOrNull!;
    expect(boss.phase, BossPhase.dormant, reason: 'no boss pressure');
    expect(boss.strikes, 0);
  });
}