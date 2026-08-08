import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/features/analytics/providers/analytics_providers.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/goals/providers/goal_providers.dart';
import 'package:ascend/features/mentor/providers/mentor_providers.dart';
import 'package:ascend/features/missions/providers/mission_providers.dart';
import 'package:ascend/features/settings/providers/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Cross-feature overrides. Features never import each other's domain; this
/// composition root (app layer) is the only place allowed to serve one
/// feature from another.
final featureBindings = <Override>[
  // Mentor ↔ character: the mentor echoes the player's own name.
  mentorPlayerNameProvider.overrideWith(
    (ref) => ref.watch(characterProfileProvider).valueOrNull?.name,
  ),
  // Analytics ↔ settings: telemetry honors the privacy toggle.
  analyticsEnabledProvider.overrideWith(
    (ref) => ref.watch(settingsProvider).valueOrNull?.analyticsEnabled ?? true,
  ),
  // Missions ← goals: the catalog honors the goal engine's milestone plan.
  // The goals feature proposes pure MissionSeed values; the missions feature
  // never learns about the goals feature.
  missionSeedSourceProvider.overrideWith(
    (ref) =>
        ref.watch(goalMissionPlanProvider).valueOrNull ??
        const <MissionSeed>[],
  ),
];