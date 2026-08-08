import 'dart:async';

import 'package:ascend/core/config/app_config.dart';
import 'package:ascend/core/services/app_boot.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

/// Firebase analytics wrapper with a fire-and-forget API.
///
/// Events are dropped when telemetry is disabled or Firebase is absent;
/// callers never crash on plugin failures.
final class AppAnalytics {
  const AppAnalytics([this._analytics]);

  const AppAnalytics.noop() : this(null);

  /// Builds an instance when telemetry is enabled for the active flavor.
  static AppAnalytics? configured(AppInit init) {
    if (!AppConfig.enableTelemetry || init is! AppInitSuccess) {
      return null;
    }
    return AppAnalytics(FirebaseAnalytics.instance);
  }

  final FirebaseAnalytics? _analytics;

  void log(String screenName) {
    unawaited(
      _analytics?.logEvent(
        name: 'screen_view',
        parameters: <String, Object>{'screen': screenName},
      ),
    );
  }

  void logEvent(String name, [Map<String, Object> parameters = const {}]) {
    unawaited(_analytics?.logEvent(name: name, parameters: parameters));
  }

  void setUserId(String? userId) {
    unawaited(_analytics?.setUserId(id: userId));
  }
}