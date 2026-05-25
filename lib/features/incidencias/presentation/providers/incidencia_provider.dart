import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/services/dio_client.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/data/datasources/incidencia_remote_data_source.dart';
import 'package:aulasmart_front_end/features/incidencias/data/repositories/incidencia_repository_impl.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/repositories/iincidencia_repository.dart';

final incidenciaRemoteDataSourceProvider =
    Provider<IncidenciaRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  final dioInc = Dio(dio.options.copyWith(
    baseUrl: ApiUrls.incidencias,
    receiveTimeout: const Duration(seconds: 60),
  ));
  dioInc.interceptors.addAll(dio.interceptors);
  return IncidenciaRemoteDataSource(dioInc);
});

final incidenciaRepositoryProvider = Provider<IIncidenciaRepository>((ref) {
  final remote = ref.read(incidenciaRemoteDataSourceProvider);
  return IncidenciaRepositoryImpl(remote: remote);
});

final incidenciasPendientesProvider =
    FutureProvider.autoDispose<List<IncidenciaEntity>>((ref) async {
  final repo = ref.read(incidenciaRepositoryProvider);
  return repo.getPendientes();
});

final todasLasIncidenciasProvider =
    FutureProvider<List<IncidenciaEntity>>((ref) async {
  final repo = ref.read(incidenciaRepositoryProvider);
  return repo.getAll();
});

final incidenciasCountProvider =
    NotifierProvider<IncidenciasCountNotifier, AsyncValue<int>>(
        IncidenciasCountNotifier.new);

class IncidenciasCountNotifier extends Notifier<AsyncValue<int>> {
  Timer? _timer;

  @override
  AsyncValue<int> build() {
    _fetch();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) => _fetch());
    return const AsyncValue.loading();
  }

  Future<void> _fetch() async {
    try {
      final repo = ref.read(incidenciaRepositoryProvider);
      final count = await repo.getCountPendientes();
      state = AsyncValue.data(count);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

Future<IncidenciaEntity> crearIncidencia(
    WidgetRef ref, Map<String, dynamic> body) async {
  final repo = ref.read(incidenciaRepositoryProvider);
  return repo.create(body);
}

Future<IncidenciaEntity> subirImagenIncidencia(
    WidgetRef ref, String id, String filePath) async {
  final repo = ref.read(incidenciaRepositoryProvider);
  return repo.uploadImage(id, filePath);
}

Future<IncidenciaEntity> responderIncidencia(
    WidgetRef ref, String id, String respuesta) async {
  final repo = ref.read(incidenciaRepositoryProvider);
  return repo.responder(id, respuesta);
}
