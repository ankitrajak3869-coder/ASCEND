import 'dart:async';

import 'package:ascend/features/missions/models/mission_model.dart';
import 'package:ascend/features/missions/providers/mission_providers.dart';
import 'package:ascend/features/missions/widgets/mission_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Today's mission roster with complete/skip affordances.
class MissionsScreen extends ConsumerWidget {
  const MissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final daily = ref.watch(dailyMissionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Missions')),
      body: daily.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Could not load missions'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(dailyMissionsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (missions) => _MissionList(
          missions: missions,
          onComplete: (mission) => unawaited(_complete(ref, mission)),
          onSkip: (mission) => unawaited(_skip(ref, mission)),
        ),
      ),
    );
  }

  Future<void> _complete(WidgetRef ref, MissionModel mission) async {
    final catalog = ref.read(missionCatalogProvider);
    await catalog.complete(mission.id);
    ref.invalidate(dailyMissionsProvider);
  }

  Future<void> _skip(WidgetRef ref, MissionModel mission) async {
    final catalog = ref.read(missionCatalogProvider);
    await catalog.skip(mission.id);
    ref.invalidate(dailyMissionsProvider);
  }
}

class _MissionList extends StatelessWidget {
  const _MissionList({
    required this.missions,
    required this.onComplete,
    required this.onSkip,
  });

  final List<MissionModel> missions;
  final ValueChanged<MissionModel> onComplete;
  final ValueChanged<MissionModel> onSkip;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: missions.length,
      itemBuilder: (context, index) {
        final mission = missions[index];
        return MissionCard(
          mission: mission,
          onComplete: () => onComplete(mission),
          onSkip: () => onSkip(mission),
        );
      },
    );
  }
}