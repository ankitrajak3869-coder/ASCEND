import 'package:ascend/features/analytics/domain/analytics_domain.dart';
import 'package:ascend/features/analytics/models/analytics_event.dart';
import 'package:flutter/material.dart';

/// Summary card for the analytics screen: counts + a flush action.
class UsageSummaryTile extends StatelessWidget {
  const UsageSummaryTile({
    super.key,
    required this.buffered,
    this.onFlush,
  });

  final List<AnalyticEventModel> buffered;
  final VoidCallback? onFlush;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final last = buffered.isEmpty ? null : buffered.first;
    final byKind = <AnalyticsEventKind, int>{};
    for (final event in buffered) {
      byKind.update(event.kind, (count) => count + 1, ifAbsent: () => 1);
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Local analytics buffer', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(
              '${buffered.length} events waiting',
              style: theme.textTheme.bodyMedium,
            ),
            if (last != null)
              Text(
                'Last: ${last.name} at ${last.recordedAt.toIso8601String()}',
                style: theme.textTheme.bodySmall,
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: byKind.entries.map((entry) {
                return Chip(
                  label: Text('${entry.key.name}: ${entry.value}'),
                );
              }).toList(),
            ),
            if (onFlush != null)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onFlush,
                  child: const Text('Flush now'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}