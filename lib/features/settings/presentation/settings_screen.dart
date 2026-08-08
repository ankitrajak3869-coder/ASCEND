import 'dart:async';

import 'package:ascend/features/settings/domain/settings_domain.dart';
import 'package:ascend/features/settings/providers/settings_providers.dart';
import 'package:ascend/features/settings/widgets/setting_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Preferences: theme, motion, notifications, analytics.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: prefsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => const Center(
          child: Text('Could not load settings'),
        ),
        data: (prefs) {
          final notifier = ref.read(settingsProvider.notifier);
          return ListView(
            children: <Widget>[
              SettingTile(
                title: 'Theme',
                subtitle: 'Follow the system or pick a look.',
                trailing: SegmentedButton<ThemePreference>(
                  segments: const <ButtonSegment<ThemePreference>>[
                    ButtonSegment(
                      value: ThemePreference.system,
                      label: Text('Auto'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemePreference.light,
                      label: Text('Light'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemePreference.dark,
                      label: Text('Dark'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: <ThemePreference>{prefs.theme},
                  onSelectionChanged: (selection) => unawaited(
                    notifier.setTheme(selection.single),
                  ),
                ),
              ),
              SettingTile(
                title: 'Reduce motion',
                subtitle: 'Disable animated decorations.',
                trailing: Switch(
                  value: prefs.reduceMotion,
                  onChanged: (value) => unawaited(notifier.setReduceMotion(value)),
                ),
              ),
              SettingTile(
                title: 'Notifications',
                subtitle: 'Daily reminders to stay on the climb.',
                trailing: Switch(
                  value: prefs.notificationsEnabled,
                  onChanged: (value) => unawaited(notifier.setNotifications(value)),
                ),
              ),
              SettingTile(
                title: 'Anonymous analytics',
                subtitle: 'Crash reports and usage telemetry.',
                trailing: Switch(
                  value: prefs.analyticsEnabled,
                  onChanged: (value) => unawaited(notifier.setAnalytics(value)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}