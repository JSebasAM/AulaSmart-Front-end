import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/core/network/dio_client.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/data/datasources/incidencia_remote_data_source.dart';
import 'package:aulasmart_front_end/features/incidencias/data/repositories/incidencia_repository_impl.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/repositories/iincidencia_repository.dart';

final incidenciaRemoteDsProvider = Provider<IncidenciaRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final d = Dio(dio.options.copyWith(
    baseUrl: ApiUrls.incidencias,
    receiveTimeout: const Duration(seconds: 60),
  ));
  d.interceptors.addAll(dio.interceptors);
  return IncidenciaRemoteDataSource(d);
});

final incidenciaRepoProvider = Provider<IIncidenciaRepository>((ref) {
  final remote = ref.read(incidenciaRemoteDsProvider);
  return IncidenciaRepositoryImpl(remote: remote);
});

final incidenciasPendientesProvider =
    FutureProvider.autoDispose<List<IncidenciaEntity>>((ref) async {
  return ref.read(incidenciaRepoProvider).getPendientes();
});

final todasLasIncidenciasProvider =
    FutureProvider<List<IncidenciaEntity>>((ref) async {
  return ref.read(incidenciaRepoProvider).getAll();
});

final incidenciasCountProvider =
    NotifierProvider<IncidenciaCountNotifier, AsyncValue<int>>(
        IncidenciaCountNotifier.new);

class IncidenciaCountNotifier extends Notifier<AsyncValue<int>> {
  Timer? _timer;
  @override
  AsyncValue<int> build() {
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());
    return const AsyncValue.loading();
  }
  Future<void> _fetch() async {
    try {
      state = AsyncValue.data(await ref.read(incidenciaRepoProvider).getCountPendientes());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final incidenciaByIdProvider =
    FutureProvider.family<IncidenciaEntity, String>((ref, id) async {
  return ref.read(incidenciaRepoProvider).getById(id);
});

Future<IncidenciaEntity> crearIncidencia(WidgetRef ref, Map<String, dynamic> body) async =>
    ref.read(incidenciaRepoProvider).create(body);

Future<IncidenciaEntity> subirImagen(WidgetRef ref, String id, String filePath) async =>
    ref.read(incidenciaRepoProvider).uploadImage(id, filePath);

Future<IncidenciaEntity> responderIncidencia(WidgetRef ref, String id, String r) async =>
    ref.read(incidenciaRepoProvider).responder(id, r);

Future<void> eliminarIncidencia(WidgetRef ref, String id) async =>
    ref.read(incidenciaRepoProvider).delete(id);

Future<IncidenciaEntity> actualizarIncidencia(WidgetRef ref, String id, Map<String, dynamic> b) async =>
    ref.read(incidenciaRepoProvider).update(id, b);
