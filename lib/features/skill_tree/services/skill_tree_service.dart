import 'package:ascend/features/skill_tree/domain/skill_tree_domain.dart';
import 'package:ascend/features/skill_tree/models/skill_tree_snapshot.dart';
import 'package:ascend/features/skill_tree/repositories/skill_tree_repository.dart';

/// Skill tree rules: loads a fresh all-locked tree, unlocks nodes in catalog
/// order on goal completions, and persists every mutation.
final class SkillTreeService {
  const SkillTreeService({required this.repository});

  final SkillTreeRepository repository;

  /// Loads the tree, minting a fresh all-locked one on first run.
  Future<SkillTreeSnapshot> loadOrFresh() async {
    return await repository.load() ?? const SkillTreeSnapshot();
  }

  /// Unlocks the next catalog node (a goal completion grants one node).
  ///
  /// Deterministic: the catalog order decides which node. Already-complete
  /// trees are no-ops. Returns the updated snapshot.
  Future<SkillTreeSnapshot> unlockNext() async {
    final current = await loadOrFresh();
    final nextId = current.nextNodeId;
    if (nextId == null) {
      return current;
    }
    final nextNode = SkillTreeRules.catalog.firstWhere(
      (node) => node.id == nextId,
    );
    final updated = SkillTreeSnapshot(
      unlockedNodeIds: <String>[...current.unlockedNodeIds, nextNode.id],
    );
    await repository.save(updated);
    return updated;
  }
}