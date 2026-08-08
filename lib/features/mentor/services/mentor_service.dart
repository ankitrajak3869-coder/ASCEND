import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:ascend/features/mentor/models/mentor_entry.dart';
import 'package:ascend/features/mentor/repositories/mentor_repository.dart';

/// Coaches the player with canned, deterministic replies per topic.
///
/// The mentor never invents facts about the player's day: replies come from
/// a fixed pool, selected locally from the question text, and may only echo
/// the player's own name back at them.
final class MentorService {
  const MentorService({required this.repository});

  final MentorRepository repository;

  Future<List<MentorEntry>> history() => repository.history();

  /// Records the player's question and returns the mentor's reply.
  Future<MentorEntry> ask({
    required String question,
    required MentorTopic topic,
    String? playerName,
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    final clean = question.trim();
    final userEntry = MentorEntry(
      id: 'msg-${at.microsecondsSinceEpoch}-u',
      topic: topic,
      text: clean.isEmpty ? '(empty prompt)' : clean,
      fromMentor: false,
      createdAt: at,
    );
    await repository.append(userEntry);

    final replyEntry = MentorEntry(
      id: 'msg-${at.microsecondsSinceEpoch}-m',
      topic: topic,
      text: _replyFor(clean, topic, playerName),
      fromMentor: true,
      createdAt: at.add(const Duration(milliseconds: 1)),
    );
    await repository.append(replyEntry);
    return replyEntry;
  }

  Future<void> clear() => repository.clear();

  static String _replyFor(String question, MentorTopic topic, String? name) {
    final pool = switch (topic) {
      MentorTopic.planning => _planningPool,
      MentorTopic.focus => _focusPool,
      MentorTopic.reflection => _reflectionPool,
    };
    final index = question.hashCode.abs() % pool.length;
    final base = pool[index];
    if (name == null || name.isEmpty) {
      return base;
    }
    return '$name, $base';
  }

  static const List<String> _planningPool = <String>[
    'break the plan into one step you can finish before tonight',
    'pick the single task whose completion unlocks the rest',
    'write the plan down; a plan you can see is a plan you keep',
  ];

  static const List<String> _focusPool = <String>[
    'put the phone in another room for the next 40 minutes',
    'one task, one window of time, nothing else open',
    'when your mind wanders, write the thought down and return',
  ];

  static const List<String> _reflectionPool = <String>[
    'name one thing that went better than you expected',
    'what you finished matters more than what you added to the list',
    'notice how far you moved this week, not how far you think you are',
  ];
}