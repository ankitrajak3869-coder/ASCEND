import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/character/data/local_character_repository.dart';
import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/models/character_profile.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/character/repositories/character_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelRules', () {
    test('the live curve starts every adventurer at level 1', () {
      final rules = LevelRules.live;
      expect(rules.levelAt(0), 1);
      expect(rules.levelAt(999), 1);
    });

    test('levels up exactly at each threshold', () {
      final rules = LevelRules.live;
      expect(rules.levelAt(1000), 2);
      expect(rules.levelAt(2499), 2);
      expect(rules.levelAt(2500), 3);
      expect(rules.levelAt(4999), 3);
      expect(rules.levelAt(5000), 4);
    });

    test('thresholds are configurable and monotonic by construction', () {
      const rules = LevelRules(levelUpThresholds: <int>[100, 300]);
      expect(rules.levelAt(50), 1);
      expect(rules.levelAt(100), 2);
      expect(rules.levelAt(300), 3);
      expect(rules.levelAt(10_000), 3);
    });

    test('xpIntoLevel reports progress inside the current level', () {
      final rules = LevelRules.live;
      expect(rules.xpIntoLevel(500), 500);
      expect(rules.xpIntoLevel(1000), 0);
      expect(rules.xpIntoLevel(1300), 300);
    });
  });

  group('LocalCharacterRepository', () {
    test('load returns null when nothing is stored', () async {
      final repository = LocalCharacterRepository(
        storage: InMemorySecureStorageService(),
      );
      expect(await repository.load(), isNull);
    });

    test('round-trips a profile', () async {
      final storage = InMemorySecureStorageService();
      final repository = LocalCharacterRepository(storage: storage);
      final profile = CharacterProfile(
        name: 'Aria',
        level: 3,
        xp: 342,
        joinedAt: DateTime(2026, 1, 1),
      );

      await repository.save(profile);
      final loaded = await repository.load();

      expect(loaded?.name, 'Aria');
      expect(loaded?.level, 3);
      expect(loaded?.xp, 342);
    });

    test('corrupt payload loads as absent', () async {
      final storage = InMemorySecureStorageService();
      await storage.write('feature.character.profile.v1', '{broken');
      final repository = LocalCharacterRepository(storage: storage);

      expect(await repository.load(), isNull);
    });
  });

  group('CharacterProfileNotifier', () {
    test('build seeds a fresh profile on empty storage', () async {
      final harness = _harness();
      final profile = await harness.container.read(
        characterProfileProvider.future,
      );
      expect(profile.name, 'Rookie');
      expect(profile.level, 1);
    });

    test('awardXp recomputes level across thresholds', () async {
      final harness = _harness();
      final start = await harness.container.read(
        characterProfileProvider.future,
      );
      final needed = LevelRules.live.levelUpThresholds.first;
      final leveled = await harness.container
          .read(characterProfileProvider.notifier)
          .awardXp(needed);

      expect(leveled.level, start.level + 1);
      expect(leveled.xp, start.xp + needed);
    });

    test('rename rejects blank, trims and persists', () async {
      final harness = _harness();
      final notifier = harness.container.read(
        characterProfileProvider.notifier,
      );

      expect(
        notifier.rename('   '),
        throwsArgumentError,
      );

      await notifier.rename('  Kaira  ');
      expect(
        (await harness.container.read(characterProfileProvider.future)).name,
        'Kaira',
      );

      final saved = await harness.repository.load();
      expect(saved?.name, 'Kaira');
    });
  });
}

({ProviderContainer container, CharacterRepository repository}) _harness() {
  final repository = LocalCharacterRepository(
    storage: InMemorySecureStorageService(),
  );
  final container = ProviderContainer(
    overrides: <Override>[
      characterRepositoryProvider.overrideWithValue(repository),
    ],
  );
  return (container: container, repository: repository);
}