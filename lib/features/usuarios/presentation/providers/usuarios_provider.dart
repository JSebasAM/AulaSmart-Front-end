import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/usuario_entity.dart';
import '../../data/repositories/usuario_repository_impl.dart';
import '../../../../services/dio_client.dart';

part 'usuarios_provider.g.dart';

@riverpod
UsuarioRepositoryImpl usuarioRepository(Ref ref) {
  final dioGlobal = ref.watch(dioProvider);
  final dio = Dio(dioGlobal.options.copyWith(
    baseUrl: ApiUrls.usuarios,
  ));
  dio.interceptors.addAll(dioGlobal.interceptors);
  return UsuarioRepositoryImpl(dio: dio);
}

@riverpod
class Usuarios extends _$Usuarios {
  @override
  FutureOr<List<UsuarioEntity>> build() async {
    return _fetchUsuarios();
  }

  Future<List<UsuarioEntity>> _fetchUsuarios() async {
    return ref.read(usuarioRepositoryProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchUsuarios());
  }

  Future<void> create(Map<String, dynamic> body) async {
    await ref.read(usuarioRepositoryProvider).create(body);
    await refresh();
  }

  Future<void> editar(String id, Map<String, dynamic> body) async {
    await ref.read(usuarioRepositoryProvider).update(id, body);
    await refresh();
  }

  Future<void> remove(String id) async {
    await ref.read(usuarioRepositoryProvider).delete(id);
    await refresh();
  }

  Future<void> cambiarPassword(String id, String newPassword) async {
    await ref.read(usuarioRepositoryProvider).changePassword(id, newPassword);
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

@riverpod
class UsuarioFiltroRol extends _$UsuarioFiltroRol {
  @override
  String build() => 'Todos';

  void setRol(String rol) {
    state = rol;
  }
}

@riverpod
class UsuariosPaginados extends _$UsuariosPaginados {
  @override
  int build() => 20;

  void cargarMas() {
    state += 20;
  }

  void reiniciar() {
    state = 20;
  }
}

@riverpod
List<UsuarioEntity> usuariosFiltrados(Ref ref) {
  final usuariosAsync = ref.watch(usuariosProvider);
  final todos = usuariosAsync.value ?? [];
  final rol = ref.watch(usuarioFiltroRolProvider);
  final search = ref.watch(searchQueryProvider);

  return todos.where((u) {
    if (rol != 'Todos' && u.rol != rol) return false;
      if (search.isNotEmpty) {
        final q = search.toLowerCase();
        if (!u.nombre.toLowerCase().contains(q) &&
            !u.email.toLowerCase().contains(q)) {
          return false;
        }
    }
    return true;
  }).toList();
}
