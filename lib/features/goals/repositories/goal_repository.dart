import 'package:ascend/features/goals/models/goal_model.dart';

/// Port for goal persistence.
abstract interface class GoalRepository {
  Future<List<GoalModel>> findAll();

  Future<GoalModel> findById(String id);

  Future<void> save(GoalModel goal);

  Future<void> remove(String id);
}