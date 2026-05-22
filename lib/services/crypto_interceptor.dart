import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'crypto_service.dart';
import 'session_manager.dart';
import 'storage_service.dart';

class CryptoInterceptor extends Interceptor {
  final Dio _cleanDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final Set<String> _pendingHandshakes = {};
  final StorageService _storage;

  CryptoInterceptor(this._storage);

  static bool isSensitivePath(String path) {
    return path.contains('/aula-service/aulas') ||
        path.contains('/usuario-service/usuarios') ||
        path.contains('/auth/');
  }

  String _extractHost(String baseUrl) {
    return baseUrl;
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (!isSensitivePath(options.path)) {
      return handler.next(options);
    }

    final host = _extractHost(options.baseUrl);
    var session = await SessionManager.getSession(host);

    if (session == null && !_pendingHandshakes.contains(host)) {
      _pendingHandshakes.add(host);
      try {
        session = await _performHandshake(host);
      } catch (e) {
        return handler.reject(DioException(
            requestOptions: options, error: 'Handshake failed: $e'));
      } finally {
        _pendingHandshakes.remove(host);
      }
    }

    if (session == null) {
      return handler.reject(DioException(
          requestOptions: options,
          error: 'No hay sesion criptografica disponible'));
    }

    final method = options.method.toUpperCase();
    if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
      final aes =
          AesHelper(Uint8List.fromList(base64Decode(session.aesKeyBase64)));
      final plainBody = jsonEncode(options.data ?? {});
      final encrypted = aes.encryptText(plainBody);
      options.data = {'payload': encrypted};
    }
    options.headers['x-session-id'] = session.sessionId;
    handler.next(options);
  }

  @override
  Future<void> onResponse(
      Response response, ResponseInterceptorHandler handler) async {
    final request = response.requestOptions;
    if (!isSensitivePath(request.path)) {
      return handler.next(response);
    }

    if (response.data is Map && response.data['payload'] != null) {
      final host = _extractHost(request.baseUrl);
      final session = await SessionManager.getSession(host);
      if (session != null) {
        final aes = AesHelper(
            Uint8List.fromList(base64Decode(session.aesKeyBase64)));
        final decrypted = aes.decryptText(response.data['payload']);
        try {
          response.data = jsonDecode(decrypted);
        } catch (_) {
          response.data = decrypted;
        }
      }
    }
    handler.next(response);
  }

  Future<SessionEntry> _performHandshake(String baseUrl) async {
    final pkResponse = await _cleanDio.get('$baseUrl/crypto/public-key');
    final n = pkResponse.data['n'] as String;
    final e = pkResponse.data['e'] as String;

    final aesKey = Uint8List(16);
    final rnd = Random.secure();
    for (var i = 0; i < 16; i++) {
      aesKey[i] = rnd.nextInt(256);
    }

    final encryptedKey = RsaHelper.encryptAesKey(aesKey, n, e);

    final token = await _storage.accessToken;
    final hsResponse = await _cleanDio.post(
      '$baseUrl/crypto/handshake',
      data: {'encryptedAesKey': encryptedKey},
      options: Options(
        headers: token != null ? {'Authorization': 'Bearer $token'} : {},
      ),
    );

    final sessionId = hsResponse.data['sessionId'] as String;
    final entry = SessionEntry(
      sessionId: sessionId,
      aesKeyBase64: base64Encode(aesKey),
    );
    await SessionManager.saveSession(baseUrl, entry);
    return entry;
  }
}
