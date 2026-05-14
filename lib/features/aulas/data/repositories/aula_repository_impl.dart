import 'package:dio/dio.dart';
import '../../domain/entities/aula_entity.dart';
import '../../domain/repositories/iaula_repository.dart';
import '../models/aula_model.dart';

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
      throw Exception('Error de conexion al obtener aulas: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado parseando aulas: $e');
    }
  }
}
