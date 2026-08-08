/// Analytics domain: event kinds and buffer bounds.
library;

/// Buffer bounds for locally queued events.
abstract final class AnalyticsRules {
  /// Events kept on-device before a flush. Small by design.
  static const int maxBuffered = 100;
}

/// Logical event categories surfaced on the summary screen.
enum AnalyticsEventKind { session, action, progress }