import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../base_service.dart';
import '../../models/usuario.dart';
import '../dio_client.dart';

class UsuarioService extends BaseService {
  UsuarioService(Dio dio) : super(dio);

  // Métodos específicos para el recurso de usuarios
  Future<List<User>> getAll() async {
    return await get<List<User>>(
      '${ApiUrls.usuarios}/usuario-service/usuarios',
      parser: (data) {
        if (kDebugMode) {
          print('USUARIO_SERVICE_DATA: $data');
        }
        List<dynamic> list = [];
        if (data is List) {
          list = data;
        } else if (data is Map) {
          // Intentar extraer la lista de campos comunes
          list = data['data'] ?? data['usuarios'] ?? data['content'] ?? [];
        }

        return list
            .map((e) => User.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  Future<User> getById(String id) async {
    return await get<User>(
      '${ApiUrls.usuarios}/usuario-service/usuarios/$id',
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> create(Map<String, dynamic> payload) async {
    return await post<User>(
      '${ApiUrls.usuarios}/usuario-service/usuarios',
      data: payload,
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> update(String id, Map<String, dynamic> payload) async {
    return await put<User>(
      '${ApiUrls.usuarios}/usuario-service/usuarios/$id',
      data: payload,
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> remove(String id) async {
    await delete('${ApiUrls.usuarios}/usuario-service/usuarios/$id');
  }
}

  final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  return UsuarioService(ref.watch(dioProvider));

});