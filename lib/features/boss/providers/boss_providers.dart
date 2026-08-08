import 'dart:async';

import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/features/boss/data/local_boss_repository.dart';
import 'package:ascend/features/boss/models/boss_model.dart';
import 'package:ascend/features/boss/repositories/boss_repository.dart';
import 'package:ascend/features/boss/services/boss_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed boss repository.
final bossRepositoryProvider = Provider<BossRepository>(
  (ref) => LocalBossRepository(storage: ref.watch(secureStorageProvider)),
);

/// Boss encounter service; announces defeats on the domain bus.
final bossServiceProvider = Provider<BossService>(
  (ref) => BossService(
    repository: ref.watch(bossRepositoryProvider),
    events: ref.watch(domainEventBusProvider),
  ),
);

/// Current encounter; a dormant boss is minted on first read.
final bossStateProvider =
    AsyncNotifierProvider<BossNotifier, BossModel>(BossNotifier.new);

final class BossNotifier extends AsyncNotifier<BossModel> {
  @override
  Future<BossModel> build() => ref.watch(bossServiceProvider).loadOrFresh();

  /// Lands a strike and refreshes state.
  Future<BossModel> strike({DateTime? now}) async {
    final next = await ref
        .read(bossServiceProvider)
        .strike(now: now ?? DateTime.now());
    state = AsyncData<BossModel>(next);
    return next;
  }

  /// Revives a defeated boss.
  Future<BossModel> revive() async {
    final next = await ref.read(bossServiceProvider).revive();
    state = AsyncData<BossModel>(next);
    return next;
  }

  /// A mission counts as a strike while the boss is actively engaged.
  Future<BossModel> completeMission(MissionCompletedEvent mission) async {
    final next = await ref
        .read(bossServiceProvider)
        .applyMissionCompletion(mission: mission);
    state = AsyncData<BossModel>(next);
    return next;
  }

  /// A goal completion unlocks a dormant boss into the fight.
  Future<BossModel> awaken() async {
    final next = await ref.read(bossServiceProvider).awaken();
    state = AsyncData<BossModel>(next);
    return next;
  }
}

/// Listens on the domain bus and forwards completed missions to the boss.
/// Dormant or defeated bosses ignore the strikes. Watched by the pipeline.
final bossMissionRelayProvider = Provider<StreamSubscription<DomainEvent>>(
  (ref) {
    final bus = ref.watch(domainEventBusProvider);
    final subscription = listenForGame(bus, (event) {
      if (event case MissionCompletedEvent()) {
        unawaited(
          ref.read(bossStateProvider.notifier).completeMission(event),
        );
      }
    });
    ref.onDispose(subscription.cancel);
    return subscription;
  },
);

/// Listens on the domain bus for goal completions and unlocks a dormant
/// boss; already-active fights are left alone. Watched by the pipeline.
final bossGoalRelayProvider = Provider<StreamSubscription<DomainEvent>>(
  (ref) {
    final bus = ref.watch(domainEventBusProvider);
    final subscription = listenForGame(bus, (event) {
      if (event case GoalCompletedEvent()) {
        unawaited(ref.read(bossStateProvider.notifier).awaken());
      }
    });
    ref.onDispose(subscription.cancel);
    return subscription;
  },
);