import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/aulas_provider.dart';
import '../widgets/aula_card_widget.dart';

class AulasScreen extends ConsumerStatefulWidget {
  const AulasScreen({super.key});

  @override
  ConsumerState<AulasScreen> createState() => _AulasScreenState();
}

class _AulasScreenState extends ConsumerState<AulasScreen> {
  @override
  Widget build(BuildContext context) {
    final aulasAsync = ref.watch(aulasProvider);
    final categoriaSeleccionada = ref.watch(categoriaFiltroProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Aulas Smart',
            style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: aulasAsync.when(
        data: (aulas) {
          if (aulas.isEmpty) {
            return _buildEmptyState(context);
          }

          final categorias = ['Todas'];
          categorias
              .addAll(aulas.map((a) => a.tipoAula.nombre).toSet().toList());
          final bloques = ['Todos'];
          bloques.addAll(aulas.map((a) => a.bloque.nombre).toSet().toList());
          final bloqueSeleccionada = ref.watch(bloqueFiltroProvider);

          final aulasFiltradas = ref.watch(aulasFiltradasProvider);
          final aulasVisibles = ref.watch(aulasVisiblesProvider);

          return RefreshIndicator(
            onRefresh: () async {
              ref.read(visibleAulasCountProvider.notifier).state = 20;
              await ref.read(aulasProvider.notifier).refresh();
            },
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Text(
                      'Categorias',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: TextField(
                      onChanged: (v) {
                        ref.read(searchQueryProvider.notifier).state = v;
                        ref.read(visibleAulasCountProvider.notifier).state = 20;
                      },
                      decoration: InputDecoration(
                        hintText: 'Buscar aula...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildFilterBar(context, ref, categorias,
                        categoriaSeleccionada),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildBloqueBar(
                        context, ref, bloques, bloqueSeleccionada),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aulas Disponibles',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${aulasVisibles.length} de ${aulasFiltradas.length} aulas',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: aulasFiltradas.isEmpty
                      ? SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(
                              'No hay aulas en esta categoria',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.outline,
                                  ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              if (index >= aulasVisibles.length) return null;
                              return AulaCardWidget(
                                  aula: aulasVisibles[index]);
                            },
                            childCount: aulasVisibles.length +
                                (aulasVisibles.length < aulasFiltradas.length
                                    ? 1
                                    : 0),
                          ),
                        ),
                ),
                if (aulasVisibles.length < aulasFiltradas.length)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: TextButton.icon(
                          onPressed: () {
                            final total = ref.read(visibleAulasCountProvider);
                            ref.read(visibleAulasCountProvider.notifier).state =
                                total + 20;
                          },
                          icon: const Icon(Icons.expand_more),
                          label: const Text('Cargar más'),
                        ),
                      ),
                    ),
                  ),
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

  Widget _buildFilterBar(BuildContext context, WidgetRef ref,
      List<String> categorias, String seleccionActual) {
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
                ref.read(visibleAulasCountProvider.notifier).state = 20;
              }
            },
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            backgroundColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            selectedColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            side: BorderSide.none,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          );
        },
      ),
    );
  }

  Widget _buildBloqueBar(BuildContext context, WidgetRef ref,
      List<String> bloques, String seleccionActual) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: bloques.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final b = bloques[index];
          final isSelected = b == seleccionActual;
          final colorScheme = Theme.of(context).colorScheme;

          return ChoiceChip(
            label: Text(b),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(bloqueFiltroProvider.notifier).state = b;
                ref.read(visibleAulasCountProvider.notifier).state = 20;
              }
            },
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant,
            ),
            backgroundColor:
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            selectedColor: colorScheme.primary,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
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
          Icon(Icons.meeting_room_outlined,
              size: 64, color: Theme.of(context).colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No hay aulas disponibles.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      BuildContext context, WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 64, color: Theme.of(context).colorScheme.error),
            const SizedBox(height: 16),
            Text(
              'No pudimos cargar las aulas',
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.tonalIcon(
              onPressed: () {
                ref.read(visibleAulasCountProvider.notifier).state = 20;
                ref.read(aulasProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
