import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/goals/data/local_goal_repository.dart';
import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/services/goal_engine.dart';
import 'package:ascend/features/goals/services/goal_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late LocalGoalRepository repository;
  late GoalService service;
  late GoalEngine engine;
  late DomainEventBus bus;
  final monday = DateTime(2026, 8, 3, 9);

  setUp(() {
    repository = LocalGoalRepository(storage: InMemorySecureStorageService());
    service = GoalService(repository: repository);
    bus = DomainEventBus();
    engine = GoalEngine(repository: repository, events: bus);
  });

  MissionCompletedEvent milestoneDone(String goalId, int index) =>
      MissionCompletedEvent(
        missionId: 'gm-$goalId-$index',
        missionTitle: 'step',
        xpReward: GoalRules.milestoneXpReward,
        isWeekly: false,
        completedAt: monday,
        goalId: goalId,
        milestoneIndex: index,
      );

  group('planning', () {
    test('creates deterministic milestone plans for any goal', () {
      final plan = GoalEngine.planMilestones();

      expect(plan, hasLength(GoalRules.milestonesPerGoal));
      expect(plan.map((ms) => ms.title), <String>[
        'Foundation',
        'Momentum',
        'Finish',
      ]);
      expect(plan.map((ms) => ms.index), <int>[0, 1, 2]);
    });

    test('the plan does not depend on goal content or creation time',
        () async {
      final a = await service.create(id: 'a', title: 'Write a book', now: monday);
      final b = await service.create(id: 'b', title: 'Learn the piano', now: monday);

      expect(a.milestones.map((ms) => ms.title), b.milestones.map((ms) => ms.title));
    });
  });

  group('seeding', () {
    test('raises exactly one deterministic seed per active goal', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      await service.create(id: 'b', title: 'Learn the piano', now: monday);

      final seeds = await engine.plan();
      expect(seeds, hasLength(2));
      expect(seeds[0].missionId, 'gm-a-0');
      expect(seeds[1].missionId, 'gm-b-0');
      expect(seeds.first.goalId, 'a');
      expect(seeds.first.xpReward, GoalRules.milestoneXpReward);
    });

    test('a done goal raises no seed', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      await service.complete('a');

      expect(await engine.plan(), isEmpty);
    });

    test('planning is pure: same state, same seeds', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);

      final first = await engine.plan();
      final second = await engine.plan();

      expect(
        first.map((s) => s.missionId).toList(),
        second.map((s) => s.missionId).toList(),
      );
    });
  });

  group('advanceMilestone', () {
    test('a mission completion advances the goal milestone', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);

      final updated = await engine.advanceMilestone(milestoneDone('a', 0));

      expect(updated, isNotNull);
      expect(updated!.doneMilestones, 1);
      expect(updated.progress, closeTo(1 / GoalRules.milestonesPerGoal, 0.01));
      expect(updated.status, GoalStatus.active);
    });

test('the next open milestone seeds next once a mission completes',
        () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      await engine.advanceMilestone(milestoneDone('a', 0));

      expect(await engine.plan(), hasLength(1));
      expect((await engine.plan()).single.missionId, 'gm-a-1');
    });

    test('completing every milestone emits GoalCompletedEvent once', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      final completed = <GoalCompletedEvent>[];
      bus.events().listen((event) {
        if (event is GoalCompletedEvent) {
          completed.add(event);
        }
      });

      for (var i = 0; i < GoalRules.milestonesPerGoal; i++) {
        final updated = await engine.advanceMilestone(milestoneDone('a', i));
        expect(updated, isNotNull);
      }

      expect(completed, hasLength(1));
      expect(completed.single.goalId, 'a');
      expect(completed.single.completedAt, monday);

      final done = (await repository.findById('a'));
      expect(done.status, GoalStatus.done);
      expect(done.progress, 1);
    });

    test('replaying a done mission never re-emits', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      var emissions = 0;
      bus.events().listen((event) {
        if (event is GoalCompletedEvent) {
          emissions++;
        }
      });
      for (var i = 0; i < GoalRules.milestonesPerGoal; i++) {
        await engine.advanceMilestone(milestoneDone('a', i));
      }

      await engine.advanceMilestone(milestoneDone('a', GoalRules.milestonesPerGoal - 1));

      expect(emissions, 1);
    });

    test('unknown goals and done goals are no-ops', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      await service.complete('a');

      expect(await engine.advanceMilestone(milestoneDone('missing', 0)), isNull);
      expect(await engine.advanceMilestone(milestoneDone('a', 0)), isNull);
    });
  });

  group('reopen', () {
    test('reactivates the last milestone of a finished goal', () async {
      await service.create(id: 'a', title: 'Write a book', now: monday);
      for (var i = 0; i < GoalRules.milestonesPerGoal; i++) {
        await engine.advanceMilestone(milestoneDone('a', i));
      }

      final reopened = await engine.reopen('a');
      expect(reopened!.status, GoalStatus.active);
      expect(reopened.doneMilestones, GoalRules.milestonesPerGoal - 1);
      expect(reopened.progress, closeTo(2 / 3, 0.01));

      expect(await engine.plan(), hasLength(1));
      expect((await engine.plan()).single.milestoneIndex, GoalRules.milestonesPerGoal - 1);
    });
  });
}