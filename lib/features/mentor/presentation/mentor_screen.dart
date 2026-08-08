import 'dart:async';

import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:ascend/features/mentor/providers/mentor_providers.dart';
import 'package:ascend/features/mentor/widgets/mentor_bubble.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chat with the mentor. Deterministic replies, no facts invented.
class MentorScreen extends ConsumerStatefulWidget {
  const MentorScreen({super.key, this.playerName});

  /// Name echoed in replies when available (wired at composition root).
  final String? playerName;

  @override
  ConsumerState<MentorScreen> createState() => _MentorScreenState();
}

class _MentorScreenState extends ConsumerState<MentorScreen> {
  final TextEditingController _controller = TextEditingController();
  MentorTopic _topic = MentorTopic.reflection;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty) {
      return;
    }
    _controller.clear();
    FocusScope.of(context).unfocus();
    final actions = ref.read(mentorActionsProvider);
    await actions.ask(
      question: text,
      topic: _topic,
      playerName: widget.playerName,
    );
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(mentorHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mentor')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <MentorTopic>[
                MentorTopic.planning,
                MentorTopic.focus,
                MentorTopic.reflection,
              ].map((topic) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: TopicChip(
                    topic: topic,
                    selected: topic == _topic,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _topic = topic;
                        }
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: historyAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => const Center(
                child: Text('Could not load the conversation'),
              ),
              data: (entries) => ListView.builder(
                reverse: true,
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: entries.length,
                itemBuilder: (context, index) => MentorBubble(
                  entry: entries[index],
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => unawaited(_send()),
                      decoration: const InputDecoration(
                        hintText: 'Ask the mentor…',
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: () => unawaited(_send()),
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}