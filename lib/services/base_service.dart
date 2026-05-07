import 'package:dio/dio.dart';
import 'api_exception.dart';

abstract class BaseService {

  const BaseService(this._dio, this._baseUrl);
  final Dio _dio;
  final String _baseUrl;

//URL completa para cada endpoint
 String _url(String path) => '$_baseUrl$path';

// Métodos genéricos para realizar solicitudes HTTP
  Future<T> get<T>(
    String path,
   {
    Map<String, dynamic>? queryParameters, required T Function(dynamic  data) parser,
    }) async {
    try {
      final response = await _dio.get(_url(path), queryParameters: queryParameters);
      return parser(response.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> post<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final res = await _dio.post(_url(path), data: data);
      return parser(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<T> put<T>(
    String path, {
    required Map<String, dynamic> data,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final res = await _dio.put(_url(path), data: data);
      return parser(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await _dio.delete(_url(path));
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}