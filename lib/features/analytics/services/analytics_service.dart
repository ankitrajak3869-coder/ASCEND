import 'package:ascend/features/analytics/domain/analytics_domain.dart';
import 'package:ascend/features/analytics/models/analytics_event.dart';
import 'package:ascend/features/analytics/repositories/analytics_repository.dart';

/// Records analytics locally when enabled.
///
/// When [enabled] is false every call is a no-op, so callers never branch on
/// the privacy toggle themselves.
final class AnalyticsService {
  const AnalyticsService({
    required this.repository,
    required this.enabled,
  });

  final AnalyticsRepository repository;
  final bool enabled;

  Future<void> track(
    String name, {
    AnalyticsEventKind kind = AnalyticsEventKind.action,
    Map<String, Object?> parameters = const <String, Object?>{},
    DateTime? now,
  }) async {
    if (!enabled) {
      return;
    }
    final event = AnalyticEventModel(
      name: name,
      kind: kind,
      parameters: parameters,
      recordedAt: now ?? DateTime.now(),
    );
    await repository.append(event);
  }

  Future<List<AnalyticEventModel>> buffered() => repository.buffered();

  /// Pops the local queue (the remote flush is a later phase).
  Future<AnalyticsFlushResult> flush() async {
    final events = await repository.buffered();
    await repository.clear();
    return AnalyticsFlushResult(flushed: events.length);
  }
}

/// Outcome of a flush.
final class AnalyticsFlushResult {
  const AnalyticsFlushResult({required this.flushed});

  final int flushed;
}