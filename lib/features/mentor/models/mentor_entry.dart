import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:flutter/foundation.dart';

/// One message in the mentor conversation.
@immutable
final class MentorEntry {
  const MentorEntry({
    required this.id,
    required this.topic,
    required this.text,
    required this.fromMentor,
    required this.createdAt,
  });

  factory MentorEntry.fromJson(Map<String, Object?> json) => MentorEntry(
    id: json['id'] as String,
    topic: _topic(json['topic']),
    text: json['text'] as String,
    fromMentor: json['fromMentor'] as bool,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
  );

  final String id;
  final MentorTopic topic;
  final String text;
  final bool fromMentor;
  final DateTime createdAt;

  MentorEntry copyWith({bool? fromMentor, String? text}) {
    return MentorEntry(
      id: id,
      topic: topic,
      text: text ?? this.text,
      fromMentor: fromMentor ?? this.fromMentor,
      createdAt: createdAt,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'id': id,
    'topic': topic.name,
    'text': text,
    'fromMentor': fromMentor,
    'createdAt': createdAt.millisecondsSinceEpoch,
  };
}

MentorTopic _topic(Object? raw) {
  for (final topic in MentorTopic.values) {
    if (topic.name == raw) {
      return topic;
    }
  }
  return MentorTopic.reflection;
}