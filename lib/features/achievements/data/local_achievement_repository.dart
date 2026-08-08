import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/achievements/models/achievement_model.dart';
import 'package:ascend/features/achievements/repositories/achievement_repository.dart';

/// Secure-storage backed achievement list. Corrupt payloads degrade to empty.
final class LocalAchievementRepository implements AchievementRepository {
  LocalAchievementRepository({required this.storage});

  static const String key = 'feature.achievements.v1';

  final SecureStorageService storage;

  List<AchievementModel>? _cache;
  bool _hydrated = false;

  Future<List<AchievementModel>> _read() async {
    if (_hydrated) {
      return _cache ?? <AchievementModel>[];
    }
    _hydrated = true;
    final raw = await storage.read(key);
    if (raw == null) {
      _cache = <AchievementModel>[];
      return _cache!;
    }
    try {
      final decoded = jsonDecode(raw) as List<Object?>;
      _cache = decoded
          .cast<Map<String, Object?>>()
          .map(AchievementModel.fromJson)
          .toList();
    } on Object {
      _cache = <AchievementModel>[];
    }
    return _cache!;
  }

  Future<void> _write(List<AchievementModel> achievements) async {
    _cache = achievements;
    await storage.write(
      key,
      jsonEncode(achievements.map((a) => a.toJson()).toList()),
    );
  }

  @override
  Future<List<AchievementModel>> load() => _read();

  @override
  Future<void> save(List<AchievementModel> achievements) => _write(achievements);
}