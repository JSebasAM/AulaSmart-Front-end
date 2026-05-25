import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/aula_entity.dart';
import '../../domain/entities/tipo_aula_entity.dart';
import '../../domain/entities/bloque_entity.dart';
import '../../data/repositories/aula_repository_impl.dart';
import '../../../../services/dio_client.dart';

part 'aulas_provider.g.dart';

@riverpod
AulaRepositoryImpl aulaRepository(Ref ref) {
  final dioGlobal = ref.watch(dioProvider);
  final dioAulas = Dio(dioGlobal.options.copyWith(
    baseUrl: ApiUrls.aulas,
  ));
  dioAulas.interceptors.addAll(dioGlobal.interceptors);
  return AulaRepositoryImpl(dio: dioAulas);
}

@riverpod
class Aulas extends _$Aulas {
  @override
  FutureOr<List<AulaEntity>> build() async {
    return _fetchAulas();
  }

  Future<List<AulaEntity>> _fetchAulas() async {
    return ref.read(aulaRepositoryProvider).getAulas();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAulas());
  }

  Future<void> create(Map<String, dynamic> payload) async {
    await ref.read(aulaRepositoryProvider).create(payload);
    await refresh();
  }

  Future<void> editar(Map<String, dynamic> payload) async {
    await ref.read(aulaRepositoryProvider).update(payload);
    await refresh();
  }

  Future<void> delete(int id) async {
    await ref.read(aulaRepositoryProvider).delete(id);
    await refresh();
  }
}

final tiposAulaProvider = FutureProvider<List<TipoAulaEntity>>((ref) async {
  return ref.read(aulaRepositoryProvider).getTiposAula();
});

final bloquesProvider = FutureProvider<List<BloqueEntity>>((ref) async {
  return ref.read(aulaRepositoryProvider).getBloques();
});

@riverpod
class CategoriaFiltro extends _$CategoriaFiltro {
  @override
  String build() => 'Todas';

  void setCategoria(String categoria) {
    state = categoria;
  }
}

final searchQueryProvider = StateProvider<String>((ref) => '');

final bloqueFiltroProvider = StateProvider<String>((ref) => 'Todos');

@riverpod
List<AulaEntity> aulasFiltradas(Ref ref) {
  final aulasAsync = ref.watch(aulasProvider);
  final categoria = ref.watch(categoriaFiltroProvider);
  final bloque = ref.watch(bloqueFiltroProvider);
  final search = ref.watch(searchQueryProvider);

  final todasLasAulas = aulasAsync.value ?? [];

  return todasLasAulas.where((aula) {
    final matchesCategoria = categoria == 'Todas' ||
        aula.tipoAula.nombre.toLowerCase() == categoria.toLowerCase();
    final matchesBloque = bloque == 'Todos' ||
        aula.bloque.nombre.toLowerCase() == bloque.toLowerCase();
    final matchesSearch = search.isEmpty ||
        aula.nombreAula.toLowerCase().contains(search.toLowerCase());
    return matchesCategoria && matchesBloque && matchesSearch;
  }).toList();
}

final visibleAulasCountProvider = StateProvider<int>((ref) => 20);

final aulasVisiblesProvider = Provider<List<AulaEntity>>((ref) {
  final todas = ref.watch(aulasFiltradasProvider);
  final count = ref.watch(visibleAulasCountProvider);
  if (count >= todas.length) return todas;
  return todas.take(count).toList();
});
