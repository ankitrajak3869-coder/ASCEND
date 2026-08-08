import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/settings/data/local_settings_repository.dart';
import 'package:ascend/features/settings/domain/settings_domain.dart';
import 'package:ascend/features/settings/models/app_preferences.dart';
import 'package:ascend/features/settings/services/settings_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsService', () {
    test('loads defaults when nothing is stored', () async {
      final service = SettingsService(
        repository: LocalSettingsRepository(
          storage: InMemorySecureStorageService(),
        ),
      );
      final prefs = await service.loadEffective();
      expect(prefs.theme, ThemePreference.system);
      expect(prefs.analyticsEnabled, isTrue);
      expect(prefs.reduceMotion, isFalse);
    });

    test('round-trips stored preferences', () async {
      final storage = InMemorySecureStorageService();
      final service = SettingsService(
        repository: LocalSettingsRepository(storage: storage),
      );

      await service.save(
        const AppPreferences(
          theme: ThemePreference.dark,
          reduceMotion: true,
          notificationsEnabled: false,
          analyticsEnabled: false,
        ),
      );

      final loaded = await service.loadEffective();
      expect(loaded.theme, ThemePreference.dark);
      expect(loaded.reduceMotion, isTrue);
      expect(loaded.notificationsEnabled, isFalse);
      expect(loaded.analyticsEnabled, isFalse);
    });

    test('corrupt payload falls back to defaults', () async {
      final storage = InMemorySecureStorageService();
      await storage.write('feature.settings.v1', '{broken');
      final service = SettingsService(
        repository: LocalSettingsRepository(storage: storage),
      );

      expect((await service.loadEffective()).theme, ThemePreference.system);
    });
  });

  group('themeFromName', () {
    test('parses known names', () {
      expect(themeFromName('dark'), ThemePreference.dark);
      expect(themeFromName('light'), ThemePreference.light);
      expect(themeFromName('system'), ThemePreference.system);
    });

    test('falls back to system for unknown values', () {
      expect(themeFromName('neon'), ThemePreference.system);
      expect(themeFromName(null), ThemePreference.system);
    });
  });
}