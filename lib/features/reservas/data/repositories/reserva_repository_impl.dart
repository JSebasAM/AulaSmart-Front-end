import '../../domain/entities/reserva_entity.dart';
import '../../domain/repositories/reserva_repository.dart';
import '../datasources/reserva_remote_data_source.dart';
import '../models/reserva_model.dart';

class ReservaRepositoryImpl implements ReservaRepository {
  final ReservaRemoteDataSource remoteDataSource;

  // Simple in-memory cache keyed by aulaId
  final Map<int, _CacheItem> _cache = {};
  final Duration cacheTtl = const Duration(seconds: 30);

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
}

class _CacheItem {
  final DateTime fetchedAt;
  final List<ReservaEntity> data;
  _CacheItem(this.fetchedAt, this.data);
}
