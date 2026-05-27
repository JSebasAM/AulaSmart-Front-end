import '../entities/reserva_entity.dart';

abstract class ReservaRepository {
  Future<List<ReservaEntity>> getReservasPorAula(int aulaId);
  Future<List<ReservaEntity>> getMisReservas();
  Future<List<ReservaEntity>> getReservasPendientes();
  Future<ReservaEntity> createReserva(Map<String, dynamic> body);
  Future<ReservaEntity> confirmarReserva(String id);
  Future<ReservaEntity> rechazarReserva(String id);
  Future<void> cancelarReserva(String id);
}
