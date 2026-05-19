import '../entities/reserva_entity.dart';
import '../repositories/reserva_repository.dart';

class RechazarReserva {
  final ReservaRepository repository;
  RechazarReserva(this.repository);
  Future<ReservaEntity> call(String id) => repository.rechazarReserva(id);
}
