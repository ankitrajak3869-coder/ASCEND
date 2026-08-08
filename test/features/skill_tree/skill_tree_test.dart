import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/skill_tree/data/local_skill_tree_repository.dart';
import 'package:ascend/features/skill_tree/services/skill_tree_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalSkillTreeRepository repository;
  late SkillTreeService service;

  setUp(() {
    repository = LocalSkillTreeRepository(storage: InMemorySecureStorageService());
    service = SkillTreeService(repository: repository);
  });

  group('unlockNext', () {
    test('a fresh tree unlocks the first catalog node', () async {
      final tree = await service.unlockNext();

      expect(tree.unlockedNodeIds, <String>['deeper_plans']);
      expect(tree.isUnlocked('deeper_plans'), isTrue);
      expect(tree.isUnlocked('boss_access'), isFalse);
    });

    test('nodes unlock strictly in catalog order', () async {
      await service.unlockNext();
      await service.unlockNext();
      final tree = await service.unlockNext();

      expect(tree.unlockedNodeIds, <String>[
        'deeper_plans',
        'boss_access',
        'ai_review',
      ]);
      expect(tree.isComplete, isTrue);
    });

    test('a complete tree is a no-op', () async {
      await service.unlockNext();
      await service.unlockNext();
      await service.unlockNext();
      final tree = await service.unlockNext();

      expect(tree.unlockedNodeIds, hasLength(3));
    });
  });

  test('the tree persists across repository instances', () async {
    await service.unlockNext();

    final reloaded = SkillTreeService(
      repository: LocalSkillTreeRepository(storage: repository.storage),
    );
    final tree = await reloaded.loadOrFresh();

    expect(tree.isUnlocked('deeper_plans'), isTrue);
  });

  test('corrupt payload degrades to a fresh all-locked tree', () async {
    final broken = InMemorySecureStorageService();
    await broken.write('feature.skilltree.v1', 'not json');
    final service = SkillTreeService(
      repository: LocalSkillTreeRepository(storage: broken),
    );

    expect((await service.loadOrFresh()).unlockedNodeIds, isEmpty);
  });
}