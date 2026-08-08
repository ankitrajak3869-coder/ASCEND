import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/skill_tree/models/skill_tree_snapshot.dart';
import 'package:ascend/features/skill_tree/repositories/skill_tree_repository.dart';

/// Secure-storage backed skill tree. Corrupt payloads degrade to a fresh
/// all-locked tree.
final class LocalSkillTreeRepository implements SkillTreeRepository {
  LocalSkillTreeRepository({required this.storage});

  static const String key = 'feature.skilltree.v1';

  final SecureStorageService storage;

  SkillTreeSnapshot? _cache;

  @override
  Future<SkillTreeSnapshot?> load() async {
    final cached = _cache;
    if (cached != null) {
      return cached;
    }
    final raw = await storage.read(key);
    if (raw == null) {
      return null;
    }
    try {
      final snapshot = SkillTreeSnapshot.fromJson(
        jsonDecode(raw) as Map<String, Object?>,
      );
      _cache = snapshot;
      return snapshot;
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(SkillTreeSnapshot snapshot) async {
    _cache = snapshot;
    await storage.write(key, jsonEncode(snapshot.toJson()));
  }
}