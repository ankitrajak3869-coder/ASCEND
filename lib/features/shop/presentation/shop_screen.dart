import 'dart:async';

import 'package:ascend/features/shop/models/purchase_result.dart';
import 'package:ascend/features/shop/models/shop_item.dart';
import 'package:ascend/features/shop/providers/shop_providers.dart';
import 'package:ascend/features/shop/widgets/shop_item_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The shop: browse, buy, and watch the wallet drain.
class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(shopCatalogProvider);
    final balanceAsync = ref.watch(walletBalanceProvider);
    final ownedAsync = ref.watch(ownedItemsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: balanceAsync.when(
                loading: () => const Text('…'),
                error: (error, stack) => const Text('?'),
                data: (balance) => Row(
                  children: <Widget>[
                    const Icon(Icons.monetization_on_outlined, size: 20),
                    const SizedBox(width: 4),
                    Text('$balance'),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
        ),
        itemCount: catalog.length,
        itemBuilder: (context, index) {
          final item = catalog[index];
          final owned = ownedAsync.valueOrNull?.contains(item.id) ?? false;
          final balance = balanceAsync.valueOrNull ?? 0;
          return ShopItemTile(
            item: item,
            owned: owned,
            balance: balance,
            onPurchase: () => unawaited(_purchase(ref, item, context)),
          );
        },
      ),
    );
  }

  Future<void> _purchase(
    WidgetRef ref,
    ShopItemModel item,
    BuildContext context,
  ) async {
    final result = await ref.read(shopServiceProvider).purchase(item.id);
    ref.invalidate(walletBalanceProvider);
    ref.invalidate(ownedItemsProvider);
    if (!context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    switch (result) {
      case PurchaseSucceeded():
        messenger.showSnackBar(
          SnackBar(content: Text('${item.name} purchased')),
        );
      case PurchaseDeclined():
        messenger.showSnackBar(
          SnackBar(content: Text('${item.name}: ${result.reason}')),
        );
    }
  }
}