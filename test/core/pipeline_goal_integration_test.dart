import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/achievements/providers/achievement_providers.dart';
import 'package:ascend/features/analytics/providers/analytics_providers.dart';
import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:ascend/features/boss/providers/boss_providers.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/models/goal_model.dart';
import 'package:ascend/features/goals/providers/goal_providers.dart';
import 'package:ascend/features/missions/providers/mission_providers.dart';
import 'package:ascend/features/skill_tree/providers/skill_tree_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The full goal engine flow, through the real composition root:
///
///   Goal → Milestones → Mission seeds → Missions → Mission Complete →
///   Goal Progress → Goal Completed → unlock Boss / Skill node /
///   Achievement / (analytics review trigger).
void main() {
  final monday = DateTime(2026, 8, 3, 9);
  late InMemorySecureStorageService storage;
  late ProviderContainer container;

  setUp(() {
    storage = InMemorySecureStorageService();
    container = ProviderContainer(
      overrides: <Override>[
        secureStorageProvider.overrideWithValue(storage),
        missionSeedSourceProvider.overrideWith(
          (ref) =>
              ref.watch(goalMissionPlanProvider).valueOrNull ??
              const <MissionSeed>[],
        ),
      ],
    );
    addTearDown(container.dispose);

    // Subscription order mirrors the app pipeline (boss first so the third
    // mission of a goal is evaluated while the boss is still dormant,
    // keeping the chain deterministic).
    container.read(characterProgressionRelayProvider);
    container.read(bossMissionRelayProvider);
    container.read(bossGoalRelayProvider);
    container.read(goalMissionRelayProvider);
    container.read(achievementsRelayProvider);
    container.read(skillTreeGoalRelayProvider);
    container.read(analyticsRelayProvider);
  });

  Future<void> settle() async {
    for (var i = 0; i < 20; i++) {
      await container.pump();
    }
  }

  Future<GoalModel> createGoal(String id, String title) async {
    await container.read(goalServiceProvider).create(
      id: id,
      title: title,
      now: monday,
    );
    container.invalidate(goalsProvider);
    container.invalidate(goalMissionPlanProvider);
    return (await container.read(goalsProvider.future))
        .firstWhere((goal) => goal.id == id);
  }

  Future<void> completeGoalMilestones(String goalId) async {
    for (var i = 0; i < GoalRules.milestonesPerGoal; i++) {
      // The seed source bridges the plan future synchronously, so each
      // round must wait for the recomputed plan before reading the catalog.
      await container.read(goalMissionPlanProvider.future);
      final catalog = container.read(missionCatalogProvider);
      final planned = await catalog.applySeeds(now: monday);
      final mission = planned.singleWhere(
        (mission) => mission.goalId == goalId && mission.milestoneIndex == i,
      );
      await catalog.complete(mission.id, now: monday);
      await settle();
    }
  }

  test('a goal completes through its milestone missions', () async {
    final goal = await createGoal('goal-1', 'Write a book');
    expect(goal.milestones, hasLength(GoalRules.milestonesPerGoal));
    await settle();

    await completeGoalMilestones('goal-1');

    final stored = await container.read(goalRepositoryProvider).findById('goal-1');
    expect(stored.status, GoalStatus.done);
    expect(stored.progress, 1);
    expect(stored.doneMilestones, GoalRules.milestonesPerGoal);
  });

  test('a completed goal unlocks the boss, a skill root and an achievement',
      () async {
    await createGoal('goal-1', 'Write a book');
    await settle();
    await completeGoalMilestones('goal-1');

    final boss = container.read(bossStateProvider).valueOrNull!;
    expect(boss.phase, isNot(BossPhase.dormant), reason: 'goal unlocks the fight');
    expect(boss.phase, BossPhase.rumbling);

    await container.read(bossStateProvider.notifier).strike(now: monday);
    await settle();
    expect(
      container.read(bossStateProvider).valueOrNull!.strikes,
      1,
      reason: 'the unlocked boss accepts strikes',
    );

    final trophies =
        container.read(achievementsProvider).valueOrNull ?? const [];
    expect(
      trophies.firstWhere((t) => t.id == 'first_goal').isUnlocked,
      isTrue,
    );
    expect(
      trophies.firstWhere((t) => t.id == 'goal_architect').isUnlocked,
      isFalse,
    );

    final tree = container.read(skillTreeProvider).valueOrNull;
    expect(tree, isNotNull);
    expect(tree!.isUnlocked('deeper_plans'), isTrue);
    expect(tree.isUnlocked('boss_access'), isFalse);

    final buffered = await container.read(bufferedEventsProvider.future);
    final names = buffered.map((event) => event.name).toList();
    expect(names.where((n) => n == 'mission_completed'), hasLength(3));
    expect(names.where((n) => n == 'goal_completed'), hasLength(1));
  });

  test('a second completed goal unlocks the next skill node', () async {
    await createGoal('goal-1', 'Write a book');
    await settle();
    await completeGoalMilestones('goal-1');

    await createGoal('goal-2', 'Learn the piano');
    await settle();
    await completeGoalMilestones('goal-2');

    final tree = container.read(skillTreeProvider).valueOrNull!;
    expect(tree.isUnlocked('deeper_plans'), isTrue);
    expect(tree.isUnlocked('boss_access'), isTrue);

    final boss = container.read(bossStateProvider).valueOrNull!;
    expect(
      boss.phase,
      isNot(BossPhase.dormant),
      reason: 'a second goal keeps the fight unlocked',
    );
  });
}