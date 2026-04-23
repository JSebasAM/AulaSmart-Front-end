import 'dart:convert';

import 'package:aulasmart_front_end/models/profile_data.dart';
import 'package:http/http.dart' as http;

class ProfileService {
  ProfileService({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');

  final http.Client _client;
  final String _baseUrl;

  Future<ProfileData> obtenerPerfil() async {
    final uri = Uri.parse('$_baseUrl/perfil');

    try {
      final response = await _client.get(uri);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        return _mockPerfil;
      }

      final dynamic body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final data = body['data'];
        if (data is Map<String, dynamic>) {
          return ProfileData.fromJson(data);
        }
        return ProfileData.fromJson(body);
      }

      return _mockPerfil;
    } catch (_) {
      return _mockPerfil;
    }
  }

  static const ProfileData _mockPerfil = ProfileData(
    id: 'u-01',
    nombre: 'Juan Perez',
    rol: 'Docente',
    avatarUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=240',
    aulas: 12,
    aulasReservadas: 8,
    incidencias: 3,
  );
}
