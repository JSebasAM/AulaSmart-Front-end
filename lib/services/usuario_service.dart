import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_service.dart';
import '../models/usuario.dart';
import 'dio_client.dart';

class UsuarioService extends BaseService {
  UsuarioService(Dio dio) : super(dio, ApiUrls.usuarios);

  // Métodos específicos para el recurso de usuarios
  Future<List<User>> getAll() async {
    return await get<List<User>>(
      '${ApiUrls.usuarios}/usuarios',
      parser: (data) {
        if (data is List) {
          return data.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
        }
        return <User>[];
      },
    );
  }

  Future<User> getById(int id) async {
    return await get<User>(
      '${ApiUrls.usuarios}/usuarios/$id',
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> create(Map<String, dynamic> payload) async {
    return await post<User>(
      '${ApiUrls.usuarios}/usuarios',
      data: payload,
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<User> update(int id, Map<String, dynamic> payload) async {
    return await put<User>(
      '${ApiUrls.usuarios}/usuarios/$id',
      data: payload,
      parser: (data) => User.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<void> remove(int id) async {
    await delete('${ApiUrls.usuarios}/usuarios/$id');
  }
}

  final usuarioServiceProvider = Provider<UsuarioService>((ref) {
  return UsuarioService(ref.watch(dioProvider));

});