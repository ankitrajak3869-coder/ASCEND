import 'package:ascend/features/mentor/models/mentor_entry.dart';

/// Port for conversation history.
abstract interface class MentorRepository {
  /// Newest first.
  Future<List<MentorEntry>> history();

  /// Appends an entry; implementations may trim the tail.
  Future<void> append(MentorEntry entry);

  /// Clears the entire conversation.
  Future<void> clear();
}