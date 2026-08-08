import 'package:ascend/features/achievements/models/achievement_model.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// A single trophy row: lock icon, title and progress to the target.
class AchievementCard extends StatelessWidget {
  const AchievementCard({super.key, required this.achievement});

  final AchievementModel achievement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: Icon(
          achievement.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
          color: achievement.isUnlocked ? AppColors.gold : null,
        ),
        title: Text(
          achievement.title,
          style: theme.textTheme.titleMedium?.copyWith(
            color: achievement.isUnlocked
                ? null
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(achievement.description),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.progress,
                minHeight: 5,
                color: achievement.isUnlocked ? AppColors.success : AppColors.primary,
                backgroundColor: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ],
        ),
        trailing: Text(
          achievement.isUnlocked
              ? 'Achieved'
              : '${achievement.current}/${achievement.target}',
          style: theme.textTheme.labelMedium?.copyWith(
            color: achievement.isUnlocked ? AppColors.success : null,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}