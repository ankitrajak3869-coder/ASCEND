import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Keys used with the [SecureStorageService] backend.
abstract final class SecureKeys {
  static const String authToken = 'auth_token';
  static const String authProvider = 'auth_provider';
  static const String lastSignedInUid = 'last_signed_in_uid';
}

/// Abstraction over device secure storage so tests and other tiers can swap
/// in an in-memory variant.
abstract interface class SecureStorageService {
  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);
}

final class SecureStorageServiceFlutter implements SecureStorageService {
  const SecureStorageServiceFlutter();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

/// In-memory backend for tests. Never persist anything real.
final class InMemorySecureStorageService implements SecureStorageService {
  final Map<String, String> _values = <String, String>{};

  @override
  Future<void> write(String key, String value) async => _values[key] = value;

  @override
  Future<String?> read(String key) async => _values[key];

  @override
  Future<void> delete(String key) async => _values.remove(key);

  /// Resets all stored values (used between tests).
  void clear() => _values.clear();
}