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

  static bool isPublicPath(String path) {
    return path.contains('/auth/') || path.contains('/crypto/');
  }

  static bool isSensitivePath(String path) {
    if (isPublicPath(path)) return false;
    return path.contains('/aula-service/') ||
        path.contains('/usuario-service/') ||
        path.contains('/chat');
    // reserva-service e incidencia-service: E2E pendiente de verificar
    // en el backend (EncryptionFilter no está descifrando el payload)
  }

  String _extractHost(String baseUrl) {
    return baseUrl;
  }

  @override
  Future<void> onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    final path = options.path;

    if (isPublicPath(path)) {
      options.headers.remove('x-session-id');
      return handler.next(options);
    }

    if (!isSensitivePath(path)) {
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
    final path = response.requestOptions.path;
    if (isPublicPath(path) || !isSensitivePath(path)) {
      return handler.next(response);
    }

    if (response.data is Map && response.data['payload'] != null) {
      final host = _extractHost(response.requestOptions.baseUrl);
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

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    if (isPublicPath(path) || !isSensitivePath(path)) {
      return handler.next(err);
    }

    if (err.response?.statusCode == 401) {
      final body = err.response?.data;
      final msg = body is Map
          ? (body['mensaje'] ?? body['message'] ?? body['error'] ?? '')
              .toString()
          : body?.toString() ?? '';
      if (msg.contains('Sesion criptografica invalida') ||
          msg.toLowerCase().contains('sesion criptografica') ||
          msg.toLowerCase().contains('session')) {
        await SessionManager.clearAll();
        return handler.next(err);
      }
    }
    handler.next(err);
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
