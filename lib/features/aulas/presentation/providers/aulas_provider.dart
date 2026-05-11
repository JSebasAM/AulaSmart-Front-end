import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/entities/aula_entity.dart';
import '../../data/repositories/aula_repository_impl.dart';
import '../../../../services/dio_client.dart'; // Importante: Traer tu cliente JWT

part 'aulas_provider.g.dart';

@riverpod
AulaRepositoryImpl aulaRepository(Ref ref) {
  // Ahora inyectamos tu Dio global que YA tiene los interceptores de JWT
  final dioGlobal = ref.watch(dioProvider);
  
  // Clonamos el Dio para setearle la baseUrl específica de Aulas sin dañar el original
  final dioAulas = Dio(dioGlobal.options.copyWith(
    baseUrl: ApiUrls.aulas,
  ));
  // Le copiamos los interceptores (el JWT y el Refresh Token)
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
    final repository = ref.watch(aulaRepositoryProvider);
    return await repository.getAulas();
  }

  // Método opcional para refrescar la lista manualmente
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchAulas());
  }
}

@riverpod
class CategoriaFiltro extends _$CategoriaFiltro {
  @override
  String build() => 'Todas';

  void setCategoria(String categoria) {
    state = categoria;
  }
}
