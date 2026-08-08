import 'package:ascend/features/shop/domain/shop_domain.dart';
import 'package:flutter/foundation.dart';

/// A purchasable from the catalog.
@immutable
final class ShopItemModel {
  const ShopItemModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.category,
    required this.icon,
    required this.description,
  });

  final String id;
  final String name;
  final int cost;
  final ShopCategory category;

  /// Material icon codepoint key (e.g. `shield`), resolved in widgets.
  final String icon;
  final String description;

  @override
  String toString() => 'ShopItemModel($id, $name, $cost)';
}