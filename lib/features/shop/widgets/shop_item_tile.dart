import 'package:ascend/features/shop/domain/shop_domain.dart';
import 'package:ascend/features/shop/models/shop_item.dart';
import 'package:flutter/material.dart';

/// Catalog tile: icon, price, and an owned/affordable state.
class ShopItemTile extends StatelessWidget {
  const ShopItemTile({
    super.key,
    required this.item,
    required this.owned,
    required this.balance,
    this.onPurchase,
  });

  final ShopItemModel item;
  final bool owned;
  final int balance;
  final VoidCallback? onPurchase;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final affordable = balance >= item.cost;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: owned ? null : onPurchase,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(_iconFor(item), size: 32),
              const Spacer(),
              Text(item.name, style: theme.textTheme.titleSmall),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Icon(
                    owned ? Icons.check : Icons.monetization_on_outlined,
                    size: 16,
                    color: owned
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    owned ? 'Owned' : '${item.cost}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: owned
                          ? theme.colorScheme.primary
                          : (affordable
                                ? null
                                : theme.colorScheme.error),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(ShopItemModel item) => switch (item.icon) {
    'spark' => Icons.spa_outlined,
    'black_circle' => Icons.circle_outlined,
    'palette' => Icons.palette_outlined,
    'bolt' => Icons.bolt_outlined,
    'auto_awesome' => Icons.auto_awesome,
    'wb_sunny' => Icons.wb_sunny_outlined,
    _ => Icons.shopping_bag_outlined,
  };

  static String categoryLabel(ShopCategory category) => switch (category) {
    ShopCategory.avatarFrame => 'Frame',
    ShopCategory.theme => 'Theme',
    ShopCategory.boost => 'Boost',
  };
}