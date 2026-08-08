import 'package:ascend/features/achievements/domain/achievement_domain.dart';
import 'package:ascend/features/achievements/models/achievement_model.dart';
import 'package:ascend/features/achievements/repositories/achievement_repository.dart';

/// Achievement counters: seeds the catalog, applies progress, honors
/// clamp/unlock-once and persists every mutation.
final class AchievementService {
  const AchievementService({required this.repository});

  final AchievementRepository repository;

  /// The seeded trophy rack, in a stable display order.
  static const List<AchievementModel> catalog = <AchievementModel>[
    AchievementModel(
      id: 'first_step',
      title: 'First Step',
      description: 'Complete your first mission.',
      kind: AchievementKind.missionsCompleted,
      target: AchievementRules.firstStepTarget,
    ),
    AchievementModel(
      id: 'weekly_roster',
      title: 'Weekly Roster',
      description: 'Complete 25 missions.',
      kind: AchievementKind.missionsCompleted,
      target: AchievementRules.weeklyRosterTarget,
    ),
    AchievementModel(
      id: 'xp_momentum',
      title: 'Momentum',
      description: 'Earn 500 XP from missions.',
      kind: AchievementKind.totalXp,
      target: AchievementRules.xpMomentumTarget,
    ),
    AchievementModel(
      id: 'boss_slayer',
      title: 'Boss Slayer',
      description: 'Defeat the boss.',
      kind: AchievementKind.bossesDefeated,
      target: AchievementRules.bossSlayerTarget,
    ),
    AchievementModel(
      id: 'first_goal',
      title: 'First Goal',
      description: 'Complete your first goal.',
      kind: AchievementKind.goalsCompleted,
      target: AchievementRules.firstGoalTarget,
    ),
    AchievementModel(
      id: 'goal_architect',
      title: 'Goal Architect',
      description: 'Complete 5 goals.',
      kind: AchievementKind.goalsCompleted,
      target: AchievementRules.goalArchitectTarget,
    ),
  ];

  /// Loads the rack, sealing in the seeded catalog on first run.
  Future<List<AchievementModel>> loadOrSeed() async {
    final stored = await repository.load();
    if (stored.isNotEmpty) {
      return stored;
    }
    await repository.save(catalog);
    return catalog;
  }

  /// Advances every trophy of [kind] by [amount]; see [applyProgresses]
  /// for the shared semantics.
  Future<List<AchievementModel>> applyProgress(
    AchievementKind kind,
    int amount, {
    DateTime? now,
  }) {
    return applyProgresses(<AchievementKind, int>{kind: amount}, now: now);
  }

  /// Advances several counters in one atomic batch so concurrent callers
  /// never partially persist (one save, one render).
  ///
  /// Progress never exceeds the target, and an unlocked trophy never
  /// re-stamps its unlock time. All-zero batches are no-ops.
  Future<List<AchievementModel>> applyProgresses(
    Map<AchievementKind, int> progress, {
    DateTime? now,
  }) async {
    if (progress.values.every((amount) => amount <= 0)) {
      return loadOrSeed();
    }
    final rack = await loadOrSeed();
    final clock = now ?? DateTime.now();
    final updated = rack
        .map((trophy) {
          final amount = progress[trophy.kind] ?? 0;
          if (amount <= 0) {
            return trophy;
          }
          final current = (trophy.current + amount) > trophy.target
              ? trophy.target
              : trophy.current + amount;
          final unlockTime = trophy.isUnlocked
              ? trophy.unlockedAt
              : (current >= trophy.target ? clock : null);
          return trophy.copyWith(current: current, unlockedAt: unlockTime);
        })
        .toList();
    await repository.save(updated);
    return updated;
  }
}