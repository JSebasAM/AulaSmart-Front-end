import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/aulas_provider.dart';
import '../widgets/aula_card_widget.dart';

class AulasScreen extends ConsumerWidget {
  const AulasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aulasAsync = ref.watch(aulasProvider);
    final categoriaSeleccionada = ref.watch(categoriaFiltroProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Aulas Smart', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: aulasAsync.when(
        data: (aulas) {
          if (aulas.isEmpty) {
            return _buildEmptyState(context);
          }

          // Extraer categorías únicas para los filtros dinámicos
          final categorias = ['Todas'];
          categorias.addAll(aulas.map((a) => a.tipoAula.nombre).toSet().toList());

          // Filtrar aulas según selección
          final aulasFiltradas = categoriaSeleccionada == 'Todas'
              ? aulas
              : aulas.where((a) => a.tipoAula.nombre == categoriaSeleccionada).toList();

          return RefreshIndicator(
            onRefresh: () => ref.read(aulasProvider.notifier).refresh(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Barra de filtros horizontal
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
                    child: _buildFilterBar(context, ref, categorias, categoriaSeleccionada),
                  ),
                ),
                
                // Lista de Aulas o Estado Vacío de Filtro
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: aulasFiltradas.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No hay aulas en esta categoría',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Theme.of(context).colorScheme.outline,
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return AulaCardWidget(aula: aulasFiltradas[index]);
                            },
                            childCount: aulasFiltradas.length,
                          ),
                        ),
                ),
                // Espacio al final de la lista
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(context, ref, error),
      ),
    );
  }

  Widget _buildFilterBar(BuildContext context, WidgetRef ref, List<String> categorias, String seleccionActual) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final isSelected = cat == seleccionActual;
          final colorScheme = Theme.of(context).colorScheme;

          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(categoriaFiltroProvider.notifier).setCategoria(cat);
              }
            },
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.5),
            selectedColor: colorScheme.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined, size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No hay aulas disponibles.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar las aulas',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () => ref.read(aulasProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
