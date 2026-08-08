import 'package:ascend/features/analytics/models/analytics_event.dart';

/// Port for the local event buffer.
abstract interface class AnalyticsRepository {
  /// Newest first.
  Future<List<AnalyticEventModel>> buffered();

  /// Appends an event, trimming to [AnalyticsRules.maxBuffered].
  Future<void> append(AnalyticEventModel event);

  /// Drops the buffer after an upload.
  Future<void> clear();
}