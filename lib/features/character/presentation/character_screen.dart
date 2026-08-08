import 'dart:async';

import 'package:ascend/features/character/models/character_profile.dart';
import 'package:ascend/features/character/providers/character_providers.dart';
import 'package:ascend/features/character/widgets/character_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Character sheet: avatar, name, level bar and rename affordance.
class CharacterScreen extends ConsumerWidget {
  const CharacterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(characterProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Character'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: () => _promptRename(context, ref),
          ),
        ],
      ),
body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(
          child: Text('Failed to load profile'),
        ),
        data: (profile) => _ProfileSheet(profile: profile),
      ),
    );
  }

  Future<void> _promptRename(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(
      text: ref.read(characterProfileProvider).value?.name ?? '',
    );
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename character'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'New name'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null) {
      return;
    }
    final notifier = ref.read(characterProfileProvider.notifier);
    await notifier.rename(name);
  }
}

class _ProfileSheet extends StatelessWidget {
  const _ProfileSheet({required this.profile});

  final CharacterProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: <Widget>[
        const Spacer(),
        CharacterAvatar(profile: profile, radius: 44),
        const SizedBox(height: 16),
        Text(profile.name, style: theme.textTheme.headlineMedium),
        const SizedBox(height: 4),
        Text(
          'Level ${profile.level}',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        const Spacer(),
      ],
    );
  }
}