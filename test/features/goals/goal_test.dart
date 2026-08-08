import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/goals/data/local_goal_repository.dart';
import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/services/goal_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late GoalService service;
  late LocalGoalRepository repository;

  setUp(() {
    repository = LocalGoalRepository(storage: InMemorySecureStorageService());
    service = GoalService(repository: repository);
  });

  Future<void> seed(int count) async {
    for (var i = 0; i < count; i++) {
      await service.create(id: 'goal-$i', title: 'Goal $i');
    }
  }

  group('create', () {
    test('enforces the active cap', () async {
      await seed(GoalRules.maxActive);

      expect(
        service.create(id: 'overflow', title: 'Extra'),
        throwsA(isA<GoalQuotaReachedException>()),
      );
    });

    test('quota is per active goal; completing frees a slot', () async {
      await seed(GoalRules.maxActive);
      await service.complete('goal-0');

      final goal = await service.create(id: 'goal-4', title: 'After done');
      expect(goal.id, 'goal-4');
    });

    test('blank titles are rejected', () async {
      expect(
        service.create(id: 'x', title: '   '),
        throwsArgumentError,
      );
    });
  });

  group('progress', () {
    test('is clamped into 0..1', () async {
      await service.create(id: 'g', title: 'Run a lap');
      await service.setProgress('g', 2.5);
      expect((await repository.findById('g')).progress, 1);

      await service.setProgress('g', -3);
      expect((await repository.findById('g')).progress, 0);
    });

    test('complete sets progress to 1 and status done', () async {
      await service.create(id: 'g', title: 'Run a lap');
      await service.complete('g');

      final goal = await repository.findById('g');
      expect(goal.isDone, isTrue);
      expect(goal.progress, 1);
    });

    test('reopen restores the active status', () async {
      await service.create(id: 'g', title: 'Run a lap');
      await service.complete('g');
      await service.reopen('g');

      expect((await repository.findById('g')).isDone, isFalse);
    });
  });

  test('unknown id surfaces GoalNotFoundException', () async {
    expect(
      () => service.complete('nope'),
      throwsA(isA<GoalNotFoundException>()),
    );
  });

  test('remove drops the goal from persistence', () async {
    await service.create(id: 'g', title: 'Run a lap');
    await service.remove('g');

    expect(await repository.findAll(), isEmpty);
  });
}