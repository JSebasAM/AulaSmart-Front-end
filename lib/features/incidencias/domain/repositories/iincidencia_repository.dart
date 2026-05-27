import '../entities/incidencia_entity.dart';

abstract class IIncidenciaRepository {
  Future<List<IncidenciaEntity>> getAll();
  Future<List<IncidenciaEntity>> getPendientes();
  Future<int> getCountPendientes();
  Future<IncidenciaEntity> getById(String id);
  Future<IncidenciaEntity> create(Map<String, dynamic> body);
  Future<IncidenciaEntity> update(String id, Map<String, dynamic> body);
  Future<IncidenciaEntity> uploadImage(String id, String filePath);
  Future<IncidenciaEntity> responder(String id, String respuesta);
  Future<void> delete(String id);
  String imageUrl(String filename);
}
