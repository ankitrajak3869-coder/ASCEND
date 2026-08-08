import 'package:ascend/features/boss/models/boss_model.dart';

/// Port for boss state persistence.
abstract interface class BossRepository {
  Future<BossModel?> load();

  Future<void> save(BossModel boss);

  Future<void> clear();
}