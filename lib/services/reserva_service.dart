import 'dart:convert';

import 'package:aulasmart_front_end/models/reserva.dart';
import 'package:http/http.dart' as http;

class ReservaService {
  ReservaService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

  final http.Client _client;
  final String _baseUrl;

  Future<List<Reserva>> listarReservas() async {
    final uri = Uri.parse('$_baseUrl/reservas');

    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _mockReservas;
      }

      final dynamic body = jsonDecode(response.body);
      final List<dynamic> listaRaw;
      if (body is List<dynamic>) {
        listaRaw = body;
      } else if (body is Map<String, dynamic> && body['data'] is List<dynamic>) {
        listaRaw = body['data'] as List<dynamic>;
      } else {
        listaRaw = const <dynamic>[];
      }

      final reservas = listaRaw
          .whereType<Map<String, dynamic>>()
          .map(Reserva.fromJson)
          .where((reserva) => reserva.titulo.isNotEmpty)
          .toList();

      if (reservas.isEmpty) {
        return _mockReservas;
      }

      return reservas;
    } catch (_) {
      return _mockReservas;
    }
  }

  static const List<Reserva> _mockReservas = <Reserva>[
    Reserva(
      id: 'r-01',
      titulo: 'Clase de Fisica 101',
      estado: 'Confirmado',
      aula: 'Aula Magna A-101',
      fecha: 'martes, 31 de marzo de 2025',
      horario: '09:00 - 11:00',
      asistentes: 85,
      descripcion: 'Clase magistral sobre fundamentos de Mecanica Cuantica',
    ),
    Reserva(
      id: 'r-02',
      titulo: 'Presentacion de Proyecto de Ingenieria',
      estado: 'Confirmado',
      aula: 'Sala de Conferencias B-301 Edificio Administrativo',
      fecha: 'jueves, 2 de abril de 2025',
      horario: '14:00 - 16:00',
      asistentes: 45,
      descripcion: 'Presentaciones de proyectos de ultimo ano de estudiantes de Ingenieria',
    ),
    Reserva(
      id: 'r-03',
      titulo: 'Sesion de Laboratorio de Quimica',
      estado: 'Pendiente',
      aula: 'Laboratorio B-205 - Edificio de Ciencias',
      fecha: 'sabado, 4 de abril de 2025',
      horario: '10:00 - 12:00',
      asistentes: 30,
      descripcion: 'Trabajo practico de laboratorio sobre experimentos de quimica organica',
    ),
  ];
}
