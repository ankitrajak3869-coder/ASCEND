import 'package:ascend/core/events/domain_events.dart';
import 'package:ascend/core/utils/day_key.dart';
import 'package:ascend/features/boss/domain/boss_domain.dart';
import 'package:ascend/features/boss/models/boss_model.dart';
import 'package:ascend/features/boss/repositories/boss_repository.dart';

/// Boss encounter rules: combo upkeep, damage math and phase machine.
final class BossService {
  const BossService({
    required this.repository,
    this.events,
  });

  final BossRepository repository;

  /// Bus for [BossDefeatedEvent] announcements on defeat.
  final DomainEventBus? events;

  /// Loads the current encounter, or a fresh one when none exists.
  Future<BossModel> loadOrFresh() async {
    return await repository.load() ?? BossModel.fresh();
  }

  /// A player strike against the boss (direct arena action).
  Future<BossModel> strike({required DateTime now}) async {
    final current = await loadOrFresh();
    if (current.isDefeated) {
      return current;
    }
    return _applyStrike(current, now: now);
  }

  /// A completed mission counts as one strike — but only while the boss is
  /// actively engaged (rumbling or enraged). A dormant or defeated boss
  /// ignores missions entirely.
  Future<BossModel> applyMissionCompletion({
    required MissionCompletedEvent mission,
  }) async {
    final current = await loadOrFresh();
    if (current.isDefeated || current.phase == BossPhase.dormant) {
      return current;
    }
    return _applyStrike(current, now: mission.completedAt);
  }

  /// Wakes a defeated boss back up at full health.
  Future<BossModel> revive() async {
    final fresh = BossModel.fresh();
    await repository.save(fresh);
    return fresh;
  }

  /// Unlocks a dormant boss into an active fight (full health kept).
  ///
  /// Used by the goal engine contract: completing a goal may surface the
  /// boss. Already-active or defeated bosses are untouched.
  Future<BossModel> awaken() async {
    final current = await loadOrFresh();
    if (current.phase != BossPhase.dormant) {
      return current;
    }
    final awake = current.copyWith(phase: BossPhase.rumbling);
    await repository.save(awake);
    return awake;
  }

  /// Shared strike machine: combo upkeep, damage and phase transitions.
  ///
  /// The combo survives same-day strikes and consecutive days; a skipped
  /// day resets it. Emits [BossDefeatedEvent] exactly when a strike takes
  /// the boss from alive to defeated.
  Future<BossModel> _applyStrike(BossModel current, {required DateTime now}) async {
    final key = DayKey.dayKey(now);
    final combo =
        current.lastStruckKey == null || current.lastStruckKey != key
        ? 1
        : current.combo + 1;

    final damage =
        BossRules.baseDamage + (combo > 1 ? BossRules.streakBonus : 0);
    final health = (current.health - damage).clamp(0, BossRules.maxHealth);

    final BossPhase phase;
    if (health == 0) {
      phase = BossPhase.defeated;
    } else if (health <= BossRules.enrageThreshold) {
      phase = BossPhase.enraged;
    } else if (current.phase == BossPhase.dormant) {
      phase = BossPhase.rumbling;
    } else {
      phase = current.phase;
    }

    final next = BossModel(
      phase: phase,
      health: health,
      maxHealth: current.maxHealth,
      strikes: current.strikes + 1,
      combo: combo,
      lastStruckKey: key,
    );
    await repository.save(next);

    if (next.isDefeated && !current.isDefeated) {
      events?.emit(BossDefeatedEvent(defeatedAt: now));
    }
    return next;
  }
}