import 'package:ascend/features/shop/models/shop_item.dart';

/// Port for catalog, wallet and ownership persistence.
abstract interface class ShopRepository {
  /// The fixed, curated catalog.
  List<ShopItemModel> catalog();

  Future<int> balance();

  Future<void> setBalance(int balance);

  Future<Set<String>> ownedItemIds();

  Future<void> markOwned(String itemId);
}