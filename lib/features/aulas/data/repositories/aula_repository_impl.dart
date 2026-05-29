import 'package:dio/dio.dart';
import '../../domain/entities/aula_entity.dart';
import '../../domain/entities/tipo_aula_entity.dart';
import '../../domain/entities/bloque_entity.dart';
import '../../domain/repositories/iaula_repository.dart';
import '../models/aula_model.dart';
import '../models/tipo_aula_model.dart';
import '../models/bloque_model.dart';
import '../../../../core/error/api_exception.dart';

class AulaRepositoryImpl implements IAulaRepository {
  final Dio dio;

  AulaRepositoryImpl({required this.dio});

  @override
  Future<List<AulaEntity>> getAulas({int? page, int? size}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (page != null) queryParams['page'] = page;
      if (size != null) queryParams['size'] = size;

      final response = await dio.get(
        '/aula-service/aulas',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['aulas'];
        return data.map((json) => AulaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    } catch (e) {
      throw Exception('Error inesperado parseando aulas: $e');
    }
  }

  @override
  Future<AulaEntity> getById(int id) async {
    try {
      final response = await dio.get('/aula-service/aulas/$id');
      return AulaModel.fromJson(
        response.data['aula'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AulaEntity> create(Map<String, dynamic> payload) async {
    try {
      final response = await dio.post(
        '/aula-service/aulas',
        data: payload,
      );
      return AulaModel.fromJson(
        response.data['aula'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<AulaEntity> update(Map<String, dynamic> payload) async {
    try {
      final response = await dio.put(
        '/aula-service/aulas',
        data: payload,
      );
      return AulaModel.fromJson(
        response.data['aula'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await dio.delete('/aula-service/aulas/$id');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<TipoAulaEntity>> getTiposAula() async {
    try {
      final response = await dio.get('/aula-service/tipos-aula');
      final List<dynamic> data = response.data['tiposAula'];
      return data
          .map((json) => TipoAulaModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<BloqueEntity>> getBloques() async {
    try {
      final response = await dio.get('/aula-service/bloques');
      final List<dynamic> data = response.data['bloques'];
      return data
          .map((json) => BloqueModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}
