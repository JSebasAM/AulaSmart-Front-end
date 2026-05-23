import '../entities/aula_entity.dart';
import '../entities/tipo_aula_entity.dart';
import '../entities/bloque_entity.dart';

abstract class IAulaRepository {
  Future<List<AulaEntity>> getAulas({int? page, int? size});
  Future<AulaEntity> getById(int id);
  Future<AulaEntity> create(Map<String, dynamic> payload);
  Future<AulaEntity> update(Map<String, dynamic> payload);
  Future<void> delete(int id);
  Future<List<TipoAulaEntity>> getTiposAula();
  Future<List<BloqueEntity>> getBloques();
}
