import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/achievements/data/local_achievement_repository.dart';
import 'package:ascend/features/achievements/domain/achievement_domain.dart';
import 'package:ascend/features/achievements/models/achievement_model.dart';
import 'package:ascend/features/achievements/services/achievement_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late InMemorySecureStorageService storage;
  late LocalAchievementRepository repository;
  late AchievementService service;
  final monday = DateTime(2026, 8, 3, 9);

  setUp(() {
    storage = InMemorySecureStorageService();
    repository = LocalAchievementRepository(storage: storage);
    service = AchievementService(repository: repository);
  });

  AchievementModel byId(List<AchievementModel> rack, String id) =>
      rack.firstWhere((trophy) => trophy.id == id);

  group('catalog', () {
    test('seeds the rack on first load', () async {
      final rack = await service.loadOrSeed();

      expect(rack, hasLength(6));
      expect(rack.map((t) => t.id), containsAll(<String>[
        'first_step',
        'weekly_roster',
        'xp_momentum',
        'boss_slayer',
        'first_goal',
        'goal_architect',
      ]));
      expect(rack.every((t) => !t.isUnlocked), isTrue);
    });

    test('seeded rack persists across repository instances', () async {
      await service.loadOrSeed();

      final fresh = LocalAchievementRepository(storage: storage);
      expect(await fresh.load(), hasLength(6));
    });

    test('corrupt payload hydrates to an empty rack and reseeds', () async {
      storage = InMemorySecureStorageService();
      await storage.write('feature.achievements.v1', 'not json');
      repository = LocalAchievementRepository(storage: storage);
      service = AchievementService(repository: repository);

      final rack = await service.loadOrSeed();
      expect(rack, hasLength(6));
    });
  });

  group('applyProgress', () {
    test('advances only trophies of the matching kind', () async {
      final rack = await service.applyProgress(
        AchievementKind.missionsCompleted,
        1,
        now: monday,
      );

      expect(byId(rack, 'first_step').current, 1);
      expect(byId(rack, 'first_step').isUnlocked, isTrue);
      expect(byId(rack, 'xp_momentum').current, 0);
      expect(byId(rack, 'boss_slayer').current, 0);
    });

    test('clamps progress to the target', () async {
      final rack = await service.applyProgress(
        AchievementKind.missionsCompleted,
        99,
        now: monday,
      );

      expect(byId(rack, 'weekly_roster').current, 25);
      expect(byId(rack, 'weekly_roster').progress, 1);
    });

    test('unlocks exactly once and stamps the first unlock time', () async {
      await service.applyProgress(
        AchievementKind.bossesDefeated,
        1,
        now: monday,
      );
      final rack = await service.applyProgress(
        AchievementKind.bossesDefeated,
        1,
        now: monday.add(const Duration(days: 1)),
      );

      final slayer = byId(rack, 'boss_slayer');
      expect(slayer.isUnlocked, isTrue);
      expect(slayer.current, 1);
      expect(slayer.unlockedAt, monday);
    });

    test('zero or negative amounts do not persist a change', () async {
      final before = await service.loadOrSeed();
      final rack = await service.applyProgress(
        AchievementKind.missionsCompleted,
        0,
        now: monday,
      );

      expect(
        rack.map((t) => t.toJson()).toList(),
        before.map((t) => t.toJson()).toList(),
      );
    });
  });
}