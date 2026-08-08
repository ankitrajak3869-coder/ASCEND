/// Shop domain: categories and wallet wiring.
library;

/// What a shop item grants when owned.
enum ShopCategory { avatarFrame, boost, theme }

/// Wallet wiring.
abstract final class WalletRules {
  /// Tokens a fresh account starts with.
  static const int startingBalance = 50;

  /// The most tokens anyone can hold.
  static const int maxBalance = 9999;
}