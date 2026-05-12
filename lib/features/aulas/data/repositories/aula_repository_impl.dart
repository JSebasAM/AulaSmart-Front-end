import 'package:dio/dio.dart';
import '../../domain/entities/aula_entity.dart';
import '../../domain/repositories/iaula_repository.dart';
import '../models/aula_model.dart';

class AulaRepositoryImpl implements IAulaRepository {
  final Dio dio;

  AulaRepositoryImpl({required this.dio});

  @override
  Future<List<AulaEntity>> getAulas() async {
    try {
      final response = await dio.get('/aula-service/aulas');

      if (response.statusCode == 200) {
        // En base a la respuesta proporcionada: { "aulas": [...] }
        final List<dynamic> data = response.data['aulas'];
        return data.map((json) => AulaModel.fromJson(json)).toList();
      } else {
        throw Exception('Error HTTP: ${response.statusCode}');
      }
    } on DioException catch (e) {
      throw Exception('Error de conexión al obtener aulas: ${e.message}');
    } catch (e) {
      throw Exception('Error inesperado parseando aulas: \$e');
    }
  }
}
