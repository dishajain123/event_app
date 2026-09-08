import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Wraps [FlutterSecureStorage] (Keychain on iOS, Keystore-backed encrypted
/// prefs on Android) as the single place tokens ever touch disk. Nothing
/// else in the app should import `flutter_secure_storage` directly —
/// everything goes through this class, so there is exactly one place to
/// audit for how tokens are persisted.
class SecureTokenStorage {
  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'event_app.access_token';
  static const _refreshTokenKey = 'event_app.refresh_token';

  SecureTokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  Future<void> saveTokens(
      {required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  /// Access token is also re-issued on refresh; this updates it alone
  /// without touching the stored refresh token.
  Future<void> saveAccessToken(String accessToken) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
  }

  Future<String?> getAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> getRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<bool> hasStoredSession() async {
    final refresh = await getRefreshToken();
    return refresh != null && refresh.isNotEmpty;
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }
}
