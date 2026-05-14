import '../entities/reserva_entity.dart';

abstract class ReservaRepository {
  Future<List<ReservaEntity>> getReservasPorAula(int aulaId);
  Future<List<ReservaEntity>> getMisReservas();
  Future<ReservaEntity> createReserva(Map<String, dynamic> body);
}
