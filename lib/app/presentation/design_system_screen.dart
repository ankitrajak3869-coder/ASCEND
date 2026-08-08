import 'package:ascend/l10n/generated/app_localizations.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:ascend/shared/design/tokens/app_spacing.dart';
import 'package:flutter/material.dart';

/// Design System verification surface (Phase 1).
///
/// Renders every token group on the live theme so the team can review the
/// dark/light treatment before product screens land (Phase 3 replaces the
/// home route with the real Dashboard).
class DesignSystemScreen extends StatelessWidget {
  const DesignSystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(strings.designSystemTitle)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: <Widget>[
          Text(strings.designSystemSubtitle, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.xl),
          const _ColorsSection(),
          const _TypographySection(),
          const _SpacingSection(),
          const _RadiusSection(),
          const _CardDemo(),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
    );
  }
}

class _ColorsSection extends StatelessWidget {
  const _ColorsSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final swatches = <(String, Color)>[
      ('background', AppColors.background),
      ('surface', AppColors.surface),
      ('elevated', AppColors.surfaceElevated),
      ('outline', AppColors.outline),
      ('primary', AppColors.primary),
      ('bright', AppColors.primaryBright),
      ('success', AppColors.success),
      ('warning', AppColors.warning),
      ('danger', AppColors.danger),
      ('gold', AppColors.gold),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.designColors),
        Wrap(
          spacing: AppSpacing.md,
          runSpacing: AppSpacing.md,
          children: <Widget>[
            for (final (name, color) in swatches)
              Tooltip(
                message: name,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(color: AppColors.outline),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _TypographySection extends StatelessWidget {
  const _TypographySection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.designTypography),
        const Text('Space Grotesk 44 / w700'),
        const Text('Space Grotesk 32 / w700'),
        const Text('Space Grotesk 24 / w700'),
        const Text('Space Grotesk 20 / w600'),
        const SizedBox(height: AppSpacing.sm),
        const Text('Inter 16 / regular — the workhorse body copy. Line height 1.5.'),
        const Text('Inter 14 / regular — secondary copy.'),
        const Text('Inter 12 / regular — captions.'),
        const Text('Inter 15 / w600 — buttons.'),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _SpacingSection extends StatelessWidget {
  const _SpacingSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.designSpacing),
        for (final step in const <(String, double)>[
          ('8', AppSpacing.xs),
          ('16', AppSpacing.md),
          ('24', AppSpacing.lg),
          ('32', AppSpacing.xl),
        ])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  child: Text(step.$1, style: Theme.of(context).textTheme.labelMedium),
                ),
                Container(
                  height: 12,
                  width: step.$2,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _RadiusSection extends StatelessWidget {
  const _RadiusSection();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.designRadius),
        Row(
          children: <Widget>[
            for (final radius in const <double>[
              AppRadii.sm,
              AppRadii.md,
              AppRadii.lg,
              AppRadii.xl,
            ])
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    borderRadius: BorderRadius.circular(radius),
                    border: Border.all(color: AppColors.outline),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

class _CardDemo extends StatelessWidget {
  const _CardDemo();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(strings.designCardDemoTitle),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bolt_rounded, color: Colors.white),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Morning focus: 25 min deep work',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        strings.designCardDemoBody,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}