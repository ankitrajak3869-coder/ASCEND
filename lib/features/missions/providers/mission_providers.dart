import 'package:ascend/core/di/providers.dart';
import 'package:ascend/core/models/mission_seed.dart';
import 'package:ascend/features/missions/data/local_mission_repository.dart';
import 'package:ascend/features/missions/models/mission_model.dart';
import 'package:ascend/features/missions/repositories/mission_repository.dart';
import 'package:ascend/features/missions/services/mission_catalog_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed mission repository.
final missionRepositoryProvider = Provider<MissionRepository>(
  (ref) => LocalMissionRepository(storage: ref.watch(secureStorageProvider)),
);

/// Planned (goal-driven) mission requests feeding the catalog. Empty by
/// default; the app composition root binds it to the goal engine's seeds.
final missionSeedSourceProvider = Provider<List<MissionSeed>>(
  (ref) => const <MissionSeed>[],
);

/// Catalog curation service (emits completion events on the bus).
final missionCatalogProvider = Provider<MissionCatalogService>(
  (ref) => MissionCatalogService(
    repository: ref.watch(missionRepositoryProvider),
    events: ref.watch(domainEventBusProvider),
    seeds: ref.watch(missionSeedSourceProvider),
  ),
);

/// Today's missions, curated once per local day, plus the goal-driven
/// planned missions of the moment. Deterministic for a fixed local day.
final dailyMissionsProvider = FutureProvider<List<MissionModel>>(
  (ref) async {
    final catalog = ref.watch(missionCatalogProvider);
    final now = DateTime.now();
    final daily = await catalog.curatedDaily(now);
    final planned = await catalog.applySeeds(now: now);
    final merged = <MissionModel>[...daily, ...planned]..sort(
      (a, b) => a.id.compareTo(b.id),
    );
    return merged;
  },
);