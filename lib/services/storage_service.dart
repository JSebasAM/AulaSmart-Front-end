import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService();
});

class StorageService {
  static const _secureStorage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userInfoKey = 'user_info';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _secureStorage.write(key: _accessKey, value: accessToken),
      _secureStorage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  Future<String?> get accessToken => _secureStorage.read(key: _accessKey);
  Future<String?> get refreshToken => _secureStorage.read(key: _refreshKey);

  Future<void> saveUserInfo(Map<String, dynamic> userInfo) async {
    await _secureStorage.write(
        key: _userInfoKey, value: jsonEncode(userInfo));
  }

  Future<Map<String, dynamic>?> getUserInfo() async {
    final data = await _secureStorage.read(key: _userInfoKey);
    if (data != null) {
      return jsonDecode(data) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> clearAll() async {
    await _secureStorage.delete(key: _userInfoKey);
    await clearTokens();
    await clearSession();
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _secureStorage.delete(key: _accessKey),
      _secureStorage.delete(key: _refreshKey),
    ]);
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: 'crypto_sessions');
    
  Future<void> clearAccessToken() async {
    await _secureStorage.delete(key: _accessKey);
  }

  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(key: _accessKey, value: token);
  }

  Future<bool> get hasValidToken async {
    final token = await accessToken;
    if (token == null) return false;
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = String.fromCharCodes(
          base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload) as Map<String, dynamic>;
      final exp = data['exp'] as int?;
      if (exp == null) return true;
      return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
          .isAfter(DateTime.now());
    } catch (_) {
      return false;
    }
  }
}
