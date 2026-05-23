import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import '../providers/aulas_provider.dart';
import '../widgets/aula_card_widget.dart';
import 'aula_form_screen.dart';
import 'aula_admin_detail_screen.dart';

class AulasAdminScreen extends ConsumerStatefulWidget {
  const AulasAdminScreen({super.key});

  @override
  ConsumerState<AulasAdminScreen> createState() => _AulasAdminScreenState();
}

class _AulasAdminScreenState extends ConsumerState<AulasAdminScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    ref.read(visibleAulasCountProvider.notifier).state = 20;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _resetPaginacion() {
    ref.read(visibleAulasCountProvider.notifier).state = 20;
  }

  void _showFormDialog({AulaEntity? aula}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AulaFormScreen(
          aula: aula,
          onSaved: () {
            ref.read(aulasProvider.notifier).refresh();
          },
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(AulaEntity aula) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar aula'),
        content: Text('¿Estás seguro de eliminar "${aula.nombreAula}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final aulasAsync = ref.watch(aulasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Aulas'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                ref.read(searchQueryProvider.notifier).state = v;
              },
              decoration: InputDecoration(
                hintText: 'Buscar aula...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: aulasAsync.when(
              data: (aulas) {
                if (aulas.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.meeting_room_outlined,
                            size: 64, color: Theme.of(context).colorScheme.outline),
                        const SizedBox(height: 16),
                        const Text('No hay aulas registradas'),
                      ],
                    ),
                  );
                }

                final filtradas = ref.watch(aulasFiltradasProvider);
                final visibles = ref.watch(aulasVisiblesProvider);
                final hayMas = visibles.length < filtradas.length;

                final categorias = ['Todas'];
                categorias.addAll(aulas.map((a) => a.tipoAula.nombre).toSet().toList());
                final bloques = ['Todos'];
                bloques.addAll(aulas.map((a) => a.bloque.nombre).toSet().toList());
                final categoriaSeleccionada = ref.watch(categoriaFiltroProvider);
                final bloqueSeleccionado = ref.watch(bloqueFiltroProvider);

                if (filtradas.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: () => ref.read(aulasProvider.notifier).refresh(),
                    child: ListView(
                      children: [
                        const SizedBox(height: 8),
                        _buildFilterBar(categorias, categoriaSeleccionada),
                        const SizedBox(height: 8),
                        _buildBloqueBar(bloques, bloqueSeleccionado),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Center(
                            child: Text(
                              'No se encontraron aulas con ese criterio',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => ref.read(aulasProvider.notifier).refresh(),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                    itemCount: visibles.length + 2 + (hayMas ? 1 : 0),
                    separatorBuilder: (_, _) => const SizedBox(height: 4),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: _buildFilterBar(categorias, categoriaSeleccionada),
                        );
                      }
                      if (i == 1) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildBloqueBar(bloques, bloqueSeleccionado),
                        );
                      }
                      final itemIndex = i - 2;
                      if (itemIndex >= visibles.length) {
                        return Padding(
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
                        );
                      }
                      final aula = visibles[itemIndex];
                      return AulaCardWidget(
                        aula: aula,
                        onEdit: () => _showFormDialog(aula: aula),
                        onDelete: () async {
                          final confirm = await _confirmDelete(aula);
                          if (confirm) {
                            try {
                              await ref.read(aulasProvider.notifier).delete(aula.id);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('"${aula.nombreAula}" eliminada'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.redAccent,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AulaAdminDetailScreen(aula: aula),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.wifi_off_outlined,
                        size: 64, color: Theme.of(context).colorScheme.error),
                    const SizedBox(height: 16),
                    Text('Error al cargar aulas', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 8),
                    Text(error.toString(), textAlign: TextAlign.center),
                    const SizedBox(height: 24),
                    FilledButton.tonalIcon(
                      onPressed: () => ref.read(aulasProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reintentar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<String> categorias, String seleccionActual) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = categorias[index];
          final isSelected = cat == seleccionActual;
          return ChoiceChip(
            label: Text(cat),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(categoriaFiltroProvider.notifier).setCategoria(cat);
                _resetPaginacion();
              }
            },
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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

  Widget _buildBloqueBar(List<String> bloques, String seleccionActual) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: bloques.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final b = bloques[index];
          final isSelected = b == seleccionActual;
          return ChoiceChip(
            label: Text(b),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(bloqueFiltroProvider.notifier).state = b;
                _resetPaginacion();
              }
            },
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              color: isSelected ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
            ),
            backgroundColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
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
}
