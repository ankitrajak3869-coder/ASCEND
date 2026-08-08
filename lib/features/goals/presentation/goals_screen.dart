import 'dart:async';

import 'package:ascend/features/goals/providers/goal_providers.dart';
import 'package:ascend/features/goals/widgets/goal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Life goals: list, create (respecting the active cap), complete, remove.
class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalsAsync = ref.watch(goalsProvider);
    final actions = ref.watch(goalActionsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Goals')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _promptCreate(context, ref),
        icon: const Icon(Icons.add),
        label: const Text('New goal'),
      ),
      body: goalsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load goals'),
        ),
        data: (goals) => ListView.builder(
          itemCount: goals.length,
          itemBuilder: (context, index) {
            final goal = goals[index];
            return GoalCard(
              goal: goal,
              onToggle: () => unawaited(actions.complete(goal.id)),
              onRemove: () => unawaited(actions.remove(goal.id)),
            );
          },
        ),
      ),
    );
  }

  Future<void> _promptCreate(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New goal'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'e.g. Finish the deck'),
          maxLength: 80,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.trim().isEmpty) {
      return;
    }
    try {
      await ref.read(goalActionsProvider).create(title);
    } on Object {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Keep at most 3 active goals open.'),
          ),
        );
      }
    }
  }
}