import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aulasmart_front_end/models/reserva.dart';
import 'package:aulasmart_front_end/services/dio_client.dart';
import 'package:aulasmart_front_end/features/reservas/domain/usecases/get_reservas_por_aula.dart';
import 'package:aulasmart_front_end/features/reservas/data/datasources/reserva_remote_data_source.dart';
import 'package:aulasmart_front_end/features/reservas/data/repositories/reserva_repository_impl.dart';
// domain entity import not required here
import 'package:aulasmart_front_end/features/reservas/domain/repositories/reserva_repository.dart';

final reservaRemoteDataSourceProvider = Provider<ReservaRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final dioReservas = Dio(dio.options.copyWith(baseUrl: ApiUrls.reservas));
  dioReservas.interceptors.addAll(dio.interceptors);
  return ReservaRemoteDataSource(dioReservas);
});

final reservaRepositoryProvider = Provider<ReservaRepository>((ref) {
  final remote = ref.read(reservaRemoteDataSourceProvider);
  return ReservaRepositoryImpl(remoteDataSource: remote);
});

final getReservasPorAulaProvider = Provider((ref) {
  final repo = ref.read(reservaRepositoryProvider);
  return GetReservasPorAula(repo);
});

final reservasPorAulaProvider = FutureProvider.family<List<Reserva>, int>((ref, id) async {
  final usecase = ref.read(getReservasPorAulaProvider);
  final entities = await usecase.call(id);
  return entities.map((e) => Reserva.fromEntity(e)).toList();
});

// Helper executed in an isolate to group reservas by date string (yyyy-MM-dd)
Map<String, List<Map<String, dynamic>>> _groupReservasJson(List<Map<String, dynamic>> items) {
  final map = <String, List<Map<String, dynamic>>>{};
  for (final e in items) {
    final horaInicioRaw = e['hora_inicio'] as String? ?? e['horaInicio'] as String? ?? '';
    if (horaInicioRaw.isEmpty) continue;
    final horaInicio = DateTime.parse(horaInicioRaw);
    final key = '${horaInicio.year.toString().padLeft(4, '0')}-${horaInicio.month.toString().padLeft(2, '0')}-${horaInicio.day.toString().padLeft(2, '0')}';
    map.putIfAbsent(key, () => []).add(e);
  }
  return map;
}

final reservasEventsProvider = FutureProvider.family<Map<String, List<Map<String, dynamic>>>, int>((ref, id) async {
  final reservas = await ref.watch(reservasPorAulaProvider(id).future);
  final payload = reservas.map((r) => r.toJson()).toList();
  return compute(_groupReservasJson, payload);
});
