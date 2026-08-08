import 'package:ascend/features/skill_tree/domain/skill_tree_domain.dart';
import 'package:ascend/features/skill_tree/models/skill_tree_snapshot.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// A single tree node: locked or unlocked with its description.
class SkillNodeCard extends StatelessWidget {
  const SkillNodeCard({
    super.key,
    required this.node,
    required this.snapshot,
  });

  final SkillTreeNode node;
  final SkillTreeSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final unlocked = snapshot.isUnlocked(node.id);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          unlocked ? Icons.blur_on_rounded : Icons.lock_outline,
          color: unlocked ? AppColors.primaryBright : null,
        ),
        title: Text(
          node.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: unlocked ? null : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Text(node.description),
        trailing: unlocked
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : null,
      ),
    );
  }
}