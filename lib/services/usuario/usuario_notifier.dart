import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario.dart';
import 'usuario_service.dart';

class UsuarioNotifier extends AsyncNotifier<List<User>> {
  late final UsuarioService _service;

  @override
  Future<List<User>> build() async {
    _service = ref.watch(usuarioServiceProvider);
    return _service.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _service.getAll());
  }

  Future<void> create(Map<String, dynamic> body) async {
    await _service.create(body);
    await refresh();
  }

  Future<void> editar(int id, Map<String, dynamic> body) async {
    await _service.update(id, body);
    await refresh();
  }

  Future<void> remove(int id) async {
    await _service.remove(id);
    await refresh();
  }
}

final usuarioProvider =
    AsyncNotifierProvider<UsuarioNotifier, List<User>>(
  UsuarioNotifier.new,
);