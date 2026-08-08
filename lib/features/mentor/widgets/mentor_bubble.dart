import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:ascend/features/mentor/models/mentor_entry.dart';
import 'package:ascend/shared/design/tokens/app_colors.dart';
import 'package:flutter/material.dart';

/// One chat bubble, aligned by sender.
class MentorBubble extends StatelessWidget {
  const MentorBubble({
    super.key,
    required this.entry,
    this.onTap,
  });

  final MentorEntry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = !entry.fromMentor;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.surfaceElevated,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 2),
            bottomRight: Radius.circular(mine ? 2 : 16),
          ),
        ),
        child: Text(
          entry.text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: mine ? Colors.white : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Renders the topic as a short label chip.
class TopicChip extends StatelessWidget {
  const TopicChip({
    super.key,
    required this.topic,
    this.selected = false,
    this.onSelected,
  });

  final MentorTopic topic;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final label = switch (topic) {
      MentorTopic.planning => 'Plan',
      MentorTopic.focus => 'Focus',
      MentorTopic.reflection => 'Reflect',
    };
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
    );
  }
}