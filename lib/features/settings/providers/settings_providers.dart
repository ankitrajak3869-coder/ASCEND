import 'package:ascend/core/di/providers.dart';
import 'package:ascend/features/settings/data/local_settings_repository.dart';
import 'package:ascend/features/settings/domain/settings_domain.dart';
import 'package:ascend/features/settings/models/app_preferences.dart';
import 'package:ascend/features/settings/repositories/settings_repository.dart';
import 'package:ascend/features/settings/services/settings_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed settings repository.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => LocalSettingsRepository(storage: ref.watch(secureStorageProvider)),
);

/// Settings service.
final settingsServiceProvider = Provider<SettingsService>(
  (ref) => SettingsService(repository: ref.watch(settingsRepositoryProvider)),
);

/// Effective preferences.
final settingsProvider =
    AsyncNotifierProvider<SettingsNotifier, AppPreferences>(
      SettingsNotifier.new,
    );

final class SettingsNotifier extends AsyncNotifier<AppPreferences> {
  @override
  Future<AppPreferences> build() =>
      ref.watch(settingsServiceProvider).loadEffective();

  Future<void> setTheme(ThemePreference theme) => _update(
    (current) => current.copyWith(theme: theme),
  );

  Future<void> setReduceMotion(bool enabled) => _update(
    (current) => current.copyWith(reduceMotion: enabled),
  );

  Future<void> setNotifications(bool enabled) => _update(
    (current) => current.copyWith(notificationsEnabled: enabled),
  );

  Future<void> setAnalytics(bool enabled) => _update(
    (current) => current.copyWith(analyticsEnabled: enabled),
  );

  Future<void> _update(AppPreferences Function(AppPreferences) change) async {
    final current = state.value ?? await build();
    final next = change(current);
    await ref.read(settingsServiceProvider).save(next);
    state = AsyncData<AppPreferences>(next);
  }
}