import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/settings/models/app_preferences.dart';
import 'package:ascend/features/settings/repositories/settings_repository.dart';

/// Secure-storage backed preferences; absent or corrupt reads fall back to
/// null so the service can apply defaults.
final class LocalSettingsRepository implements SettingsRepository {
  LocalSettingsRepository({required this.storage});

  static const String key = 'feature.settings.v1';

  final SecureStorageService storage;

  @override
  Future<AppPreferences?> load() async {
    final raw = await storage.read(key);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      return AppPreferences.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(AppPreferences preferences) async {
    await storage.write(key, jsonEncode(preferences.toJson()));
  }
}