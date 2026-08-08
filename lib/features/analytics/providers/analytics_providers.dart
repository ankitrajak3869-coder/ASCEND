import 'dart:async';

import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/features/analytics/data/local_analytics_repository.dart';
import 'package:ascend/features/analytics/domain/analytics_domain.dart';
import 'package:ascend/features/analytics/models/analytics_event.dart';
import 'package:ascend/features/analytics/repositories/analytics_repository.dart';
import 'package:ascend/features/analytics/services/analytics_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed analytics repository.
final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => LocalAnalyticsRepository(storage: ref.watch(secureStorageProvider)),
);

/// Whether telemetry is on. Default enabled; the app composition root binds
/// it to the settings feature's privacy toggle.
final analyticsEnabledProvider = Provider<bool>((ref) => true);

/// Analytics service, enabled follows the [analyticsEnabledProvider] port.
final analyticsServiceProvider = Provider<AnalyticsService>(
  (ref) => AnalyticsService(
    repository: ref.watch(analyticsRepositoryProvider),
    enabled: ref.watch(analyticsEnabledProvider),
  ),
);

/// Buffered events for the summary screen.
final bufferedEventsProvider = FutureProvider<List<AnalyticEventModel>>(
  (ref) => ref.watch(analyticsServiceProvider).buffered(),
);

/// Number of buffered events for badges.
final bufferedCountProvider = FutureProvider<int>(
  (ref) async => (await ref.watch(bufferedEventsProvider.future)).length,
);

/// Listens on the domain bus and records cross-feature milestones.
/// Watched by the pipeline so it stays alive.
final analyticsRelayProvider = Provider<StreamSubscription<DomainEvent>>(
  (ref) {
    final bus = ref.watch(domainEventBusProvider);
    final service = ref.read(analyticsServiceProvider);
    final subscription = listenForGame(bus, (event) {
      switch (event) {
        case MissionCompletedEvent(:final isWeekly, :final xpReward):
          unawaited(
            service.track(
              'mission_completed',
              kind: AnalyticsEventKind.progress,
              parameters: <String, Object?>{'weekly': isWeekly, 'xp': xpReward},
            ),
          );
          break;
        case BossDefeatedEvent():
          unawaited(
            service.track(
              'boss_defeated',
              kind: AnalyticsEventKind.progress,
            ),
          );
          break;
        case GoalCompletedEvent():
          // The AI review trigger: a finished goal is staged as telemetry
          // for the (later) review phase to consume.
          unawaited(
            service.track(
              'goal_completed',
              kind: AnalyticsEventKind.progress,
            ),
          );
          break;
      }
    });
    ref.onDispose(subscription.cancel);
    return subscription;
  },
);