import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/boss/models/boss_model.dart';
import 'package:ascend/features/boss/repositories/boss_repository.dart';

/// Secure-storage backed boss snapshot; corrupt payloads read as absent.
final class LocalBossRepository implements BossRepository {
  LocalBossRepository({required this.storage});

  static const String key = 'feature.boss.v1';

  final SecureStorageService storage;

  @override
  Future<BossModel?> load() async {
    final raw = await storage.read(key);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      return BossModel.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(BossModel boss) async {
    await storage.write(key, jsonEncode(boss.toJson()));
  }

  @override
  Future<void> clear() => storage.delete(key);
}