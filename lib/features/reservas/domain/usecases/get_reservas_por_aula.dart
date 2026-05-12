import '../entities/reserva_entity.dart';
import '../repositories/reserva_repository.dart';

class GetReservasPorAula {
  final ReservaRepository repository;

  GetReservasPorAula(this.repository);

  Future<List<ReservaEntity>> call(int aulaId) async {
    return repository.getReservasPorAula(aulaId);
  }
}
