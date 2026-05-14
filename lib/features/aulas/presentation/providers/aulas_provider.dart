import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
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

// Estado local para la query de búsqueda (no requiere codegen)
final searchQueryProvider = StateProvider<String>((ref) => '');

// Filtro por bloque (nombre).
final bloqueFiltroProvider = StateProvider<String>((ref) => 'Todos');

@riverpod
List<AulaEntity> aulasFiltradas(Ref ref) {
  // 1. Escuchamos la lista original de aulas
  final aulasAsync = ref.watch(aulasProvider);
  
  // 2. Escuchamos los criterios de filtrado
  final categoria = ref.watch(categoriaFiltroProvider);
  final bloque = ref.watch(bloqueFiltroProvider);
  final search = ref.watch(searchQueryProvider);

  // Si aún están cargando o hubo error, devolvemos lista vacía
  final todasLasAulas = aulasAsync.value ?? [];

  // 3. Aplicamos la lógica de filtrado
  return todasLasAulas.where((aula) {
    // Filtro por Tipo de Aula
    final matchesCategoria = categoria == 'Todas' || 
                             aula.tipoAula.nombre.toLowerCase() == categoria.toLowerCase();
    
    // Filtro por Bloque
    final matchesBloque = bloque == 'Todos' || 
                          aula.bloque.nombre.toLowerCase() == bloque.toLowerCase();
    
    // Filtro por texto de búsqueda
    final matchesSearch = search.isEmpty || 
                          aula.nombreAula.toLowerCase().contains(search.toLowerCase());

    // El aula debe cumplir los TRES filtros
    return matchesCategoria && matchesBloque && matchesSearch;
  }).toList();
}

// Paginacion client-side: carga progresiva de 20 en 20
final visibleAulasCountProvider = StateProvider<int>((ref) => 20);

final aulasVisiblesProvider = Provider<List<AulaEntity>>((ref) {
  final todas = ref.watch(aulasFiltradasProvider);
  final count = ref.watch(visibleAulasCountProvider);
  if (count >= todas.length) return todas;
  return todas.take(count).toList();
});

