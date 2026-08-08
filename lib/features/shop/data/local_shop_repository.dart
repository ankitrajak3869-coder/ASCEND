import 'dart:convert';

import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/shop/domain/shop_domain.dart';
import 'package:ascend/features/shop/models/shop_item.dart';
import 'package:ascend/features/shop/repositories/shop_repository.dart';

/// Secure-storage backed wallet and ownership; catalog is code-owned.
final class LocalShopRepository implements ShopRepository {
  LocalShopRepository({required this.storage});

  static const String walletKey = 'feature.shop.wallet.v1';
  static const String ownedKey = 'feature.shop.owned.v1';

  final SecureStorageService storage;

  @override
  List<ShopItemModel> catalog() => _catalog;

  static final List<ShopItemModel> _catalog = <ShopItemModel>[
    const ShopItemModel(
      id: 'frame-spark',
      name: 'Spark frame',
      cost: 20,
      category: ShopCategory.avatarFrame,
      icon: 'spark',
      description: 'A violet halo around your avatar.',
    ),
    const ShopItemModel(
      id: 'frame-onyx',
      name: 'Onyx frame',
      cost: 60,
      category: ShopCategory.avatarFrame,
      icon: 'black_circle',
      description: 'Sharp black ring, subtle glow.',
    ),
    const ShopItemModel(
      id: 'theme-nebula',
      name: 'Nebula theme',
      cost: 80,
      category: ShopCategory.theme,
      icon: 'palette',
      description: 'Recolors surfaces into deep space.',
    ),
    const ShopItemModel(
      id: 'boost-focus',
      name: 'Focus boost',
      cost: 40,
      category: ShopCategory.boost,
      icon: 'bolt',
      description: 'Double XP for your next mission.',
    ),
    const ShopItemModel(
      id: 'frame-aurora',
      name: 'Aurora frame',
      cost: 120,
      category: ShopCategory.avatarFrame,
      icon: 'auto_awesome',
      description: 'Animated aurora ring around the avatar.',
    ),
    const ShopItemModel(
      id: 'theme-sunrise',
      name: 'Sunrise theme',
      cost: 100,
      category: ShopCategory.theme,
      icon: 'wb_sunny',
      description: 'Warm daylight surfaces.',
    ),
  ];

  @override
  Future<int> balance() async {
    final raw = await storage.read(walletKey);
    if (raw == null) {
      return WalletRules.startingBalance;
    }
    return int.tryParse(raw) ?? WalletRules.startingBalance;
  }

  @override
  Future<void> setBalance(int balance) async {
    await storage.write(walletKey, balance.toString());
  }

  @override
  Future<Set<String>> ownedItemIds() async {
    final raw = await storage.read(ownedKey);
    if (raw == null) {
      return <String>{};
    }
    try {
      final decoded = jsonDecode(raw) as List<Object?>;
      return decoded.cast<String>().toSet();
    } on Object {
      return <String>{};
    }
  }

  @override
  Future<void> markOwned(String itemId) async {
    final owned = await ownedItemIds();
    await storage.write(
      ownedKey,
      jsonEncode(<String>[...owned, itemId]),
    );
  }
}