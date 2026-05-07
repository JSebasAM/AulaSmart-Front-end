import 'package:dio/dio.dart';
import 'api_exception.dart';

abstract class BaseService {

  const BaseService(this.dio);
  final Dio dio;

  Future<T> get<T>(String path, {
    Map<String, dynamic>? queryParameters, required T Function(dynamic  data) parser,
    }) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
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
      final res = await dio.post(path, data: data);
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
      final res = await dio.put(path, data: data);
      return parser(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  Future<void> delete(String path) async {
    try {
      await dio.delete(path);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}