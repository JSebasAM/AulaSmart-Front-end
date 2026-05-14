import '../entities/reserva_entity.dart';
import '../repositories/reserva_repository.dart';

class CreateReserva {
  final ReservaRepository repository;

  CreateReserva(this.repository);

  Future<ReservaEntity> call(Map<String, dynamic> body) async {
    return repository.createReserva(body);
  }
}
