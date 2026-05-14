import '../../domain/entities/reserva_entity.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../datasources/reserva_remote_data_source.dart';
import '../models/reserva_model.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final ReservaRemoteDataSource remoteDataSource;

  final Map<int, _CacheItem> _cache = {};
  final Duration cacheTtl = const Duration(minutes: 2);
  List<ReservaEntity>? _misReservasCache;
  DateTime? _misReservasFetchedAt;

  ReservaRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<ReservaEntity>> getReservasPorAula(int aulaId) async {
    final cached = _cache[aulaId];
    if (cached != null && DateTime.now().difference(cached.fetchedAt) <= cacheTtl) {
      return cached.data;
    }

    final raw = await remoteDataSource.fetchReservasPorAula(aulaId);
    final list = raw.map((e) => ReservaModel.fromJson(e)).toList();
    _cache[aulaId] = _CacheItem(DateTime.now(), list);
    return list;
  }

  @override
  Future<List<ReservaEntity>> getMisReservas() async {
    if (_misReservasCache != null &&
        _misReservasFetchedAt != null &&
        DateTime.now().difference(_misReservasFetchedAt!) <= cacheTtl) {
      return _misReservasCache!;
    }

    final raw = await remoteDataSource.fetchMisReservas();
    final list = raw.map((e) => ReservaModel.fromJson(e)).toList();
    list.sort((a, b) => b.horaInicio.compareTo(a.horaInicio));
    _misReservasCache = list;
    _misReservasFetchedAt = DateTime.now();
    return list;
  }

  @override
  Future<ReservaEntity> createReserva(Map<String, dynamic> body) async {
    final raw = await remoteDataSource.createReserva(body);
    final reserva = ReservaModel.fromJson(raw);
    _cache.remove(body['codigo_aula'] as int?);
    _misReservasCache = null;
    return reserva;
  }

  void invalidateCache(int aulaId) {
    _cache.remove(aulaId);
  }

  void invalidateMisReservasCache() {
    _misReservasCache = null;
  }
}

class _CacheItem {
  final DateTime fetchedAt;
  final List<ReservaEntity> data;
  _CacheItem(this.fetchedAt, this.data);
}
