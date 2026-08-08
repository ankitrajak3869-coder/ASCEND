import 'package:ascend/features/achievements/models/achievement_model.dart';

/// Port for achievement persistence.
abstract interface class AchievementRepository {
  Future<List<AchievementModel>> load();

  Future<void> save(List<AchievementModel> achievements);
}