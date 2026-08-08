import 'package:ascend/core/services/secure_storage_service.dart';
import 'package:ascend/features/shop/data/local_shop_repository.dart';
import 'package:ascend/features/shop/domain/shop_domain.dart';
import 'package:ascend/features/shop/models/purchase_result.dart';
import 'package:ascend/features/shop/services/shop_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late ShopService service;
  late LocalShopRepository repository;
  const expensiveId = 'frame-aurora'; // 120
  const cheapId = 'frame-spark'; // 20

  setUp(() {
    repository = LocalShopRepository(storage: InMemorySecureStorageService());
    service = ShopService(repository: repository);
  });

  group('wallet', () {
    test('starts at the configured balance', () async {
      expect(await repository.balance(), WalletRules.startingBalance);
    });

    test('earn adds tokens and respects the cap', () async {
      final balance = await service.earn(30);
      expect(balance, 80);

      final capped = await service.earn(100000);
      expect(capped, WalletRules.maxBalance);
    });
  });

  group('purchase', () {
    test('happy path deducts and marks ownership', () async {
      final result = await service.purchase(cheapId);

      expect(result, isA<PurchaseSucceeded>());
      final success = result as PurchaseSucceeded;
      expect(success.balance, WalletRules.startingBalance - 20);
      expect(await repository.ownedItemIds(), contains(cheapId));
    });

    test('insufficient funds decline and keep the wallet intact', () async {
      final result = await service.purchase(expensiveId);

      expect(result, isA<PurchaseDeclined>());
      final declined = result as PurchaseDeclined;
      expect(declined.reason, 'Not enough tokens');
      expect(await repository.balance(), WalletRules.startingBalance);
      expect(await repository.ownedItemIds(), isEmpty);
    });

    test('an owned item cannot be bought twice', () async {
      await service.purchase(cheapId);
      final again = await service.purchase(cheapId);

      expect(again, isA<PurchaseDeclined>());
      final declined = again as PurchaseDeclined;
      expect(declined.reason, 'Already owned');
      // Still exactly one charge.
      expect(
        await repository.balance(),
        WalletRules.startingBalance - 20,
      );
    });

    test('unknown ids decline without side effects', () async {
      final result = await service.purchase('nope');

      expect(result, isA<PurchaseDeclined>());
      expect(await repository.balance(), WalletRules.startingBalance);
    });
  });

  test('catalog is fixed, sorted and fully priced', () async {
    final catalog = repository.catalog();
    expect(catalog, hasLength(6));
    expect(catalog.every((item) => item.cost > 0), isTrue);
    expect(catalog.map((item) => item.id).toSet(), hasLength(catalog.length));
  });
}