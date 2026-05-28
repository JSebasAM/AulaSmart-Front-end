import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_styles.dart';
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
      backgroundColor: AppColors.background,
      body: aulasAsync.when(
        data: (aulas) {
          if (aulas.isEmpty) {
            return _buildEmptyState();
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
                SliverAppBar(
                  toolbarHeight: 100,
                  floating: false,
                  pinned: false,
                  backgroundColor: Colors.transparent,
                  forceMaterialTransparency: true,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 24, top: 8),
                    child: DefaultTextStyle(
                      style: const TextStyle(),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShaderMask(
                            shaderCallback: (bounds) =>
                                AppColors.primaryGradient.createShader(bounds),
                            child: Text(
                              'Aula Smart',
                              style: AppTextStyles.pageTitle.copyWith(
                                color: Colors.white,
                                letterSpacing: -0.02,
                              ),
                            ),
                          ),
                          AppGaps.hSm,
                          Container(
                            width: 24,
                            height: 2,
                            decoration: BoxDecoration(
                              color: AppColors.textSecondary,
                              borderRadius: AppShapes.circular20,
                            ),
                          ),
                          AppGaps.hXs,
                          Text(
                            'Categorías',
                            style: AppTextStyles.pageSubtitle.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: _buildSearchBar(ref),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _buildChipRow(
                      items: categorias,
                      selected: categoriaSeleccionada,
                      onSelected: (cat) {
                        ref.read(categoriaFiltroProvider.notifier).setCategoria(cat);
                        ref.read(visibleAulasCountProvider.notifier).state = 20;
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _buildChipRow(
                      items: bloques,
                      selected: bloqueSeleccionada,
                      onSelected: (b) {
                        ref.read(bloqueFiltroProvider.notifier).state = b;
                        ref.read(visibleAulasCountProvider.notifier).state = 20;
                      },
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Aulas Disponibles',
                          style: AppTextStyles.sectionTitle,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: AppDecorations.badge(),
                          child: Text(
                            '${aulasVisibles.length} de ${aulasFiltradas.length} aulas',
                            style: AppTextStyles.smallLabel,
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
                              style: AppTextStyles.sectionBody.copyWith(
                                    color: AppColors.neutral,
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
        error: (error, stack) => _buildErrorState(ref, error),
      ),
    );
  }

  Widget _buildSearchBar(WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: AppShapes.circular20,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        onChanged: (v) {
          ref.read(searchQueryProvider.notifier).state = v;
          ref.read(visibleAulasCountProvider.notifier).state = 20;
        },
        decoration: InputDecoration(
          hintText: 'Buscar aula...',
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintStyle: AppTextStyles.sectionBody.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildChipRow({
    required List<String> items,
    required String selected,
    required void Function(String) onSelected,
  }) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => AppGaps.wSm,
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;

          return GestureDetector(
            onTap: () => onSelected(item),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppColors.primaryGradient : null,
                color: isSelected ? null : AppColors.surface,
                borderRadius: AppShapes.circular20,
                border: isSelected
                    ? Border.all(width: 0, color: Colors.transparent)
                    : Border.all(color: AppColors.border),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  item,
                  style: AppTextStyles.sectionBody.copyWith(
                    color: isSelected
                        ? AppColors.textOnPrimary
                        : AppColors.textSecondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room_outlined,
              size: 64, color: AppColors.neutral),
          AppGaps.hLg,
          Text(
            'No hay aulas disponibles.',
            style: AppTextStyles.sectionBody,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(WidgetRef ref, Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined,
                size: 64, color: AppColors.danger),
            AppGaps.hLg,
            Text(
              'No pudimos cargar las aulas',
              style: AppTextStyles.sectionTitle,
              textAlign: TextAlign.center,
            ),
            AppGaps.hSm,
            Text(
              error.toString(),
              style: AppTextStyles.sectionBody,
              textAlign: TextAlign.center,
            ),
            AppGaps.hXxl,
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
