import 'package:flutter/foundation.dart';

/// The canonical stat set of the character engine.
///
/// Extensible by design: adding a value here (plus mission template data)
/// is all it takes to support a new stat anywhere — missions, character
/// domain and history all read from this single vocabulary.
enum StatKind {
  health,
  strength,
  knowledge,
  discipline,
  creativity,
  finance,
  confidence,
}

/// One contribution to a character stat, declared by a mission.
///
/// Pure data: missions produce these, the character engine applies them.
@immutable
final class StatGain {
  const StatGain(this.kind, this.amount);

  final StatKind kind;
  final int amount;

  @override
  bool operator ==(Object other) =>
      other is StatGain && other.kind == kind && other.amount == amount;

  @override
  int get hashCode => Object.hash(kind, amount);

  @override
  String toString() => '+$amount ${kind.name}';
}