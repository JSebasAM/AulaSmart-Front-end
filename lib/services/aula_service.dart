import 'dart:async';
import 'dart:convert';

import 'package:aulasmart_front_end/models/aula.dart';
import 'package:http/http.dart' as http;

class AulaService {
  AulaService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

  final http.Client _client;
  final String _baseUrl;

  Future<List<Aula>> listarAulas() async {
    final uri = Uri.parse('$_baseUrl/aulas');

    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _mockAulas;
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

      final aulas = listaRaw
          .whereType<Map<String, dynamic>>()
          .map(Aula.fromJson)
          .where((aula) => aula.nombre.isNotEmpty)
          .toList();

      if (aulas.isEmpty) {
        return _mockAulas;
      }

      return aulas;
    } catch (_) {
      return _mockAulas;
    }
  }

  static const List<Aula> _mockAulas = <Aula>[
    Aula(
      id: '1',
      nombre: 'Aula Magna A-101',
      edificio: 'Edificio de Ingeniería',
      piso: 1,
      categoria: 'Aulas',
      capacidad: 120,
      estado: 'Libre',
      imagenUrl: 'https://images.unsplash.com/photo-1524995997946-a1c2e315a42f?w=600',
      tieneVideo: true,
      tieneWifi: true,
    ),
    Aula(
      id: '2',
      nombre: 'Laboratorio B-205',
      edificio: 'Edificio de Ciencias',
      piso: 2,
      categoria: 'Laboratorios',
      capacidad: 40,
      estado: 'Ocupada',
      imagenUrl: 'https://images.unsplash.com/photo-1582719478250-c89cae4dc85b?w=600',
      tieneVideo: true,
      tieneWifi: true,
    ),
    Aula(
      id: '3',
      nombre: 'Sala de Conferencias C-301',
      edificio: 'Edificio Administrativo',
      piso: 3,
      categoria: 'Salas',
      capacidad: 60,
      estado: 'Libre',
      imagenUrl: 'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?w=600',
      tieneVideo: true,
      tieneWifi: true,
    ),
    Aula(
      id: '4',
      nombre: 'Aula D-102',
      edificio: 'Edificio de Humanidades',
      piso: 1,
      categoria: 'Aulas',
      capacidad: 60,
      estado: 'Libre',
      imagenUrl: 'https://images.unsplash.com/photo-1523050854058-8df90110c9f1?w=600',
      tieneVideo: true,
      tieneWifi: true,
    ),
    Aula(
      id: '5',
      nombre: 'Auditorio Principal',
      edificio: 'Edificio Central',
      piso: 1,
      categoria: 'Auditorios',
      capacidad: 250,
      estado: 'Libre',
      imagenUrl: 'https://images.unsplash.com/photo-1475721027785-f74eccf877e2?w=600',
      tieneVideo: true,
      tieneWifi: true,
    ),
  ];
}
