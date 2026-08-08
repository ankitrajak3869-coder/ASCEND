import 'package:firebase_core/firebase_core.dart';

/// Environment-driven app configuration.
enum AppFlavor { dev, staging, prod }

const String _env = String.fromEnvironment('ASCEND_ENV');
const String _apiKey = String.fromEnvironment('ASCEND_FIREBASE_API_KEY');
const String _appId = String.fromEnvironment('ASCEND_FIREBASE_APP_ID');
const String _senderId = String.fromEnvironment('ASCEND_FIREBASE_SENDER_ID');
const String _projectId = String.fromEnvironment('ASCEND_FIREBASE_PROJECT_ID');

abstract final class AppConfig {
  static AppFlavor get flavor => switch (_env) {
        'staging' => AppFlavor.staging,
        'prod' => AppFlavor.prod,
        _ => AppFlavor.dev,
      };

  /// Only the local development flavor talks to the Firebase emulators.
  static bool get useEmulator => flavor == AppFlavor.dev;

  /// Crash reporting and analytics run outside production to avoid noisy
  /// alerts; staging and prod both report.
  static bool get enableTelemetry =>
      flavor == AppFlavor.prod || flavor == AppFlavor.staging;

  static bool get hasFirebaseCredentials =>
      _apiKey.isNotEmpty && _appId.isNotEmpty && _projectId.isNotEmpty;

  /// Firebase options resolved from build-time defines. A clean clone runs
  /// in emulator mode until `flutterfire configure` supplies real values.
  static FirebaseOptions? get firebaseOptions {
    if (!hasFirebaseCredentials) {
      return null;
    }
    return const FirebaseOptions(
      apiKey: _apiKey,
      appId: _appId,
      messagingSenderId: _senderId,
      projectId: _projectId,
    );
  }
}