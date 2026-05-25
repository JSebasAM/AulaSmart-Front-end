import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar usuario'),
        content: Text(
          'Esta seguro de que deseas eliminar a ${user.nombre} ${user.apellido}?\nEsta accion no se puede deshacer.',
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showPasswordDialog(UsuarioEntity user) {
    final controller = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Cambiar contrasena de ${user.nombre}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: controller,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Nueva contrasena',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirmar contrasena',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requerido';
                  if (v != controller.text) return 'No coinciden';
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              try {
                await ref
                    .read(usuariosProvider.notifier)
                    .cambiarPassword(user.codigo, controller.text);
                if (mounted) Navigator.pop(context);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Contrasena actualizada'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Guardar'),
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
      appBar: AppBar(
        title: Text(
          widget.roleFilter != null ? 'Gestión de ${widget.roleFilter}s' : 'Gestión de Usuarios',
          style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  ref.read(searchQueryProvider.notifier).state = value,
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre o correo...',
                                hintStyle: AppTextStyles.cardSubtitle.copyWith(
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                prefixIcon: const Icon(Icons.search,
                                    color: AppColors.primary),
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
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            gradient: AppColors.activeIconGradient,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
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
                  ],
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _roles.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
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
                      labelStyle: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                      ),
                      backgroundColor: Colors.white,
                      selectedColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide.none,
                      showCheckmark: false,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: usuariosAsync.when(
                  data: (_) {
                    final visible = filtrados.take(paginasState).toList();

                    if (filtrados.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(usuariosProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: visible.length + (filtrados.length > paginasState ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= visible.length) {
                            return _buildCargarMasButton();
                          }
                          final user = visible[index];
                          return UserCardWidget(
                            user: user,
                            onEdit: () =>
                                _showFormDialog(context, user: user),
                            onDelete: () => _confirmDelete(user),
                            onChangePassword: () =>
                                _showPasswordDialog(user),
                          );
                        },
                      ),
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  error: (err, stack) => _buildErrorState(err),
                ),
              ),
            ],
          ),
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
            side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              search.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            search.isEmpty
                ? 'No hay usuarios registrados'
                : 'No se encontraron resultados',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            search.isEmpty
                ? 'Comienza agregando un nuevo usuario'
                : 'Intenta con otros términos de búsqueda',
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
            const SizedBox(height: 16),
            Text(
              'Ocurrió un error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.danger.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed: () => ref.refresh(usuariosProvider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
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
