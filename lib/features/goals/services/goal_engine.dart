import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/models/goal_model.dart';
import 'package:ascend/features/goals/models/milestone_model.dart';
import 'package:ascend/features/goals/repositories/goal_repository.dart';

/// The goal engine: owns milestone planning and mission seeding.
///
/// Generation is pure and deterministic — it never consults the clock, an
/// id supplier or randomness; identical state yields identical plans. An AI
/// may later refine plans, but it plugs in above this engine and never owns
/// the primary generation logic.
final class GoalEngine {
  const GoalEngine({
    required this.repository,
    this.events,
  });

  final GoalRepository repository;

  /// Bus for [GoalCompletedEvent] announcements.
  final DomainEventBus? events;

  /// The deterministic milestone plan for any goal.
  static List<GoalMilestone> planMilestones() {
    return <GoalMilestone>[
      for (var i = 0; i < GoalRules.milestonesPerGoal; i++)
        GoalMilestone(
          index: i,
          title: GoalRules.milestonePhaseTitles[i],
        ),
    ];
  }

  /// Seeds a mission for the first open milestone of an active goal.
  ///
  /// Deterministic: the mission id derives only from the goal id and the
  /// milestone index, so replays raise the same mission. No mission is
  /// raised for a completed goal or a goal without milestones.
  MissionSeed? seedFor(GoalModel goal) {
    if (goal.status != GoalStatus.active || goal.milestones.isEmpty) {
      return null;
    }
    for (final milestone in goal.milestones) {
      if (!milestone.isDone) {
        return MissionSeed(
          missionId: 'gm-${goal.id}-${milestone.index}',
          goalId: goal.id,
          milestoneIndex: milestone.index,
          title: '${milestone.title}: ${goal.title}',
          description: 'Step ${milestone.index + 1} of ${goal.title}.',
          xpReward: GoalRules.milestoneXpReward,
        );
      }
    }
    return null;
  }

  /// The current plan: one mission per active goal's first open milestone.
  Future<List<MissionSeed>> plan() async {
    final goals = await repository.findAll();
    final seeds = <MissionSeed>[];
    for (final goal in goals) {
      final seed = seedFor(goal);
      if (seed != null) {
        seeds.add(seed);
      }
    }
    return seeds;
  }

  /// Advances the goal a completed mission belongs to.
  ///
  /// Marks the milestone done, recomputes progress and, when the last open
  /// milestone closes, marks the goal done and announces [GoalCompletedEvent]
  /// (idempotent: unknown goals, done milestones and done goals never emit).
  /// Returns the updated goal, or null when nothing advanced.
  Future<GoalModel?> advanceMilestone(
    MissionCompletedEvent event, {
    DateTime? now,
  }) async {
    final goalId = event.goalId;
    final milestoneIndex = event.milestoneIndex;
    if (goalId == null || milestoneIndex == null) {
      return null;
    }
    final GoalModel goal;
    try {
      goal = await repository.findById(goalId);
    } on GoalNotFoundException {
      return null;
    }
    if (goal.status != GoalStatus.active) {
      return null;
    }
    final plan = goal.milestones;
    if (plan.isEmpty) {
      return null;
    }
    if (milestoneIndex < 0 || milestoneIndex >= plan.length) {
      return null;
    }
    if (plan[milestoneIndex].isDone) {
      return null;
    }

    final advanced = <GoalMilestone>[
      for (final milestone in plan)
        milestone.index == milestoneIndex
            ? milestone.copyWith(status: MilestoneStatus.done)
            : milestone,
    ];
    final done = advanced.where((ms) => ms.isDone).length;
    final completedAll = done == plan.length;

    final updated = goal.copyWith(
      milestones: advanced,
      progress: completedAll
          ? GoalRules.maxProgress
          : done / plan.length,
      status: completedAll ? GoalStatus.done : goal.status,
    );
    await repository.save(updated);

    if (completedAll) {
      events?.emit(
        GoalCompletedEvent(
          goalId: goal.id,
          goalTitle: goal.title,
          completedAt: now ?? event.completedAt,
        ),
      );
    }
    return updated;
  }

  /// Reactivates a finished goal's last milestone so it can be planned and
  /// completed again. Returns the reopened goal, or null when not applicable.
  Future<GoalModel?> reopen(String goalId) async {
    final GoalModel goal;
    try {
      goal = await repository.findById(goalId);
    } on GoalNotFoundException {
      return null;
    }
    if (goal.status != GoalStatus.done || goal.milestones.isEmpty) {
      return null;
    }
    final last = goal.milestones.last;
    final plan = <GoalMilestone>[
      for (final milestone in goal.milestones)
        milestone.index == last.index
            ? milestone.copyWith(status: MilestoneStatus.active)
            : milestone,
    ];
    final done = plan.where((ms) => ms.isDone).length;
    final updated = goal.copyWith(
      milestones: plan,
      progress: done / plan.length,
      status: GoalStatus.active,
    );
    await repository.save(updated);
    return updated;
  }
}