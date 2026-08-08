import 'dart:async';

import 'package:ascend/features/boss/models/boss_model.dart';
import 'package:ascend/features/boss/providers/boss_providers.dart';
import 'package:ascend/features/boss/widgets/boss_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The boss arena: strike the boss, grow the combo, end the phases.
class BossScreen extends ConsumerWidget {
  const BossScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bossAsync = ref.watch(bossStateProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('The Boss')),
      body: bossAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('The boss slipped away. Pull to retry.'),
        ),
        data: (boss) => _Arena(boss: boss),
      ),
    );
  }
}

class _Arena extends ConsumerWidget {
  const _Arena({required this.boss});

  final BossModel boss;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: <Widget>[
          const Spacer(),
          BossFace(phase: boss.phase),
          const SizedBox(height: 24),
          Text(
            'The Ascendant',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          BossHealthBar(boss: boss),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                '${boss.health}/${boss.maxHealth} HP',
                style: theme.textTheme.labelMedium,
              ),
              Text(
                'x${boss.combo} combo',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const Spacer(),
          if (boss.isDefeated)
            FilledButton.icon(
              onPressed: () =>
                  unawaited(ref.read(bossStateProvider.notifier).revive()),
              icon: const Icon(Icons.refresh),
              label: const Text('Revive the boss'),
            )
          else
            FilledButton.icon(
              onPressed: () =>
                  unawaited(ref.read(bossStateProvider.notifier).strike()),
              icon: const Icon(Icons.bolt),
              label: const Text('Strike'),
            ),
          const SizedBox(height: 16),
          Text(
            'Strikes landed: ${boss.strikes}',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}