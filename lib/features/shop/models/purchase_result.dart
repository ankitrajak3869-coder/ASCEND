import 'package:ascend/features/shop/models/shop_item.dart';
import 'package:flutter/foundation.dart';

/// An immutable item category + what owning it unlocks.
@immutable
final class ShopCategoryModel {
  const ShopCategoryModel({
    required this.key,
    required this.label,
    required this.items,
  });

  final String key;
  final String label;
  final List<ShopItemModel> items;
}

/// Outcome of an attempted purchase.
sealed class PurchaseResult {
  const PurchaseResult();
}

final class PurchaseSucceeded extends PurchaseResult {
  const PurchaseSucceeded(this.item, this.balance);

  final ShopItemModel item;
  final int balance;
}

/// The purchase could not complete; [reason] is user-displayable.
final class PurchaseDeclined extends PurchaseResult {
  const PurchaseDeclined({
    required this.item,
    required this.balance,
    required this.reason,
  });

  final ShopItemModel item;
  final int balance;
  final String reason;
}