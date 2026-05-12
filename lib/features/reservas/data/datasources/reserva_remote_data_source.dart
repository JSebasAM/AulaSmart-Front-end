import 'package:dio/dio.dart';

class ReservaRemoteDataSource {
	final Dio dio;

	ReservaRemoteDataSource(this.dio);

	Future<List<Map<String, dynamic>>> fetchReservasPorAula(int aulaId) async {
		final path = '/reserva-service/reservas/aula/$aulaId/agregadas';
		final response = await dio.get(path);
		final data = response.data;
		final list = (data['reservas'] as List?) ?? (data['data'] as List?) ?? [];
		return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
	}
}

