import 'package:ascend/features/goals/models/goal_model.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// A single goal row: progress ring, title, and a completion toggle.
class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    this.onToggle,
    this.onRemove,
  });

  final GoalModel goal;
  final VoidCallback? onToggle;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: _ProgressRing(progress: goal.progress, done: goal.isDone),
        title: Text(
          goal.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: goal.isDone ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: Icon(
                goal.isDone ? Icons.undo : Icons.check_circle_outline,
                color: goal.isDone ? AppColors.success : null,
              ),
              tooltip: goal.isDone ? 'Reopen' : 'Complete',
              onPressed: onToggle,
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove',
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.done});

  final double progress;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 36,
      child: CircularProgressIndicator(
        value: done ? 1 : progress,
        strokeWidth: 3,
        color: done ? AppColors.success : AppColors.primary,
        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
      ),
    );
  }
}