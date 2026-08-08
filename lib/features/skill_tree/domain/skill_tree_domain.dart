/// Skill tree domain: node catalog and unlock contract.
library;

/// A tree node as configured by the product (deterministic catalog).
final class SkillTreeNode {
  const SkillTreeNode({
    required this.id,
    required this.title,
    required this.description,
  });

  final String id;
  final String title;
  final String description;
}

/// Hard rules the skill tree honors.
abstract final class SkillTreeRules {
  /// The fixed, ordered catalog. Unlocks happen in catalog order: one goal
  /// completion unlocks exactly the next locked node.
  static const List<SkillTreeNode> catalog = <SkillTreeNode>[
    SkillTreeNode(
      id: 'deeper_plans',
      title: 'Deeper Plans',
      description: 'Goal plans refine into richer milestones.',
    ),
    SkillTreeNode(
      id: 'boss_access',
      title: 'Boss Access',
      description: 'Completing goals unlocks boss battles.',
    ),
    SkillTreeNode(
      id: 'ai_review',
      title: 'AI Review',
      description: 'Finished goals attract a mentor review.',
    ),
  ];

  /// First goal to complete unlocks the first node.
  static const int unlockGoalTarget = 1;
}