import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/core/themes/app_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/usuario_entity.dart';
import '../providers/usuarios_provider.dart';
import '../widgets/user_card_widget.dart';
import 'usuarios_form_screen.dart';

class AdminUsersView extends ConsumerStatefulWidget {
  final String? roleFilter;
  const AdminUsersView({super.key, this.roleFilter});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView> {
  final TextEditingController _searchController = TextEditingController();

  static const _roles = ['Todos', 'Estudiante', 'Docente', 'Administrativo', 'Administrador', 'Monitor'];

  @override
  void initState() {
    super.initState();
    if (widget.roleFilter != null) {
      Future.microtask(() {
        ref.read(usuarioFiltroRolProvider.notifier).setRol(widget.roleFilter!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFormDialog(BuildContext context, {UsuarioEntity? user}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppShapes.circular24,
          ),
          child: AdminUserFormView(
            user: user,
            fixedRole: widget.roleFilter,
            onSaved: () => Navigator.pop(context),
          ),
        ),
      ),
    );
  }

  void _confirmDelete(UsuarioEntity user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppShapes.circular16),
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${user.nombre} ${user.apellido}?\nEsta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await ref.read(usuariosProvider.notifier).remove(user.codigo);
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppShapes.circular8),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuariosProvider);
    final filtrados = ref.watch(usuariosFiltradosProvider);
    final rolSeleccionado = ref.watch(usuarioFiltroRolProvider);
    final paginasState = ref.watch(usuariosPaginadosProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () => ref.read(usuariosProvider.notifier).refresh(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          SliverAppBar(
            toolbarHeight: 80,
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
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        widget.roleFilter != null ? '${widget.roleFilter}s' : 'Usuarios',
                        style: AppTextStyles.pageTitle.copyWith(color: Colors.white, letterSpacing: -0.02),
                      ),
                    ),
                    AppGaps.hSm,
                    Container(
                      width: 24, height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: AppShapes.circular20,
                      ),
                    ),
                    AppGaps.hXs,
                    Text(
                      widget.roleFilter != null ? 'Gestiona cuentas de ${widget.roleFilter?.toLowerCase()}s' : 'Gestiona cuentas y roles',
                      style: AppTextStyles.pageSubtitle.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: AppDecorations.simpleCard(
                        color: AppColors.surface,
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (value) => ref.read(searchQueryProvider.notifier).state = value,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o correo...',
                          hintStyle: AppTextStyles.cardSubtitle.copyWith(
                            color: AppColors.textSecondary.withValues(alpha: 0.5),
                          ),
                          prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 20),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref.read(searchQueryProvider.notifier).state = '';
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                        ),
                      ),
                    ),
                  ),
                  AppGaps.wMd,
                  Container(
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      gradient: AppColors.activeIconGradient,
                      borderRadius: AppShapes.circular16,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add, color: Colors.white),
                      onPressed: () => _showFormDialog(context),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _roles.length,
                separatorBuilder: (_, _) => AppGaps.wSm,
                itemBuilder: (context, index) {
                  final rol = _roles[index];
                  final isSelected = rol == rolSeleccionado;
                  return ChoiceChip(
                    label: Text(rol),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(usuarioFiltroRolProvider.notifier).setRol(rol);
                      ref.read(usuariosPaginadosProvider.notifier).reiniciar();
                    },
                    labelStyle: AppChipStyles.label(selected: isSelected),
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    shape: AppShapes.chipShape,
                    side: BorderSide.none,
                    showCheckmark: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  );
                },
              ),
            ),
          ),
          usuariosAsync.when(
            data: (_) {
              final visible = filtrados.take(paginasState).toList();
              if (filtrados.isEmpty) {
                return SliverFillRemaining(child: _buildEmptyState());
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= visible.length) {
                      return _buildCargarMasButton();
                    }
                    return UserCardWidget(
                      user: visible[index],
                      onEdit: () => _showFormDialog(context, user: visible[index]),
                      onDelete: () => _confirmDelete(visible[index]),
                    );
                  },
                  childCount: visible.length + (filtrados.length > paginasState ? 1 : 0),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (err, _) => SliverFillRemaining(child: _buildErrorState(err)),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildCargarMasButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: OutlinedButton.icon(
          onPressed: () => ref.read(usuariosPaginadosProvider.notifier).cargarMas(),
          icon: const Icon(Icons.expand_more, size: 22),
          label: const Text('Cargar más'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(color: AppColors.primary.withValues(alpha: 0.3)),
            shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final search = ref.watch(searchQueryProvider);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              search.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          AppGaps.hXxl,
          Text(
            search.isEmpty ? 'No hay usuarios registrados' : 'No se encontraron resultados',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          AppGaps.hSm,
          Text(
            search.isEmpty ? 'Comienza agregando un nuevo usuario' : 'Intenta con otros términos de búsqueda',
            style: AppTextStyles.sectionBody,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
            AppGaps.hLg,
            Text(
              'Ocurrió un error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.danger.withValues(alpha: 0.8),
              ),
            ),
            AppGaps.hSm,
            Text(err.toString(), textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
            AppGaps.hXxl,
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => ref.refresh(usuariosProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: AppShapes.circular16),
                ),
                child: const Text('Reintentar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
