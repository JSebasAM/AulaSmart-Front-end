import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import '../providers/aulas_provider.dart';
import '../widgets/aula_card_widget.dart';
import 'aula_form_screen.dart';
import 'aula_admin_detail_screen.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_styles.dart';

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
        title: Text('Eliminar aula', style: AppTextStyles.sectionTitle),
        content: Text('¿Estás seguro de eliminar "${aula.nombreAula}"?', style: AppTextStyles.sectionBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            'Gestión de Aulas',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22, color: Colors.white),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
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
              decoration: AppInputStyles.search().copyWith(
                hintStyle: TextStyle(color: AppColors.textSecondary),
                prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              ),
            ),
          ),
          Expanded(
            child: aulasAsync.when(
              data: (aulas) {
                if (aulas.isEmpty) {
                  return _buildEmptyState();
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
                        AppGaps.hSm,
                        _buildFilterBar(categorias, categoriaSeleccionada),
                        AppGaps.hSm,
                        _buildBloqueBar(bloques, bloqueSeleccionado),
                        AppGaps.hLg,
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'No se encontraron aulas con ese criterio',
                              style: AppTextStyles.sectionBody,
                              textAlign: TextAlign.center,
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
                    separatorBuilder: (_, _) => AppGaps.hXs,
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
                                ref.read(visibleAulasCountProvider.notifier).state = total + 20;
                              },
                              icon: const Icon(Icons.expand_more),
                              label: Text('Cargar más', style: AppTextStyles.sectionBody.copyWith(color: AppColors.primary)),
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
                                  SnackBar(content: Text('"${aula.nombreAula}" eliminada'), backgroundColor: AppColors.success),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
                                );
                              }
                            }
                          }
                        },
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => AulaAdminDetailScreen(aula: aula)),
                          );
                        },
                      );
                    },
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.wifi_off_outlined, size: 64, color: AppColors.danger),
                      AppGaps.hLg,
                      Text('Error al cargar aulas', style: AppTextStyles.sectionTitle),
                      AppGaps.hSm,
                      Text(error.toString(), style: AppTextStyles.sectionBody, textAlign: TextAlign.center),
                      AppGaps.hXxl,
                      FilledButton.tonalIcon(
                        onPressed: () => ref.read(aulasProvider.notifier).refresh(),
                        icon: const Icon(Icons.refresh),
                        label: Text('Reintentar', style: AppTextStyles.sectionBody),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined, size: 64, color: AppColors.neutral),
          AppGaps.hLg,
          Text('No hay aulas registradas', style: AppTextStyles.sectionBody),
        ],
      ),
    );
  }

  Widget _buildFilterBar(List<String> categorias, String seleccionActual) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categorias.length,
        separatorBuilder: (_, _) => AppGaps.wMd,
        itemBuilder: (_, index) {
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
            labelStyle: AppChipStyles.label(selected: isSelected),
            backgroundColor: AppColors.surfaceVariant,
            selectedColor: AppColors.primary,
            shape: AppShapes.chipShape,
            side: BorderSide.none,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          );
        },
      ),
    );
  }

  Widget _buildBloqueBar(List<String> bloques, String seleccionActual) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: bloques.length,
        separatorBuilder: (_, _) => AppGaps.wMd,
        itemBuilder: (_, index) {
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
            labelStyle: AppChipStyles.label(selected: isSelected),
            backgroundColor: AppColors.surfaceVariant,
            selectedColor: AppColors.primary,
            shape: AppShapes.chipShape,
            side: BorderSide.none,
            showCheckmark: false,
            padding: const EdgeInsets.symmetric(horizontal: 16),
          );
        },
      ),
    );
  }
}
