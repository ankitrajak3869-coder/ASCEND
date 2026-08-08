import 'dart:async';

import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/features/achievements/data/local_achievement_repository.dart';
import 'package:ascend/features/achievements/domain/achievement_domain.dart';
import 'package:ascend/features/achievements/models/achievement_model.dart';
import 'package:ascend/features/achievements/repositories/achievement_repository.dart';
import 'package:ascend/features/achievements/services/achievement_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed achievement repository.
final achievementRepositoryProvider = Provider<AchievementRepository>(
  (ref) => LocalAchievementRepository(storage: ref.watch(secureStorageProvider)),
);

/// Achievement counter service.
final achievementServiceProvider = Provider<AchievementService>(
  (ref) => AchievementService(repository: ref.watch(achievementRepositoryProvider)),
);

/// The persistent trophy rack.
final achievementsProvider =
    AsyncNotifierProvider<AchievementsNotifier, List<AchievementModel>>(
      AchievementsNotifier.new,
    );

/// The user's trophy rack and its event-driven progression.
final class AchievementsNotifier
    extends AsyncNotifier<List<AchievementModel>> {
  @override
  Future<List<AchievementModel>> build() async {
    return ref.watch(achievementServiceProvider).loadOrSeed();
  }

  /// Advances [kind] counters and refreshes state.
  Future<List<AchievementModel>> applyProgress(
    AchievementKind kind,
    int amount, {
    DateTime? now,
  }) {
    return applyProgresses(<AchievementKind, int>{kind: amount}, now: now);
  }

  /// Advances several counters atomically and refreshes state.
  Future<List<AchievementModel>> applyProgresses(
    Map<AchievementKind, int> progress, {
    DateTime? now,
  }) async {
    final updated = await ref
        .read(achievementServiceProvider)
        .applyProgresses(progress, now: now);
    state = AsyncData<List<AchievementModel>>(updated);
    return updated;
  }
}

/// Listens on the domain bus and grows trophies from mission completions and
/// boss defeats. Watched by the app pipeline so it stays alive.
final achievementsRelayProvider = Provider<StreamSubscription<DomainEvent>>(
  (ref) {
    final bus = ref.watch(domainEventBusProvider);
    final subscription = listenForGame(bus, (event) {
      switch (event) {
        case MissionCompletedEvent(:final xpReward):
          unawaited(
            ref
                .read(achievementsProvider.notifier)
                .applyProgresses(<AchievementKind, int>{
                  AchievementKind.missionsCompleted: 1,
                  AchievementKind.totalXp: xpReward,
                }),
          );
          break;
        case BossDefeatedEvent():
          unawaited(
            ref
                .read(achievementsProvider.notifier)
                .applyProgress(AchievementKind.bossesDefeated, 1),
          );
          break;
        case GoalCompletedEvent():
          unawaited(
            ref
                .read(achievementsProvider.notifier)
                .applyProgress(AchievementKind.goalsCompleted, 1),
          );
          break;
      }
    });
    ref.onDispose(subscription.cancel);
    return subscription;
  },
);