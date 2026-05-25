import '../entities/incidencia_entity.dart';

abstract class IIncidenciaRepository {
  Future<List<IncidenciaEntity>> getAll();
  Future<List<IncidenciaEntity>> getPendientes();
  Future<int> getCountPendientes();
  Future<IncidenciaEntity> create(Map<String, dynamic> body);
  Future<IncidenciaEntity> uploadImage(String id, String filePath);
  Future<IncidenciaEntity> responder(String id, String respuesta);
  String imageUrl(String filename);
}
