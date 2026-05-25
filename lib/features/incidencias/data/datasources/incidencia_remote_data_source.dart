import 'package:dio/dio.dart';

class IncidenciaRemoteDataSource {
  final Dio dio;
  IncidenciaRemoteDataSource(this.dio);

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final response = await dio.get('/incidencia-service/incidencias');
    final data = response.data;
    final list = (data['incidencias'] as List?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPendientes() async {
    final response =
        await dio.get('/incidencia-service/incidencias/pendientes');
    final data = response.data;
    final list = (data['incidencias'] as List?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final response = await dio.post(
      '/incidencia-service/incidencias',
      data: body,
    );
    final data = response.data;
    return Map<String, dynamic>.from(
        (data['incidencia'] as Map?) ?? data);
  }

  Future<Map<String, dynamic>> uploadImage(
      String id, String filePath) async {
    final formData = FormData.fromMap({
      'imagen': await MultipartFile.fromFile(filePath),
    });
    final response = await dio.post(
      '/incidencia-service/incidencias/$id/imagen',
      data: formData,
    );
    final data = response.data;
    return Map<String, dynamic>.from(
        (data['incidencia'] as Map?) ?? data);
  }

  Future<Map<String, dynamic>> responder(
      String id, String respuesta) async {
    final response = await dio.put(
      '/incidencia-service/incidencias/$id/responder',
      data: {'respuesta': respuesta},
    );
    final data = response.data;
    return Map<String, dynamic>.from(
        (data['incidencia'] as Map?) ?? data);
  }

  Future<int> fetchCountPendientes() async {
    final response = await dio
        .get('/incidencia-service/incidencias/pendientes/count');
    return response.data['cantidad'] as int;
  }

  String imageUrl(String filename) {
    return '${dio.options.baseUrl.replaceAll('/api/v1', '')}/uploads/incidencias/$filename';
  }
}
