import 'dart:async';

import 'package:ascend/features/analytics/providers/analytics_providers.dart';
import 'package:ascend/features/analytics/widgets/usage_summary_tile.dart';
import 'package:ascend/features/settings/providers/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Privacy + telemetry readout: opt-out and local buffer state.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final buffered = ref.watch(bufferedEventsProvider);
    final prefsAsync = ref.watch(settingsProvider);
    final enabled = prefsAsync.valueOrNull?.analyticsEnabled ?? true;

    return Scaffold(
      appBar: AppBar(title: const Text('Telemetry')),
      body: ListView(
        children: <Widget>[
          SwitchListTile(
            title: const Text('Share anonymous analytics'),
            subtitle: const Text(
              'When off, nothing is recorded locally either.',
            ),
            value: enabled,
            onChanged: (value) => unawaited(
              ref.read(settingsProvider.notifier).setAnalytics(value),
            ),
          ),
          buffered.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => const ListTile(
              title: Text('Could not read the buffer'),
            ),
            data: (events) => UsageSummaryTile(
              buffered: events,
              onFlush: events.isEmpty
                  ? null
                  : () => unawaited(_flush(ref, context)),
            ),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('Local only'),
            subtitle: Text(
              'Events stay on this device until a sync backend exists.',
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _flush(WidgetRef ref, BuildContext context) async {
    final result = await ref.read(analyticsServiceProvider).flush();
    if (!context.mounted) {
      return;
    }
    ref.invalidate(bufferedEventsProvider);
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(content: Text('${result.flushed} events flushed')),
    );
  }
}