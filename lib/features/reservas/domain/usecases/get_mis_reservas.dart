import '../entities/reserva_entity.dart';
import '../repositories/reserva_repository.dart';

class GetMisReservas {
  final ReservaRepository repository;

  GetMisReservas(this.repository);

  Future<List<ReservaEntity>> call() async {
    return repository.getMisReservas();
  }
}
