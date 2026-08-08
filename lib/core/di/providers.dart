import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/services/analytics_service.dart';
import 'package:ascend/core/services/app_boot.dart';
import 'package:ascend/core/services/crashlytics_service.dart';
import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Application-wide domain event hub (cross-feature pipeline bus).
final domainEventBusProvider = Provider<DomainEventBus>(
  (ref) {
    final bus = DomainEventBus();
    ref.onDispose(bus.dispose);
    return bus;
  },
);

/// Boot result: Firebase init outcome (emulator-aware).
final appBootProvider = FutureProvider<AppInit>(
  (ref) => AppBoot.init(),
);

/// Analytics backend: configured instance for telemetry flavors, noop
/// otherwise.
final appAnalyticsProvider = Provider<AppAnalytics>(
  (ref) {
    final init = ref.watch(appBootProvider).valueOrNull;
    if (init == null) {
      return const AppAnalytics.noop();
    }
    return AppAnalytics.configured(init) ?? const AppAnalytics.noop();
  },
);

/// Crash reporting backend.
final appCrashReporterProvider = Provider<AppCrashReporter>(
  (ref) {
    final init = ref.watch(appBootProvider).valueOrNull;
    if (init == null) {
      return const AppCrashReporter.noop();
    }
    return AppCrashReporter.configured(init);
  },
);

/// Secure key/value storage (tokens).
final secureStorageProvider = Provider<SecureStorageService>(
  (ref) => const SecureStorageServiceFlutter(),
);

/// Firebase app handle, exposed for services that attach to it.
final firebaseAppProvider = Provider<FirebaseApp?>(
  (ref) {
    final init = ref.watch(appBootProvider).valueOrNull;
    if (init is AppInitSuccess) {
      return init.firebase;
    }
    return null;
  },
);