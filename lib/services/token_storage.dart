import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken
    }) async {
      await Future.wait([
        _storage.write(key: _accessKey, value: accessToken),
        _storage.write(key: _refreshKey, value: refreshToken),
      ]);
  }

  Future<String?> get accessToken => _storage.read(key: _accessKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  Future<bool> get hasValidToken async{
    final token = await accessToken;
    if(token == null) return false;
    try{
      final parts = token.split('.');
      if(parts.length != 3) return false;
      final payload = String.fromCharCodes(base64Url.decode(base64Url.normalize(parts[1]))
    );
    final data = jsonDecode(payload) as Map<String, dynamic>;
    final exp = data['exp'] as int?;
    if(exp == null) return true;
    return DateTime.fromMillisecondsSinceEpoch(exp * 1000)
      .isAfter(DateTime.now());
    }catch(_){
      return false;
    }
  }
  
}