import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  factory SecureStorageService() => _instance;

  SecureStorageService._();

  static final SecureStorageService _instance = SecureStorageService._();

  static const accessTokenKey = 'backend_access_token';
  static const refreshTokenKey = 'backend_refresh_token';

  static const _true = 'true';
  static const _false = 'false';

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> setBool(String key, {required bool value}) async {
    await _storage.write(key: key, value: value ? _true : _false);
  }

  Future<void> setString(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> getString(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> writeAuthTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _storage.write(key: accessTokenKey, value: accessToken);
    await _storage.write(key: refreshTokenKey, value: refreshToken);
  }

  Future<String?> getAccessToken() => getString(accessTokenKey);

  Future<String?> getRefreshToken() => getString(refreshTokenKey);

  Future<void> clearAuthTokens() async {
    await _storage.delete(key: accessTokenKey);
    await _storage.delete(key: refreshTokenKey);
  }

  Future<void> clear() async => await _storage.deleteAll();
}
