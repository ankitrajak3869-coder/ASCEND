import 'dart:async';

import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/features/character/data/local_character_repository.dart';
import 'package:ascend/features/character/domain/character_domain.dart';
import 'package:ascend/features/character/models/character_profile.dart';
import 'package:ascend/features/character/repositories/character_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed character repository.
final characterRepositoryProvider = Provider<CharacterRepository>(
  (ref) => LocalCharacterRepository(storage: ref.watch(secureStorageProvider)),
);

/// Current profile, seeded with a fresh adventurer on first load.
final characterProfileProvider =
    AsyncNotifierProvider<CharacterProfileNotifier, CharacterProfile>(
      CharacterProfileNotifier.new,
    );

/// The user's avatar and progression state.
final class CharacterProfileNotifier
    extends AsyncNotifier<CharacterProfile> {
  @override
  Future<CharacterProfile> build() async {
    final repository = ref.watch(characterRepositoryProvider);
    final existing = await repository.load();
    if (existing != null) {
      return existing;
    }
    final fresh = CharacterProfile.fresh();
    await repository.save(fresh);
    return fresh;
  }

  /// Awards [amount] XP and recomputes the level.
  Future<CharacterProfile> awardXp(int amount) async {
    final current = state.value ?? await build();
    final repository = ref.read(characterRepositoryProvider);
    final leveled = current.copyWith(
      xp: current.xp + amount,
      level: LevelCurve.levelAt(current.xp + amount),
    );
    await repository.save(leveled);
    state = AsyncData<CharacterProfile>(leveled);
    return leveled;
  }

  /// Renames the profile (blank rejected).
  Future<CharacterProfile> rename(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('name must not be blank');
    }
    final current = state.value ?? await build();
    final renamed = current.copyWith(name: trimmed);
    await ref.read(characterRepositoryProvider).save(renamed);
    state = AsyncData<CharacterProfile>(renamed);
    return renamed;
  }
}

/// Listens on the domain bus and awards XP whenever a mission completes.
///
/// This relay is the only place in the character feature allowed to consume
/// events from other features. Watched by the app pipeline so it stays alive.
final characterProgressionRelayProvider =
    Provider<StreamSubscription<DomainEvent>>((ref) {
      final bus = ref.watch(domainEventBusProvider);
      final subscription = listenForGame(bus, (event) {
        if (event case MissionCompletedEvent(:final xpReward)) {
          unawaited(
            ref.read(characterProfileProvider.notifier).awardXp(xpReward),
          );
        }
      });
      ref.onDispose(subscription.cancel);
      return subscription;
    });