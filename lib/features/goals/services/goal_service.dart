import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/models/goal_model.dart';
import 'package:ascend/features/goals/repositories/goal_repository.dart';
import 'package:ascend/features/goals/services/goal_engine.dart';

/// Goal lifecycle rules: active quota, progress and completion.
final class GoalService {
  const GoalService({required this.repository});

  final GoalRepository repository;

  /// Creates a goal; throws [GoalQuotaReachedException] when the quota is
  /// full and blanks are rejected outright.
  Future<GoalModel> create({
    required String id,
    required String title,
    DateTime? now,
  }) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('goal title must not be blank');
    }
    final active = (await repository.findAll()).where(
      (goal) => goal.status == GoalStatus.active,
    );
    if (active.length >= GoalRules.maxActive) {
      throw GoalQuotaReachedException(active.length);
    }
    final goal = GoalModel(
      id: id,
      title: trimmed,
      createdAt: now ?? DateTime.now(),
      milestones: GoalEngine.planMilestones(),
    );
    await repository.save(goal);
    return goal;
  }

  /// Sets progress, clamped to 0..1.
  Future<GoalModel> setProgress(String id, double progress) async {
    final goal = await repository.findById(id);
    final clamped = progress.clamp(
      GoalRules.minProgress,
      GoalRules.maxProgress,
    );
    final updated = goal.copyWith(progress: clamped);
    await repository.save(updated);
    return updated;
  }

  /// Marks a goal done (progress forced to 1.0).
  Future<GoalModel> complete(String id) async {
    final goal = await repository.findById(id);
    final updated = goal.copyWith(status: GoalStatus.done, progress: 1);
    await repository.save(updated);
    return updated;
  }

  /// Reactivates a completed goal.
  Future<GoalModel> reopen(String id) async {
    final goal = await repository.findById(id);
    final updated = goal.copyWith(status: GoalStatus.active);
    await repository.save(updated);
    return updated;
  }

  Future<void> remove(String id) => repository.remove(id);
}