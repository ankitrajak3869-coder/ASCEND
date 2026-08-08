import 'package:ascend/features/settings/models/app_preferences.dart';
import 'package:ascend/features/settings/repositories/settings_repository.dart';

/// Settings read rules: merge stored values over defaults.
final class SettingsService {
  const SettingsService({required this.repository});

  final SettingsRepository repository;

  /// Returns effective preferences, defaulted for anything unstored.
  Future<AppPreferences> loadEffective() async {
    final stored = await repository.load();
    if (stored == null) {
      return AppPreferences.defaults();
    }
    return stored;
  }

  Future<void> save(AppPreferences preferences) => repository.save(preferences);
}