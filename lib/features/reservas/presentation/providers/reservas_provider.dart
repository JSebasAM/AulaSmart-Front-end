import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:aulasmart_front_end/services/dio_client.dart';
import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/domain/usecases/get_reservas_por_aula.dart';
import 'package:aulasmart_front_end/features/reservas/domain/usecases/get_mis_reservas.dart';
import 'package:aulasmart_front_end/features/reservas/domain/usecases/create_reserva.dart';
import 'package:aulasmart_front_end/features/reservas/data/datasources/reserva_remote_data_source.dart';
import 'package:aulasmart_front_end/features/reservas/data/repositories/reserva_repository_impl.dart';
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

final getMisReservasProvider = Provider((ref) {
  final repo = ref.read(reservaRepositoryProvider);
  return GetMisReservas(repo);
});

final createReservaProvider = Provider((ref) {
  final repo = ref.read(reservaRepositoryProvider);
  return CreateReserva(repo);
});

final reservasPorAulaProvider =
    FutureProvider.family<List<ReservaEntity>, int>((ref, id) async {
  final usecase = ref.read(getReservasPorAulaProvider);
  return usecase.call(id);
});

final todasLasReservasProvider =
    FutureProvider<List<ReservaEntity>>((ref) async {
  final usecase = ref.read(getMisReservasProvider);
  return usecase.call();
});

Map<String, List<Map<String, dynamic>>> _groupReservasJson(
    List<Map<String, dynamic>> items) {
  final map = <String, List<Map<String, dynamic>>>{};
  for (final e in items) {
    final horaInicioRaw =
        e['hora_inicio'] as String? ?? e['horaInicio'] as String? ?? '';
    if (horaInicioRaw.isEmpty) continue;
    final horaInicio = DateTime.parse(horaInicioRaw);
    final key =
        '${horaInicio.year.toString().padLeft(4, '0')}-${horaInicio.month.toString().padLeft(2, '0')}-${horaInicio.day.toString().padLeft(2, '0')}';
    map.putIfAbsent(key, () => []).add(e);
  }
  return map;
}

final reservasEventsProvider = FutureProvider.family<
    Map<String, List<Map<String, dynamic>>>, int>((ref, id) async {
  final reservas = await ref.watch(reservasPorAulaProvider(id).future);
  final payload = reservas.map((r) => r.toJson()).toList();
  return compute(_groupReservasJson, payload);
});
