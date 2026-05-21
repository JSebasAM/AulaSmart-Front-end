import '../entities/reserva_entity.dart';
import '../repositories/reserva_repository.dart';

class GetReservasPendientes {
  final ReservaRepository repository;
  GetReservasPendientes(this.repository);
  Future<List<ReservaEntity>> call() => repository.getReservasPendientes();
}
