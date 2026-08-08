/// Mentor domain: topics, reply tuning and history bounds.
library;

/// What the mentor is coaching on.
enum MentorTopic { planning, focus, reflection }

/// Conversation bounds.
abstract final class MentorRules {
  /// Conversations are capped to keep local storage tiny.
  static const int maxHistory = 60;
}

/// A topic the mentor does not coach on.
final class UnknownMentorTopicException implements Exception {
  const UnknownMentorTopicException(this.topic);

  final String topic;

  @override
  String toString() => 'UnknownMentorTopicException($topic)';
}