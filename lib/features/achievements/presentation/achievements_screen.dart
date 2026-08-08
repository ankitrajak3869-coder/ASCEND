import 'package:ascend/features/achievements/providers/achievement_providers.dart';
import 'package:ascend/features/achievements/widgets/achievement_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Trophy rack: every achievement with live progress from the event pipeline.
class AchievementsScreen extends ConsumerWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trophiesAsync = ref.watch(achievementsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: trophiesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load achievements'),
        ),
        data: (trophies) => ListView.builder(
          itemCount: trophies.length,
          itemBuilder: (context, index) =>
              AchievementCard(achievement: trophies[index]),
        ),
      ),
    );
  }
}