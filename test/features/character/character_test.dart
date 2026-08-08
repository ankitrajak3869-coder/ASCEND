import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/character/data/local_character_repository.dart';
import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/models/character_profile.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/character/repositories/character_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LevelCurve', () {
    test('xp for level 1 is required to reach level 2', () {
      final first = LevelCurve.xpForLevel(1);
      expect(first, greaterThan(0));
      expect(LevelCurve.levelAt(0), 1);
      expect(LevelCurve.levelAt(first - 1), 1);
      expect(LevelCurve.levelAt(first), 2);
    });

    test('level grows monotonically with XP', () {
      var previous = 1;
      for (var xp = 0; xp < 100000; xp += 137) {
        final level = LevelCurve.levelAt(xp);
        expect(level, greaterThanOrEqualTo(previous));
        previous = level;
      }
    });

    test('later levels cost more than early ones', () {
      expect(
        LevelCurve.xpForLevel(5),
        greaterThan(LevelCurve.xpForLevel(1)),
      );
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
      final needed = LevelCurve.xpForLevel(start.level);
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