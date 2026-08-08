import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:ascend/features/boss/models/boss_model.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// Animated health bar for the boss fight.
class BossHealthBar extends StatelessWidget {
  const BossHealthBar({
    super.key,
    required this.boss,
    this.height = 18,
  });

  final BossModel boss;
  final double height;

  @override
  Widget build(BuildContext context) {
    final color = boss.phase == BossPhase.defeated
        ? AppColors.success
        : boss.phase == BossPhase.enraged
        ? AppColors.danger
        : AppColors.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: LinearProgressIndicator(
        value: boss.healthRatio,
        minHeight: height,
        color: color,
        backgroundColor: AppColors.surfaceElevated,
      ),
    );
  }
}

/// The boss's face depends on its phase.
class BossFace extends StatelessWidget {
  const BossFace({super.key, required this.phase, this.size = 96});

  final BossPhase phase;
  final double size;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (phase) {
      BossPhase.dormant => (
        Icons.cloud_outlined,
        AppColors.textMuted,
        'asleep',
      ),
      BossPhase.rumbling => (
        Icons.flare,
        AppColors.warning,
        'rumbling',
      ),
      BossPhase.enraged => (
        Icons.local_fire_department,
        AppColors.danger,
        'enraged',
      ),
      BossPhase.defeated => (
          Icons.verified_outlined,
          AppColors.gold,
          'defeated',
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surfaceElevated,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: size * 0.55),
        ),
        const SizedBox(height: 8),
        Text(label.toUpperCase(), style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}