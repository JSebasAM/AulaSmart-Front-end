import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'crypto_service.dart';
import 'session_manager.dart';
import 'storage_service.dart';

class CryptoInterceptor extends Interceptor {
  final Dio _cleanDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
  final Dio _dio;
  final StorageService _storage;
  final Map<String, Future<SessionEntry?>> _pendingHandshakes = {};
  static const _maxRetries = 2;
  static const _sessionRetries = 1;

  CryptoInterceptor(this._storage, this._dio);

  static bool isPublicPath(String path) {
    return path.contains('/auth/') || path.contains('/crypto/');
  }

  static bool isSensitivePath(String path) {
    if (isPublicPath(path)) return false;
    return path.contains('/aula-service/') ||
        path.contains('/usuario-service/') ||
        path.contains('/chat') ||
        path.contains('/reserva-service/') ||
        path.contains('/incidencia-service/');
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

    final method = options.method.toUpperCase();

    final host = _extractHost(options.baseUrl);

    if (options.extra['_skipCrypto'] == true) {
      options.extra.remove('_skipCrypto');
      return handler.next(options);
    }

    var session = await SessionManager.getSession(host);

    if (session == null) {
      debugPrint('[CryptoInterceptor] Sin sesion para $host, iniciando handshake...');
      session = await _handshakeOrWait(host);
    }

    if (session == null) {
      return handler.reject(DioException(
          requestOptions: options,
          error: 'No hay sesion criptografica disponible'));
    }

    if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
      options.extra['_originalBody'] = options.data;
      final plainBody = jsonEncode(options.data ?? {});
      debugPrint('[CryptoInterceptor] Cifrando body para $method $path');
      debugPrint('[CryptoInterceptor] Body original (${plainBody.length} chars): $plainBody');
      final aes =
          AesHelper(Uint8List.fromList(base64Decode(session.aesKeyBase64)));
      final encrypted = aes.encryptText(plainBody);
      options.data = {'payload': encrypted};
    }

    options.headers['x-session-id'] = session.sessionId;
    handler.next(options);
  }

  Future<SessionEntry?> _handshakeOrWait(String host) async {
    if (_pendingHandshakes.containsKey(host)) {
      debugPrint('[CryptoInterceptor] Handshake en progreso para $host, esperando...');
      try {
        return await _pendingHandshakes[host];
      } catch (_) {
        return null;
      }
    }

    final future = _performHandshake(host);
    _pendingHandshakes[host] = future;

    try {
      return await future;
    } catch (e) {
      _pendingHandshakes.remove(host);
      return null;
    } finally {
      _pendingHandshakes.remove(host);
    }
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
        try {
          final decrypted = aes.decryptText(response.data['payload']);
          debugPrint('[CryptoInterceptor] Respuesta descifrada correctamente para $path');
          try {
            response.data = jsonDecode(decrypted);
          } catch (_) {
            response.data = decrypted;
          }
        } catch (e) {
          debugPrint('[CryptoInterceptor] ERROR descifrando respuesta: $e');
        }
      } else {
        debugPrint('[CryptoInterceptor] Sin sesion para descifrar respuesta de $path');
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

    final host = _extractHost(err.requestOptions.baseUrl);
    final statusCode = err.response?.statusCode;

    if (err.response?.data is Map) {
      final data = err.response?.data as Map;
      final error = data['error']?.toString() ?? '';
      final message = data['message']?.toString() ?? '';
      debugPrint('[CryptoInterceptor] Error en $path | status=$statusCode | error=$error | message=$message');
    } else {
      debugPrint('[CryptoInterceptor] Error en $path | status=$statusCode | data=${err.response?.data}');
    }

    final isCryptoError = _isLikelyCryptoError(err);

    if (isCryptoError) {
      debugPrint('[CryptoInterceptor] Error criptografico detectado, renovando sesion...');
      final retried = await _retryWithNewSession(err, host, path);
      if (retried != null) return handler.resolve(retried);
      return handler.next(err);
    }

    if (_isLikelySessionExpired(err)) {
      debugPrint('[CryptoInterceptor] Posible sesion expirada (5xx en peticion cifrada), renovando...');
      final retried = await _retryWithNewSession(err, host, path);
      if (retried != null) return handler.resolve(retried);
      return handler.next(err);
    }

    if (statusCode == 401) {
      final body = err.response?.data;
      final msg = body is Map
          ? (body['mensaje'] ?? body['message'] ?? body['error'] ?? '')
              .toString()
          : body?.toString() ?? '';
      if (msg.contains('Sesion criptografica invalida') ||
          msg.toLowerCase().contains('sesion criptografica') ||
          msg.toLowerCase().contains('session')) {
        debugPrint('[CryptoInterceptor] 401 con mensaje de sesion, limpiando...');
        await SessionManager.clearAll();
      }
    }
    handler.next(err);
  }

  Future<Response?> _retryWithNewSession(DioException err, String host, String path) async {
    await SessionManager.removeSession(host);
    final retryCount = (err.requestOptions.extra['_cryptoRetryCount'] as int?) ?? 0;
    if (retryCount >= _maxRetries) {
      debugPrint('[CryptoInterceptor] Maximos reintentos alcanzados ($_maxRetries)');
      return null;
    }
    try {
      final newSession = await _performHandshake(host);
      final method = err.requestOptions.method.toUpperCase();
      if (method == 'POST' || method == 'PUT' || method == 'PATCH') {
        final originalBody = err.requestOptions.extra['_originalBody'];
        if (originalBody != null) {
          final aes = AesHelper(
              Uint8List.fromList(base64Decode(newSession.aesKeyBase64)));
          final plainBody = jsonEncode(originalBody);
          final encrypted = aes.encryptText(plainBody);
          err.requestOptions.data = {'payload': encrypted};
        }
      }
      err.requestOptions.headers['x-session-id'] = newSession.sessionId;
      err.requestOptions.extra['_cryptoRetryCount'] = retryCount + 1;
      err.requestOptions.extra['_skipCrypto'] = true;
      if (err.requestOptions.data is Map) {
        debugPrint('[CryptoInterceptor] Body del reintento: ${jsonEncode(err.requestOptions.data)}');
      }
      debugPrint('[CryptoInterceptor] Reintentando peticion $path con nueva sesion...');
      return await _dio.fetch(err.requestOptions);
    } catch (e) {
      debugPrint('[CryptoInterceptor] Error en reintento: $e');
      return null;
    }
  }

  bool _isLikelySessionExpired(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    if (method != 'POST' && method != 'PUT' && method != 'PATCH') return false;
    final hadOriginalBody = err.requestOptions.extra.containsKey('_originalBody');
    if (!hadOriginalBody) return false;
    final statusCode = err.response?.statusCode ?? 0;
    if (statusCode < 500) return false;
    final sessionRetryCount = (err.requestOptions.extra['_sessionRetryCount'] as int?) ?? 0;
    if (sessionRetryCount >= _sessionRetries) return false;
    debugPrint('[CryptoInterceptor] 5xx en peticion cifrada: status=$statusCode, posible sesion expirada');
    return true;
  }

  bool _isLikelyCryptoError(DioException err) {
    final method = err.requestOptions.method.toUpperCase();
    if (method != 'POST' && method != 'PUT' && method != 'PATCH') {
      return false;
    }

    final hadOriginalBody = err.requestOptions.extra.containsKey('_originalBody');
    if (!hadOriginalBody) return false;

    final statusCode = err.response?.statusCode ?? 0;
    if (statusCode < 400) return false;

    if (err.response?.data is Map) {
      final data = err.response?.data as Map;
      final error = data['error']?.toString() ?? '';
      final message = data['message']?.toString() ?? '';

      if (error.contains('Payload invalido') ||
          error.contains('Error cifrando respuesta') ||
          error.toLowerCase().contains('sesion criptografica') ||
          message.toLowerCase().contains('payload')) {
        return true;
      }
    }

    return false;
  }

  Future<SessionEntry> _performHandshake(String baseUrl) async {
    debugPrint('[CryptoInterceptor] Realizando handshake con $baseUrl...');

    final pkResponse = await _cleanDio.get('$baseUrl/crypto/public-key');
    final n = pkResponse.data['n'] as String;
    final e = pkResponse.data['e'] as String;
    debugPrint('[CryptoInterceptor] Clave publica RSA obtenida');

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
    debugPrint('[CryptoInterceptor] Handshake completado | sessionId=$sessionId');
    return entry;
  }
}
