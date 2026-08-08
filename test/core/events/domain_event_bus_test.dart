import 'package:ascend/core/events/domain_events.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DomainEventBus', () {
    test('delivers to listeners synchronously in subscribe order', () {
      final bus = DomainEventBus();
      final seen = <String>[];
      bus.events().listen((event) => seen.add('a:${event.runtimeType}'));
      bus.events().listen((event) => seen.add('b:${event.runtimeType}'));
      final completed = DateTime(2026, 8, 3, 9);

      bus.emit(
        MissionCompletedEvent(
          missionId: 'm1',
          missionTitle: 'Run',
          xpReward: 50,
          isWeekly: false,
          completedAt: completed,
        ),
      );
      bus.emit(BossDefeatedEvent(defeatedAt: completed));

      expect(seen, <String>[
        'a:MissionCompletedEvent',
        'b:MissionCompletedEvent',
        'a:BossDefeatedEvent',
        'b:BossDefeatedEvent',
      ]);
    });

    test('cancelled subscriptions stop receiving', () {
      final bus = DomainEventBus();
      var received = 0;
      final sub = bus.events().listen((_) => received++);

      sub.cancel();
      bus.emit(BossDefeatedEvent(defeatedAt: DateTime(2026, 8, 4)));

      expect(received, 0);
    });

    test('dispose stops all listeners', () {
      final bus = DomainEventBus();
      var received = 0;
      bus.events().listen((_) => received++);

      bus.dispose();
      bus.emit(BossDefeatedEvent(defeatedAt: DateTime(2026, 8, 4)));

      expect(received, 0);
    });
  });

  group('listenForGame', () {
    test('isolates a throwing handler from the other listeners', () {
      final bus = DomainEventBus();
      final received = <DomainEvent>[];
      listenForGame(bus, (event) {
        if (event is MissionCompletedEvent) {
          throw StateError('relay exploded');
        }
      });
      bus.events().listen(received.add);

      final event = BossDefeatedEvent(defeatedAt: DateTime(2026, 8, 4));
      bus.emit(event);

      expect(received, <DomainEvent>[event]);
    });
  });
}