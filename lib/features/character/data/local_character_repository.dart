import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/character/models/character_profile.dart';
import 'package:ascend/features/character/repositories/character_repository.dart';

/// Secure-storage backed profile. Corrupt payloads read as absent.
final class LocalCharacterRepository implements CharacterRepository {
  LocalCharacterRepository({required this.storage});

  static const String key = 'feature.character.profile.v1';

  final SecureStorageService storage;

  @override
  Future<CharacterProfile?> load() async {
    final raw = await storage.read(key);
    if (raw == null) {
      return null;
    }
    try {
      final decoded = jsonDecode(raw) as Map<String, Object?>;
      return CharacterProfile.fromJson(decoded);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> save(CharacterProfile profile) async {
    await storage.write(key, jsonEncode(profile.toJson()));
  }
}