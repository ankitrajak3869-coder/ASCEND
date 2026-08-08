import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/analytics/data/local_analytics_repository.dart';
import 'package:ascend/features/analytics/domain/analytics_domain.dart';
import 'package:ascend/features/analytics/services/analytics_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AnalyticsService service;
  late LocalAnalyticsRepository repository;
  final at = DateTime(2026, 8, 3, 12);

  setUp(() {
    repository = LocalAnalyticsRepository(storage: InMemorySecureStorageService());
    service = AnalyticsService(repository: repository, enabled: true);
  });

  test('tracks events and keeps newest first', () async {
    await service.track('login', kind: AnalyticsEventKind.session, now: at);
    await service.track(
      'mission_completed',
      parameters: <String, Object?>{'xp': 50},
      now: at.add(const Duration(minutes: 1)),
    );

    final buffered = await service.buffered();
    expect(buffered, hasLength(2));
    expect(buffered.first.name, 'mission_completed');
  });

  test('disabled service records nothing', () async {
    final silent = AnalyticsService(repository: repository, enabled: false);
    await silent.track('login', kind: AnalyticsEventKind.session, now: at);

    expect(await service.buffered(), isEmpty);
  });

  test('flush clears the buffer and reports the count', () async {
    await service.track('login', kind: AnalyticsEventKind.session, now: at);
    await service.track('login', kind: AnalyticsEventKind.session, now: at);

    final result = await service.flush();
    expect(result.flushed, 2);
    expect(await service.buffered(), isEmpty);
  });

  test('buffer trims to the max', () async {
    for (var i = 0; i < AnalyticsRules.maxBuffered + 30; i++) {
      await service.track('e$i', kind: AnalyticsEventKind.action, now: at);
    }
    final buffered = await service.buffered();
    expect(buffered.length, AnalyticsRules.maxBuffered);
    expect(buffered.any((event) => event.name == 'e0'), isFalse);
  });

  test('corrupt buffer hydrates to empty', () async {
    final storage = InMemorySecureStorageService();
    await storage.write('feature.analytics.v1', 'not json');
    final repo = LocalAnalyticsRepository(storage: storage);
    expect(await repo.buffered(), isEmpty);
  });

  test('survives a repository-instance restart', () async {
    final storage = InMemorySecureStorageService();
    final first = AnalyticsService(
      repository: LocalAnalyticsRepository(storage: storage),
      enabled: true,
    );
    await first.track('login', kind: AnalyticsEventKind.session, now: at);

    final restarted = AnalyticsService(
      repository: LocalAnalyticsRepository(storage: storage),
      enabled: true,
    );
    expect(await restarted.buffered(), hasLength(1));
  });
}