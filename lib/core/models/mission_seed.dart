import 'package:flutter/foundation.dart';

/// A planner's request to mint a goal-driven mission.
///
/// Produced by the goal engine (deterministic, no random/clock inputs beyond
/// the caller's explicit choices) and consumed by the missions feature. Pure
/// data on purpose: features must not import each other's domains, and core
/// is the only shared vocabulary.
@immutable
final class MissionSeed {
  const MissionSeed({
    required this.missionId,
    required this.goalId,
    required this.milestoneIndex,
    required this.title,
    required this.description,
    required this.xpReward,
  });

  final String missionId;
  final String goalId;
  final int milestoneIndex;
  final String title;
  final String description;
  final int xpReward;

  @override
  String toString() => 'MissionSeed($missionId)';
}