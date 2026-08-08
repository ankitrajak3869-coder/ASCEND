import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/goals/domain/goal_domain.dart';
import 'package:ascend/features/goals/models/goal_model.dart';
import 'package:ascend/features/goals/repositories/goal_repository.dart';

/// Secure-storage backed goal list. Corrupt payloads degrade to empty.
final class LocalGoalRepository implements GoalRepository {
  LocalGoalRepository({required this.storage});

  static const String key = 'feature.goals.v1';

  final SecureStorageService storage;

  List<GoalModel>? _cache;
  bool _hydrated = false;

  Future<List<GoalModel>> _read() async {
    if (_hydrated) {
      return _cache ?? <GoalModel>[];
    }
    _hydrated = true;
    final raw = await storage.read(key);
    if (raw == null) {
      _cache = <GoalModel>[];
      return _cache!;
    }
    try {
      final decoded = jsonDecode(raw) as List<Object?>;
      _cache = decoded
          .cast<Map<String, Object?>>()
          .map(GoalModel.fromJson)
          .toList();
    } on Object {
      _cache = <GoalModel>[];
    }
    return _cache!;
  }

  Future<void> _write(List<GoalModel> goals) async {
    _cache = goals;
    await storage.write(
      key,
      jsonEncode(goals.map((goal) => goal.toJson()).toList()),
    );
  }

  @override
  Future<List<GoalModel>> findAll() => _read();

  @override
  Future<GoalModel> findById(String id) async {
    final all = await _read();
    for (final goal in all) {
      if (goal.id == id) {
        return goal;
      }
    }
    throw GoalNotFoundException(id);
  }

  @override
  Future<void> save(GoalModel goal) async {
    final all = await _read();
    final index = all.indexWhere((candidate) => candidate.id == goal.id);
    if (index >= 0) {
      final copy = List<GoalModel>.of(all);
      copy[index] = goal;
      await _write(copy);
    } else {
      await _write(<GoalModel>[...all, goal]);
    }
  }

  @override
  Future<void> remove(String id) async {
    await _write(
      (await _read()).where((goal) => goal.id != id).toList(),
    );
  }
}