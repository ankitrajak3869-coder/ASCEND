/// Domain events: pure data broadcast across features.
///
/// Events are intentionally primitive (no model references) so any layer can
/// emit or consume them without importing another feature. They are the only
/// channel by which features influence each other.
library;

import 'dart:async';

import 'package:ascend/core/models/stat_kind.dart';
import 'package:flutter/foundation.dart' show debugPrint;

/// Marker for application domain events.
sealed class DomainEvent {
  const DomainEvent();
}

/// A mission was completed (emitted by the missions feature).
final class MissionCompletedEvent extends DomainEvent {
  const MissionCompletedEvent({
    required this.missionId,
    required this.missionTitle,
    required this.xpReward,
    required this.isWeekly,
    required this.completedAt,
    this.statGains = const <StatGain>[],
    this.goalId,
    this.milestoneIndex,
  });

  final String missionId;
  final String missionTitle;
  final int xpReward;
  final bool isWeekly;
  final DateTime completedAt;

  /// Character stat contributions the player earned with this mission.
  /// Packaged as the shared vocabulary so listeners need no mission imports.
  final List<StatGain> statGains;

  /// Set when the mission was minted by the goal engine.
  final String? goalId;

  /// Index of the goal milestone the mission was minted for.
  final int? milestoneIndex;

  @override
  String toString() => 'MissionCompletedEvent($missionId, +$xpReward xp)';
}

/// The boss was defeated (emitted by the boss feature).
final class BossDefeatedEvent extends DomainEvent {
  const BossDefeatedEvent({required this.defeatedAt});

  final DateTime defeatedAt;

  @override
  String toString() => 'BossDefeatedEvent($defeatedAt)';
}

/// A goal reached completion (emitted by the goals feature).
final class GoalCompletedEvent extends DomainEvent {
  const GoalCompletedEvent({
    required this.goalId,
    required this.goalTitle,
    required this.completedAt,
  });

  final String goalId;
  final String goalTitle;
  final DateTime completedAt;

  @override
  String toString() => 'GoalCompletedEvent($goalId)';
}

/// Synchronous broadcast hub. [emit] notifies every subscriber inline, which
/// keeps integration flows deterministic in tests.
final class DomainEventBus {
  final StreamController<DomainEvent> _controller =
      StreamController<DomainEvent>.broadcast(sync: true);

  /// Publishes [event] to all subscribers. Closed buses are no-ops.
  void emit(DomainEvent event) {
    if (!_controller.isClosed) {
      _controller.add(event);
    }
  }

  /// The stream of all events.
  Stream<DomainEvent> events() => _controller.stream;

  /// Closes the hub (application shutdown).
  void dispose() => _controller.close();
}

/// A listener that isolates one feature: it may only touch its *own*
/// feature's services. Subscribers catch their own errors so a broken
/// listener never breaks the bus.
StreamSubscription<DomainEvent> listenForGame(
  DomainEventBus bus,
  void Function(DomainEvent event) onEvent,
) {
  return bus.events().listen((event) {
    try {
      onEvent(event);
    } on Object catch (error) {
      // One feature's failure must not corrupt the pipeline; the feature
      // surfaces the problem through its own notifier.
      debugPrint('event pipeline dropped handler error: $error');
    }
  });
}