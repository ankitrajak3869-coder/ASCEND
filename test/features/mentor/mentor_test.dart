import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/mentor/data/local_mentor_repository.dart';
import 'package:ascend/features/mentor/domain/mentor_domain.dart';
import 'package:ascend/features/mentor/services/mentor_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MentorService service;
  late LocalMentorRepository repository;
  final at = DateTime(2026, 8, 3, 12);

  setUp(() {
    repository = LocalMentorRepository(storage: InMemorySecureStorageService());
    service = MentorService(repository: repository);
  });

  group('ask', () {
    test('appends the question and a mentor reply', () async {
      final reply = await service.ask(
        question: 'Should I push or rest?',
        topic: MentorTopic.planning,
        now: at,
      );

      expect(reply.fromMentor, isTrue);
      final history = await service.history();
      expect(history, hasLength(2));
    });

    test('replies are deterministic per question text', () async {
      final first = await service.ask(
        question: 'Plan my day?',
        topic: MentorTopic.planning,
        now: at,
      );
      final second = await service.ask(
        question: 'Plan my day?',
        topic: MentorTopic.planning,
        now: at.add(const Duration(minutes: 1)),
      );

      expect(second.text, first.text);
    });

    test('mentor echoes the player name when provided', () async {
      final reply = await service.ask(
        question: 'How do I focus?',
        topic: MentorTopic.focus,
        playerName: 'Kaira',
        now: at,
      );
      expect(reply.text, startsWith('Kaira, '));
    });

    test('blank prompts are recorded but never crash', () async {
      final reply = await service.ask(
        question: '   ',
        topic: MentorTopic.reflection,
        now: at,
      );
      final history = await service.history();
      expect(history, hasLength(2));
      expect(reply.fromMentor, isTrue);
    });

test('history is capped at MentorRules.maxHistory', () async {
      for (var i = 0; i < 40; i++) {
        await service.ask(
          question: 'q$i',
          topic: MentorTopic.planning,
          now: at,
        );
      }
      final history = await service.history();
      expect(history.length, MentorRules.maxHistory);
      // Oldest entries (the first conversation) fell off the cap.
      expect(history.any((entry) => entry.text.endsWith('q0')), isFalse);
    });
  });

  group('repository', () {
    test('history returns newest entries first', () async {
      await service.ask(
        question: 'first',
        topic: MentorTopic.planning,
        now: at,
      );
      await service.ask(
        question: 'second',
        topic: MentorTopic.focus,
        now: at.add(const Duration(minutes: 5)),
      );

      final history = await service.history();
      expect(
        history.first.createdAt.isAfter(history.last.createdAt),
        isTrue,
      );
      // The two newest entries belong to the "second" exchange.
      final newestTexts = history.take(2).map((entry) => entry.text).toList();
      expect(newestTexts, contains('second'));
      expect(
        newestTexts.any((text) => text == 'first'),
        isFalse,
      );
    });

    test('persists across repository instances', () async {
      final storage = InMemorySecureStorageService();
      final first = MentorService(
        repository: LocalMentorRepository(storage: storage),
      );
      await first.ask(question: 'hi', topic: MentorTopic.planning, now: at);

      final second = MentorService(
        repository: LocalMentorRepository(storage: storage),
      );
      expect(await second.history(), hasLength(2));
    });

    test('clear empties the conversation', () async {
      await service.ask(question: 'hi', topic: MentorTopic.planning, now: at);
      await service.clear();
      expect(await service.history(), isEmpty);
    });
  });
}