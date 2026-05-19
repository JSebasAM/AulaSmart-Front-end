import '../entities/reserva_entity.dart';
import '../repositories/reserva_repository.dart';

class ConfirmarReserva {
  final ReservaRepository repository;
  ConfirmarReserva(this.repository);
  Future<ReservaEntity> call(String id) => repository.confirmarReserva(id);
}
