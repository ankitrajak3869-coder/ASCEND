import 'dart:async';

import 'package:ascend/core/services/app_boot.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

/// Crash reporting wrapper. Records fatal errors through Crashlytics when
/// enabled; drops reports otherwise.
final class AppCrashReporter {
  const AppCrashReporter._(this._enabled);

  factory AppCrashReporter.configured(AppInit init) {
    if (init is! AppInitSuccess) {
      return const AppCrashReporter.noop();
    }
    return const AppCrashReporter._(true);
  }

  const AppCrashReporter.noop() : this._(false);

  final bool _enabled;

  void recordError(Object error, StackTrace stack) {
    if (!_enabled) {
      return;
    }
    unawaited(FirebaseCrashlytics.instance.recordError(error, stack));
  }
}