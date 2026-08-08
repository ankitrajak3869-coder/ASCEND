import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/analytics/domain/analytics_domain.dart';
import 'package:ascend/features/analytics/models/analytics_event.dart';
import 'package:ascend/features/analytics/repositories/analytics_repository.dart';

/// Secure-storage backed queue, trimmed to [AnalyticsRules.maxBuffered].
final class LocalAnalyticsRepository implements AnalyticsRepository {
  LocalAnalyticsRepository({required this.storage});

  static const String key = 'feature.analytics.v1';

  final SecureStorageService storage;

  List<AnalyticEventModel>? _cache;
  bool _hydrated = false;

  Future<List<AnalyticEventModel>> _read() async {
    if (_hydrated) {
      return _cache ?? <AnalyticEventModel>[];
    }
    _hydrated = true;
    final raw = await storage.read(key);
    if (raw == null) {
      _cache = <AnalyticEventModel>[];
      return _cache!;
    }
    try {
      final decoded = jsonDecode(raw) as List<Object?>;
      _cache = decoded
          .cast<Map<String, Object?>>()
          .map(AnalyticEventModel.fromJson)
          .toList();
    } on Object {
      _cache = <AnalyticEventModel>[];
    }
    return _cache!;
  }

  Future<void> _write(List<AnalyticEventModel> events) async {
    _cache = events;
    await storage.write(
      key,
      jsonEncode(events.map((event) => event.toJson()).toList()),
    );
  }

  @override
  Future<List<AnalyticEventModel>> buffered() async {
    final sorted = List<AnalyticEventModel>.of(await _read())
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    return sorted;
  }

  @override
  Future<void> append(AnalyticEventModel event) async {
    final all = await _read();
    final merged = <AnalyticEventModel>[event, ...all];
    if (merged.length > AnalyticsRules.maxBuffered) {
      merged.removeRange(AnalyticsRules.maxBuffered, merged.length);
    }
    await _write(merged);
  }

  @override
  Future<void> clear() async {
    await _write(<AnalyticEventModel>[]);
  }
}