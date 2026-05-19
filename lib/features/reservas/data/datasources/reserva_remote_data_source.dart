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

	Future<List<Map<String, dynamic>>> fetchMisReservas() async {
		final path = '/reserva-service/reservas/mis-reservas';
		final response = await dio.get(path);
		final data = response.data;
		final list = (data['reservas'] as List?) ?? (data['data'] as List?) ?? [];
		return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
	}

	Future<List<Map<String, dynamic>>> fetchReservasPendientes() async {
		final path = '/reserva-service/reservas/pendientes';
		final response = await dio.get(path);
		final data = response.data;
		final list = (data['reservas'] as List?) ?? (data['data'] as List?) ?? [];
		return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
	}

	Future<Map<String, dynamic>> createReserva(Map<String, dynamic> body) async {
		final path = '/reserva-service/reservas';
		final response = await dio.post(path, data: body);
		final data = response.data;
		return Map<String, dynamic>.from(
			(data['reserva'] as Map?) ?? (data['data'] as Map?) ?? data as Map,
		);
	}

	Future<Map<String, dynamic>> confirmarReserva(String id) async {
		final path = '/reserva-service/reservas/$id/confirmar';
		final response = await dio.put(path);
		final data = response.data;
		return Map<String, dynamic>.from(
			(data['reserva'] as Map?) ?? (data['data'] as Map?) ?? data as Map,
		);
	}

	Future<Map<String, dynamic>> rechazarReserva(String id) async {
		final path = '/reserva-service/reservas/$id/rechazar';
		final response = await dio.put(path);
		final data = response.data;
		return Map<String, dynamic>.from(
			(data['reserva'] as Map?) ?? (data['data'] as Map?) ?? data as Map,
		);
	}
}

