import 'package:dio/dio.dart';

class IncidenciaRemoteDataSource {
  final Dio dio;
  IncidenciaRemoteDataSource(this.dio);

  Future<List<Map<String, dynamic>>> fetchAll() async {
    final r = await dio.get('/incidencia-service/incidencias');
    final list = (r.data['incidencias'] as List?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> fetchPendientes() async {
    final r = await dio.get('/incidencia-service/incidencias/pendientes');
    final list = (r.data['incidencias'] as List?) ?? [];
    return list.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<int> fetchCountPendientes() async {
    final r = await dio.get('/incidencia-service/incidencias/pendientes/count');
    return r.data['cantidad'] as int;
  }

  Future<Map<String, dynamic>> fetchById(String id) async {
    final r = await dio.get('/incidencia-service/incidencias/$id');
    return Map<String, dynamic>.from((r.data['incidencia'] as Map?) ?? r.data);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final r = await dio.post('/incidencia-service/incidencias', data: body);
    return Map<String, dynamic>.from((r.data['incidencia'] as Map?) ?? r.data);
  }

  Future<Map<String, dynamic>> update(String id, Map<String, dynamic> body) async {
    final r = await dio.put('/incidencia-service/incidencias/$id', data: body);
    return Map<String, dynamic>.from((r.data['incidencia'] as Map?) ?? r.data);
  }

  Future<Map<String, dynamic>> uploadImage(String id, String filePath) async {
    final fd = FormData.fromMap({'imagen': await MultipartFile.fromFile(filePath)});
    final r = await dio.post('/incidencia-service/incidencias/$id/imagen', data: fd);
    return Map<String, dynamic>.from((r.data['incidencia'] as Map?) ?? r.data);
  }

  Future<Map<String, dynamic>> responder(String id, String respuesta) async {
    final r = await dio.put('/incidencia-service/incidencias/$id/responder',
        data: {'respuesta': respuesta});
    return Map<String, dynamic>.from((r.data['incidencia'] as Map?) ?? r.data);
  }

  Future<void> delete(String id) async {
    await dio.delete('/incidencia-service/incidencias/$id');
  }

  String imageUrl(String filename) =>
      '${dio.options.baseUrl.replaceAll('/api/v1', '')}/app/uploads/incidencias/$filename';
}
