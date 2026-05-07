import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario.dart';
import 'usuario_service.dart';

class UsuarioNotifier extends AsyncNotifier<List<User>> {
  @override
  Future<List<User>> build() async {
    // Escuchamos el servicio y obtenemos todos los usuarios
    return ref.watch(usuarioServiceProvider).getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => ref.read(usuarioServiceProvider).getAll());
  }

  Future<void> create(Map<String, dynamic> body) async {
    await ref.read(usuarioServiceProvider).create(body);
    await refresh();
  }

  Future<void> editar(String id, Map<String, dynamic> body) async {
    await ref.read(usuarioServiceProvider).update(id, body);
    await refresh();
  }

  Future<void> remove(String id) async {
    await ref.read(usuarioServiceProvider).remove(id);
    await refresh();
  }
}

final usuarioProvider =
    AsyncNotifierProvider<UsuarioNotifier, List<User>>(
  UsuarioNotifier.new,
);