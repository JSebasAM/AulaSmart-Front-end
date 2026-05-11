import '../entities/aula_entity.dart';

abstract class IAulaRepository {
  Future<List<AulaEntity>> getAulas();
  // En el futuro, podemos agregar métodos como getAulaById(int id), getAulasDisponibles(...), etc.
}
