import 'package:ascend/features/missions/models/mission_model.dart';

/// Port for mission persistence. Implementations own the storage backend.
abstract interface class MissionRepository {
  Future<List<MissionModel>> findAll();

  Future<MissionModel> findById(String id);

  Future<void> save(MissionModel mission);

  Future<void> remove(String id);
}