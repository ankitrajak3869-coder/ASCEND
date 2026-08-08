import 'package:ascend/features/settings/models/app_preferences.dart';

/// Port for preference persistence.
abstract interface class SettingsRepository {
  Future<AppPreferences?> load();

  Future<void> save(AppPreferences preferences);
}