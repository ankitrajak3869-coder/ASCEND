import 'package:ascend/features/skill_tree/domain/skill_tree_domain.dart';
import 'package:flutter/foundation.dart';

/// Immutable snapshot of unlocked skill tree nodes.
@immutable
final class SkillTreeSnapshot {
  const SkillTreeSnapshot({this.unlockedNodeIds = const <String>[]});

  factory SkillTreeSnapshot.fromJson(Map<String, Object?> json) =>
      SkillTreeSnapshot(
        unlockedNodeIds: (json['unlockedNodeIds'] as List<Object?>? ?? const [])
            .cast<String>()
            .toList(),
      );

  final List<String> unlockedNodeIds;

  bool isUnlocked(String nodeId) => unlockedNodeIds.contains(nodeId);

  /// The next node the engine should unlock, in catalog order.
  String? get nextNodeId {
    for (final node in SkillTreeRules.catalog) {
      if (!isUnlocked(node.id)) {
        return node.id;
      }
    }
    return null;
  }

  /// Whether every catalog node is unlocked.
  bool get isComplete => nextNodeId == null;

  SkillTreeSnapshot copyWith({List<String>? unlockedNodeIds}) {
    return SkillTreeSnapshot(
      unlockedNodeIds: unlockedNodeIds ?? this.unlockedNodeIds,
    );
  }

  Map<String, Object?> toJson() => <String, Object?>{
    'unlockedNodeIds': unlockedNodeIds,
  };

  @override
  String toString() => 'SkillTreeSnapshot($unlockedNodeIds)';
}