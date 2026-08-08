import 'package:ascend/features/analytics/domain/analytics_domain.dart';
import 'package:flutter/foundation.dart';

/// One locally buffered analytics event.
@immutable
final class AnalyticEventModel {
  const AnalyticEventModel({
    required this.name,
    required this.kind,
    required this.parameters,
    required this.recordedAt,
  });

  factory AnalyticEventModel.fromJson(Map<String, Object?> json) =>
      AnalyticEventModel(
        name: json['name'] as String,
        kind: _kind(json['kind']),
        parameters: (json['parameters'] as Map<String, Object?>?) ??
            const <String, Object?>{},
        recordedAt: DateTime.fromMillisecondsSinceEpoch(
          json['recordedAt'] as int,
        ),
      );

  final String name;
  final AnalyticsEventKind kind;
  final Map<String, Object?> parameters;
  final DateTime recordedAt;

  Map<String, Object?> toJson() => <String, Object?>{
    'name': name,
    'kind': kind.name,
    'parameters': parameters,
    'recordedAt': recordedAt.millisecondsSinceEpoch,
  };

  @override
  String toString() => 'AnalyticEventModel($name, ${kind.name})';
}

AnalyticsEventKind _kind(Object? raw) {
  for (final kind in AnalyticsEventKind.values) {
    if (kind.name == raw) {
      return kind;
    }
  }
  return AnalyticsEventKind.session;
}