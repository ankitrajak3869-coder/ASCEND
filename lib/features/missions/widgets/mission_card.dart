import 'package:ascend/features/missions/models/mission_model.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// One row in the mission list: title, blurb, reward and completion affordance.
class MissionCard extends StatelessWidget {
  const MissionCard({
    super.key,
    required this.mission,
    this.onComplete,
    this.onSkip,
  });

  final MissionModel mission;
  final VoidCallback? onComplete;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = mission.isDone;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          done ? Icons.check_circle : Icons.radio_button_unchecked,
          color: done ? AppColors.success : AppColors.primary,
        ),
        title: Text(
          mission.title,
          style: theme.textTheme.titleMedium?.copyWith(
            decoration: done ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(mission.description),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Chip(
              label: Text('+${mission.xpReward} XP'),
              visualDensity: VisualDensity.compact,
            ),
            if (!done && onComplete != null)
              IconButton(
                icon: const Icon(Icons.check),
                tooltip: 'Complete',
                onPressed: onComplete,
              ),
            if (!done && onSkip != null)
              IconButton(
                icon: const Icon(Icons.close),
                tooltip: 'Skip',
                onPressed: onSkip,
              ),
          ],
        ),
      ),
    );
  }
}