import 'package:ascend/core/di/providers.dart';
import 'package:ascend/features/mentor/data/local_mentor_repository.dart';
import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:ascend/features/mentor/models/mentor_entry.dart';
import 'package:ascend/features/mentor/repositories/mentor_repository.dart';
import 'package:ascend/features/mentor/services/mentor_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed mentor repository.
final mentorRepositoryProvider = Provider<MentorRepository>(
  (ref) => LocalMentorRepository(storage: ref.watch(secureStorageProvider)),
);

/// Mentor coaching service.
final mentorServiceProvider = Provider<MentorService>(
  (ref) => MentorService(repository: ref.watch(mentorRepositoryProvider)),
);

/// The conversation, newest first.
final mentorHistoryProvider = FutureProvider<List<MentorEntry>>(
  (ref) => ref.watch(mentorServiceProvider).history(),
);

/// Player name echoed by the mentor. Default null; overridden at the app
/// composition root from the character feature.
final mentorPlayerNameProvider = Provider<String?>((ref) => null);

/// Sends a question and refreshes the history.
final mentorActionsProvider = Provider<MentorActions>(
  (ref) => MentorActions(ref),
);

final class MentorActions {
  const MentorActions(this.ref);

  final Ref ref;

  Future<void> ask({
    required String question,
    MentorTopic topic = MentorTopic.reflection,
    String? playerName,
  }) async {
    await ref
        .read(mentorServiceProvider)
        .ask(question: question, topic: topic, playerName: playerName);
    ref.invalidate(mentorHistoryProvider);
  }
}