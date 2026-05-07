
import 'package:aulasmart_front_end/views/new_report_modal_view.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'storage_service.dart';

class ApiUrls {
  static String get usuarios    => dotenv.env['API_USUARIOS'] ?? 'http://localhost:8081/api/v1';
  static String get reservas    => dotenv.env['API_RESERVAS'] ?? 'http://localhost:8082/api/v1';
  static String get aulas       => dotenv.env['API_AULAS'] ?? 'http://localhost:8083/api/v1';
  static String get incidencias => dotenv.env['API_INCIDENCIAS'] ?? 'http://localhost:8084/api/v1';
}

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));

  dio.interceptors.add(_AuthInterceptor(StorageService(), dio));
  return dio;
});

class _AuthInterceptor extends QueuedInterceptor {
  final StorageService _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    if (kDebugMode) {
      print('INTERCEPTOR_REQUEST: ${options.uri}');
      print('INTERCEPTOR_HAS_TOKEN: ${token != null}');
    }
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
  
  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401) {
      try{
        final refreshToken = await _storage.refreshToken;
        if(refreshToken == null){
          await _storage.clearTokens();
          return handler.next(err);
        }

        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiUrls.usuarios,
          headers: {'Content-Type': 'application/json'},
        ));

        final response = await refreshDio.post(
          '/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final newAccess = response.data['access_token'] as String;
        final newRefresh = response.data['refresh_token'] as String;

        await _storage.saveTokens(
          accessToken: newAccess,
          refreshToken: newRefresh,
        );
        
        err.requestOptions.headers['Authorization'] = 'Bearer $newAccess';
        final retryResponse = await _dio.fetch(err.requestOptions);
        return handler.resolve(retryResponse);
      }catch(_){
        await _storage.clearTokens();
        return handler.next(err);
      }
    }
    handler.next(err);
  }
}
