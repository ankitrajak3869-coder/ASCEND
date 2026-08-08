import 'dart:async';

import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/features/goals/data/local_goal_repository.dart';
import 'package:ascend/features/goals/models/goal_model.dart';
import 'package:ascend/features/goals/repositories/goal_repository.dart';
import 'package:ascend/features/goals/services/goal_engine.dart';
import 'package:ascend/features/goals/services/goal_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed goal repository.
final goalRepositoryProvider = Provider<GoalRepository>(
  (ref) => LocalGoalRepository(storage: ref.watch(secureStorageProvider)),
);

/// Goal rules service.
final goalServiceProvider = Provider<GoalService>(
  (ref) => GoalService(repository: ref.watch(goalRepositoryProvider)),
);

/// The goal engine: deterministic milestone planning and mission seeding.
final goalEngineProvider = Provider<GoalEngine>(
  (ref) => GoalEngine(
    repository: ref.watch(goalRepositoryProvider),
    events: ref.watch(domainEventBusProvider),
  ),
);

/// All goals, newest first.
final goalsProvider = FutureProvider<List<GoalModel>>(
  (ref) async {
    final goals = await ref.watch(goalRepositoryProvider).findAll();
    goals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return goals;
  },
);

/// The current milestone-derived plan (one mission per open milestone).
/// Consumed by the missions feature via the app composition root.
final goalMissionPlanProvider = FutureProvider<List<MissionSeed>>(
  (ref) async {
    ref.watch(goalsProvider);
    return ref.read(goalEngineProvider).plan();
  },
);

/// Convenience actions that operate on the current goals state.
final goalActionsProvider = Provider<GoalActions>((ref) => GoalActions(ref));

final class GoalActions {
  const GoalActions(this.ref);

  final Ref ref;

  Future<void> create(String title) async {
    final id = 'goal-${DateTime.now().microsecondsSinceEpoch}';
    await ref.read(goalServiceProvider).create(id: id, title: title);
    ref.invalidate(goalsProvider);
    ref.invalidate(goalMissionPlanProvider);
  }

  Future<void> complete(String id) async {
    await ref.read(goalServiceProvider).complete(id);
    ref.invalidate(goalsProvider);
    ref.invalidate(goalMissionPlanProvider);
  }

  Future<void> reopen(String id) async {
    await ref.read(goalEngineProvider).reopen(id);
    ref.invalidate(goalsProvider);
    ref.invalidate(goalMissionPlanProvider);
  }

  Future<void> remove(String id) async {
    await ref.read(goalServiceProvider).remove(id);
    ref.invalidate(goalsProvider);
    ref.invalidate(goalMissionPlanProvider);
  }
}

/// Listens on the domain bus and forwards goal-mission completions to the
/// engine. Watched by the app pipeline so it stays alive.
final goalMissionRelayProvider = Provider<StreamSubscription<DomainEvent>>(
  (ref) {
    final bus = ref.watch(domainEventBusProvider);
    final subscription = listenForGame(bus, (event) {
      if (event case MissionCompletedEvent(:final goalId) when goalId != null) {
        unawaited(_forwardMilestone(ref, event));
      }
    });
    ref.onDispose(subscription.cancel);
    return subscription;
  },
);

Future<void> _forwardMilestone(Ref ref, MissionCompletedEvent event) async {
  await ref.read(goalEngineProvider).advanceMilestone(event);
  ref.invalidate(goalsProvider);
  ref.invalidate(goalMissionPlanProvider);
}