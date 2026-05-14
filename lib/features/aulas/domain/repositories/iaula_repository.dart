import '../entities/aula_entity.dart';

abstract class IAulaRepository {
  Future<List<AulaEntity>> getAulas({int? page, int? size});
}
