import 'package:ascend/core/di/providers.dart';
import 'package:ascend/features/shop/data/local_shop_repository.dart';
import 'package:ascend/features/shop/models/shop_item.dart';
import 'package:ascend/features/shop/repositories/shop_repository.dart';
import 'package:ascend/features/shop/services/shop_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Storage-backed shop repository.
final shopRepositoryProvider = Provider<ShopRepository>(
  (ref) => LocalShopRepository(storage: ref.watch(secureStorageProvider)),
);

/// Shop service (wallet + purchases).
final shopServiceProvider = Provider<ShopService>(
  (ref) => ShopService(repository: ref.watch(shopRepositoryProvider)),
);

/// The curated catalog.
final shopCatalogProvider = Provider<List<ShopItemModel>>(
  (ref) => ref.watch(shopRepositoryProvider).catalog(),
);

/// The player's token balance.
final walletBalanceProvider = FutureProvider<int>(
  (ref) => ref.watch(shopRepositoryProvider).balance(),
);

/// Items the player already owns.
final ownedItemsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(shopRepositoryProvider).ownedItemIds(),
);