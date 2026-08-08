import 'dart:async';

import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/features/skill_tree/data/local_skill_tree_repository.dart';
import 'package:ascend/features/skill_tree/models/skill_tree_snapshot.dart';
import 'package:ascend/features/skill_tree/repositories/skill_tree_repository.dart';
import 'package:ascend/features/skill_tree/services/skill_tree_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed skill tree repository.
final skillTreeRepositoryProvider = Provider<SkillTreeRepository>(
  (ref) => LocalSkillTreeRepository(storage: ref.watch(secureStorageProvider)),
);

/// Skill tree rules service.
final skillTreeServiceProvider = Provider<SkillTreeService>(
  (ref) => SkillTreeService(repository: ref.watch(skillTreeRepositoryProvider)),
);

/// The current skill tree state.
final skillTreeProvider =
    AsyncNotifierProvider<SkillTreeNotifier, SkillTreeSnapshot>(
      SkillTreeNotifier.new,
    );

/// The user's unlocked nodes.
final class SkillTreeNotifier extends AsyncNotifier<SkillTreeSnapshot> {
  @override
  Future<SkillTreeSnapshot> build() {
    return ref.watch(skillTreeServiceProvider).loadOrFresh();
  }

  /// Unlocks the next catalog node and refreshes state.
  Future<SkillTreeSnapshot> unlockNext() async {
    final updated = await ref.read(skillTreeServiceProvider).unlockNext();
    state = AsyncData<SkillTreeSnapshot>(updated);
    return updated;
  }
}

/// Unlocks a tree node every time a goal completes. Watched by the app
/// pipeline so it stays alive.
final skillTreeGoalRelayProvider = Provider<StreamSubscription<DomainEvent>>(
  (ref) {
    final bus = ref.watch(domainEventBusProvider);
    final subscription = listenForGame(bus, (event) {
      if (event case GoalCompletedEvent()) {
        unawaited(ref.read(skillTreeProvider.notifier).unlockNext());
      }
    });
    ref.onDispose(subscription.cancel);
    return subscription;
  },
);