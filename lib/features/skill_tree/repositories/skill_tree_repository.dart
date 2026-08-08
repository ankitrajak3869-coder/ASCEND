import 'package:ascend/features/skill_tree/models/skill_tree_snapshot.dart';

/// Port for skill tree persistence.
abstract interface class SkillTreeRepository {
  Future<SkillTreeSnapshot?> load();

  Future<void> save(SkillTreeSnapshot snapshot);
}