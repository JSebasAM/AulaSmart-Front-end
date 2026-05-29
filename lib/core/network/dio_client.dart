import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../storage/storage_service.dart';
import '../security/crypto_interceptor.dart';
import '../auth/session_provider.dart';

class ApiUrls {
  static String get auth        => dotenv.env['API_AUTH'] ?? 'http://localhost:8081/api/v1';
  static String get usuarios    => dotenv.env['API_USUARIOS'] ?? 'http://localhost:8081/api/v1';
  static String get reservas    => dotenv.env['API_RESERVAS'] ?? 'http://localhost:8082/api/v1';
  static String get aulas       => dotenv.env['API_AULAS'] ?? 'http://localhost:8083/api/v1';
  static String get incidencias => dotenv.env['API_INCIDENCIAS'] ?? 'http://localhost:8085/api/v1';
  static String get chat        => dotenv.env['API_CHAT'] ?? 'http://localhost:8086/api/v1';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 20),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(_AuthInterceptor(StorageService(), dio, onSessionExpired: () => ref.read(sessionExpiredProvider.notifier).state = true));
  dio.interceptors.add(CryptoInterceptor(StorageService(), dio));
  if (kDebugMode) {
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => debugPrint('[DIO] $obj'),
    ));
  }

  return dio;
});

class _AuthInterceptor extends QueuedInterceptor {
  final StorageService _storage;
  final Dio _dio;
  final void Function()? _onSessionExpired;
  bool _isRefreshing = false;
  DateTime? _lastRefreshAttempt;
  static const _cooldown = Duration(seconds: 30);

  _AuthInterceptor(this._storage, this._dio, {void Function()? onSessionExpired})
      : _onSessionExpired = onSessionExpired;

  bool get _canRefresh {
    if (_lastRefreshAttempt == null) return true;
    return DateTime.now().difference(_lastRefreshAttempt!) > _cooldown;
  }

  Future<bool> _attemptRefresh() async {
    if (_isRefreshing) return false;

    _isRefreshing = true;
    _lastRefreshAttempt = DateTime.now();
    try {
      final refreshToken = await _storage.refreshToken;
      if (refreshToken == null) return false;

      final refreshDio = Dio(BaseOptions(
        baseUrl: ApiUrls.auth,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      ));

      final response = await refreshDio.post('/auth/refresh');

      final data = response.data['data'] as Map<String, dynamic>;

      await _storage.saveTokens(
        accessToken: data['access_token'] as String,
        refreshToken: data['refresh_token'] as String,
      );
      return true;
    } catch (e) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path.contains('/auth/')) {
      return handler.next(options);
    }

    final isValid = await _storage.hasValidToken;
    final canRefresh = _canRefresh;
    final hasRefresh = await _storage.refreshToken;

    var refreshFailed = false;
    if (!isValid && canRefresh) {
      if (hasRefresh != null) {
        final ok = await _attemptRefresh();
        if (!ok) refreshFailed = true;
      }
    }

    final token = await _storage.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    } else if (refreshFailed) {
      _onSessionExpired?.call();
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 || err.response?.statusCode == 403) {
      final hadToken = err.requestOptions.headers.containsKey('Authorization');
      if (!hadToken) {
        return handler.next(err);
      }

      final refreshed = await _attemptRefresh();
      if (!refreshed) {
        _onSessionExpired?.call();
        return handler.next(err);
      }

      final newAccess = await _storage.accessToken;
      if (newAccess == null) return handler.next(err);

      err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
      try {
        final retryResponse = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      } catch (e) {
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
