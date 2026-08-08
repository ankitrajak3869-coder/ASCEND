import 'package:ascend/features/shop/domain/shop_domain.dart';
import 'package:ascend/features/shop/models/purchase_result.dart';
import 'package:ascend/features/shop/models/shop_item.dart';
import 'package:ascend/features/shop/repositories/shop_repository.dart';

/// Purchase rules: affordability, ownership and the wallet ledger.
final class ShopService {
  const ShopService({required this.repository});

  final ShopRepository repository;

  /// Attempts to buy [itemId] for the current balance.
  Future<PurchaseResult> purchase(String itemId) async {
    final item = _find(itemId);
    if (item == null) {
      return PurchaseDeclined(
        item: ShopItemModel(
          id: itemId,
          name: itemId,
          cost: 0,
          category: ShopCategory.boost,
          icon: 'help_outline',
          description: '',
        ),
        balance: await repository.balance(),
        reason: 'Unknown item',
      );
    }

    final owned = await repository.ownedItemIds();
    if (owned.contains(itemId)) {
      return PurchaseDeclined(
        item: item,
        balance: await repository.balance(),
        reason: 'Already owned',
      );
    }

    final balance = await repository.balance();
    if (balance < item.cost) {
      return PurchaseDeclined(
        item: item,
        balance: balance,
        reason: 'Not enough tokens',
      );
    }

    final next = balance - item.cost;
    await repository.setBalance(next);
    await repository.markOwned(itemId);
    return PurchaseSucceeded(item, next);
  }

  /// Grants [amount] tokens (used by quest rewards), capped by the wallet.
  Future<int> earn(int amount) async {
    final balance = await repository.balance();
    final next = (balance + amount).clamp(0, WalletRules.maxBalance);
    await repository.setBalance(next);
    return next;
  }

  ShopItemModel? _find(String itemId) {
    for (final item in repository.catalog()) {
      if (item.id == itemId) {
        return item;
      }
    }
    return null;
  }
}