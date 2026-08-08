import 'package:ascend/features/achievements/providers/achievement_providers.dart';
import 'package:ascend/features/analytics/providers/analytics_providers.dart';
import 'package:ascend/features/boss/providers/boss_providers.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/goals/providers/goal_providers.dart';
import 'package:ascend/features/skill_tree/providers/skill_tree_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Watches every feature relay so the cross-feature event pipeline stays
/// alive for the whole app run. This file (app layer) is the only place
/// allowed to know about all relay providers at once.
abstract final class FeaturePipeline {
  /// Keeps each feature's relay subscribed for the container's lifetime.
  static void start(Ref ref) {
    ref.watch(characterProgressionRelayProvider);
    ref.watch(bossMissionRelayProvider);
    ref.watch(bossGoalRelayProvider);
    ref.watch(goalMissionRelayProvider);
    ref.watch(achievementsRelayProvider);
    ref.watch(skillTreeGoalRelayProvider);
    ref.watch(analyticsRelayProvider);
  }
}