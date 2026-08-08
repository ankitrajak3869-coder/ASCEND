import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/missions/domain/mission_domain.dart';
import 'package:ascend/features/missions/models/mission_model.dart';
import 'package:ascend/features/missions/repositories/mission_repository.dart';

/// Secure-storage backed mission persistence.
///
/// Corruption or unreadable payloads degrade to an empty catalog rather than
/// throwing, so a single bad write never bricks the app.
final class LocalMissionRepository implements MissionRepository {
  LocalMissionRepository({required this.storage});

  static const String key = 'feature.missions.v1';

  final SecureStorageService storage;

  List<MissionModel>? _cache;
  bool _hydrated = false;

  Future<List<MissionModel>> _read() async {
    if (_hydrated) {
      return _cache ?? <MissionModel>[];
    }
    final raw = await storage.read(key);
    _hydrated = true;
    if (raw == null) {
      _cache = <MissionModel>[];
      return _cache!;
    }
    try {
      final decoded = jsonDecode(raw) as List<Object?>;
      _cache = decoded
          .cast<Map<String, Object?>>()
          .map(MissionModel.fromJson)
          .toList();
    } on Object {
      _cache = <MissionModel>[];
    }
    return _cache!;
  }

  Future<void> _write(List<MissionModel> missions) async {
    _cache = missions;
    final encoded = jsonEncode(missions.map((m) => m.toJson()).toList());
    await storage.write(key, encoded);
  }

  @override
  Future<List<MissionModel>> findAll() => _read();

  @override
  Future<MissionModel> findById(String id) async {
    final all = await _read();
    for (final mission in all) {
      if (mission.id == id) {
        return mission;
      }
    }
    throw MissionNotFoundException(id);
  }

  @override
  Future<void> save(MissionModel mission) async {
    final all = await _read();
    final index = all.indexWhere((candidate) => candidate.id == mission.id);
    if (index >= 0) {
      final copy = List<MissionModel>.of(all);
      copy[index] = mission;
      await _write(copy);
    } else {
      await _write(<MissionModel>[...all, mission]);
    }
  }

  @override
  Future<void> remove(String id) async {
    await _write(
      (await _read()).where((mission) => mission.id != id).toList(),
    );
  }
}