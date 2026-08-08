import 'package:ascend/features/skill_tree/domain/skill_tree_domain.dart';
import 'package:ascend/features/skill_tree/providers/skill_tree_providers.dart';
import 'package:ascend/features/skill_tree/widgets/skill_node_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Skill tree: nodes unlocked one per completed goal, in catalog order.
class SkillTreeScreen extends ConsumerWidget {
  const SkillTreeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshotAsync = ref.watch(skillTreeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Skill Tree')),
      body: snapshotAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load the skill tree'),
        ),
        data: (snapshot) => ListView.builder(
          itemCount: SkillTreeRules.catalog.length,
          itemBuilder: (context, index) => SkillNodeCard(
            node: SkillTreeRules.catalog[index],
            snapshot: snapshot,
          ),
        ),
      ),
    );
  }
}