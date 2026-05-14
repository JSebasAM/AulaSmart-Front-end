import '../entities/usuario_entity.dart';

abstract class IUsuarioRepository {
  Future<List<UsuarioEntity>> getAll();
  Future<UsuarioEntity> getById(String id);
  Future<UsuarioEntity> create(Map<String, dynamic> payload);
  Future<UsuarioEntity> update(String id, Map<String, dynamic> payload);
  Future<void> delete(String id);
}
