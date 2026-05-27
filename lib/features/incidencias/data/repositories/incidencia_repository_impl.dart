import '../../domain/entities/incidencia_entity.dart';
import '../../domain/repositories/iincidencia_repository.dart';
import '../datasources/incidencia_remote_data_source.dart';
import '../models/incidencia_model.dart';

class IncidenciaRepositoryImpl implements IIncidenciaRepository {
  final IncidenciaRemoteDataSource remote;
  IncidenciaRepositoryImpl({required this.remote});

  @override Future<List<IncidenciaEntity>> getAll() async =>
      (await remote.fetchAll()).map((e) => IncidenciaModel.fromJson(e)).toList();

  @override Future<List<IncidenciaEntity>> getPendientes() async =>
      (await remote.fetchPendientes()).map((e) => IncidenciaModel.fromJson(e)).toList();

  @override Future<int> getCountPendientes() async => remote.fetchCountPendientes();

  @override Future<IncidenciaEntity> getById(String id) async =>
      IncidenciaModel.fromJson(await remote.fetchById(id));

  @override Future<IncidenciaEntity> create(Map<String, dynamic> body) async =>
      IncidenciaModel.fromJson(await remote.create(body));

  @override Future<IncidenciaEntity> update(String id, Map<String, dynamic> body) async =>
      IncidenciaModel.fromJson(await remote.update(id, body));

  @override Future<IncidenciaEntity> uploadImage(String id, String filePath) async =>
      IncidenciaModel.fromJson(await remote.uploadImage(id, filePath));

  @override Future<IncidenciaEntity> responder(String id, String respuesta) async =>
      IncidenciaModel.fromJson(await remote.responder(id, respuesta));

  @override Future<void> delete(String id) async => remote.delete(id);

  @override String imageUrl(String filename) => remote.imageUrl(filename);
}
