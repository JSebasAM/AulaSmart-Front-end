import '../../domain/entities/incidencia_entity.dart';
import '../../domain/repositories/iincidencia_repository.dart';
import '../datasources/incidencia_remote_data_source.dart';
import '../models/incidencia_model.dart';

class IncidenciaRepositoryImpl implements IIncidenciaRepository {
  final IncidenciaRemoteDataSource remote;
  IncidenciaRepositoryImpl({required this.remote});

  @override
  Future<List<IncidenciaEntity>> getAll() async {
    final raw = await remote.fetchAll();
    return raw.map((e) => IncidenciaModel.fromJson(e)).toList();
  }

  @override
  Future<List<IncidenciaEntity>> getPendientes() async {
    final raw = await remote.fetchPendientes();
    return raw.map((e) => IncidenciaModel.fromJson(e)).toList();
  }

  @override
  Future<IncidenciaEntity> create(Map<String, dynamic> body) async {
    final raw = await remote.create(body);
    return IncidenciaModel.fromJson(raw);
  }

  @override
  Future<IncidenciaEntity> uploadImage(String id, String filePath) async {
    final raw = await remote.uploadImage(id, filePath);
    return IncidenciaModel.fromJson(raw);
  }

  @override
  Future<IncidenciaEntity> responder(String id, String respuesta) async {
    final raw = await remote.responder(id, respuesta);
    return IncidenciaModel.fromJson(raw);
  }

  @override
  Future<int> getCountPendientes() async {
    return remote.fetchCountPendientes();
  }

  @override
  String imageUrl(String filename) {
    return remote.imageUrl(filename);
  }
}
