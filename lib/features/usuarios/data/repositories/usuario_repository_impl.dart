import 'package:dio/dio.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../domain/repositories/iusuario_repository.dart';
import '../models/usuario_model.dart';
import '../../../../services/api_exception.dart';

class UsuarioRepositoryImpl implements IUsuarioRepository {
  final Dio dio;

  UsuarioRepositoryImpl({required this.dio});

  @override
  Future<List<UsuarioEntity>> getAll() async {
    try {
      final response = await dio.get('/usuario-service/usuarios');

      List<dynamic> list = [];
      if (response.data is List) {
        list = response.data as List<dynamic>;
      } else if (response.data is Map) {
        list = response.data['data'] ??
            response.data['usuarios'] ??
            response.data['content'] ??
            [];
      }

      return list
          .map((e) => UsuarioModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UsuarioEntity> getById(String id) async {
    try {
      final response = await dio.get('/usuario-service/usuarios/$id');
      if (response.data is Map && response.data['usuario'] != null) {
        return UsuarioModel.fromJson(
          response.data['usuario'] as Map<String, dynamic>,
        );
      }
      return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UsuarioEntity> create(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post(
        '/usuario-service/usuarios',
        data: payload,
      );
      if (response.data is Map && response.data['usuario'] != null) {
        return UsuarioModel.fromJson(
          response.data['usuario'] as Map<String, dynamic>,
        );
      }
      return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<UsuarioEntity> update(String id, Map<String, dynamic> payload) async {
    try {
      final response = await dio.put(
        '/usuario-service/usuarios/$id',
        data: payload,
      );
      if (response.data is Map && response.data['usuario'] != null) {
        return UsuarioModel.fromJson(
          response.data['usuario'] as Map<String, dynamic>,
        );
      }
      return UsuarioModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> delete(String id) async {
    try {
      await dio.delete('/usuario-service/usuarios/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
