import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario.dart';
import '../../services/usuario/usuario_notifier.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';
import '../../widgets/admin/user_card_widget.dart';
import '../../widgets/primary_button.dart';
import 'admin_user_form_view.dart';

class AdminUsersView extends ConsumerStatefulWidget {
  final String? roleFilter;
  const AdminUsersView({super.key, this.roleFilter});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  void _showFormDialog(BuildContext context, {User? user}) {
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

  void _confirmDelete(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
              await ref.read(usuarioProvider.notifier).remove(user.codigo);
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

  @override
  Widget build(BuildContext context) {
    final usuariosAsync = ref.watch(usuarioProvider);

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
              // Barra de búsqueda y botón nuevo
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                                  setState(() => _searchQuery = value),
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre o correo...',
                                hintStyle: AppTextStyles.cardSubtitle.copyWith(
                                  color: AppColors.textSecondary.withOpacity(0.5),
                                ),
                                prefixIcon: const Icon(Icons.search,
                                    color: AppColors.primary),
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
              // Lista de usuarios
              Expanded(
                child: usuariosAsync.when(
                  data: (usuarios) {
                    final filteredUsers = usuarios.where((u) {
                      // Filtrar por rol si aplica
                      if (widget.roleFilter != null && u.rol != widget.roleFilter) {
                        return false;
                      }

                      final nameMatch = u.nombre
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                      final emailMatch = u.email
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase());
                      return nameMatch || emailMatch;
                    }).toList();

                    if (filteredUsers.isEmpty) {
                      return _buildEmptyState();
                    }

                    return RefreshIndicator(
                      onRefresh: () =>
                          ref.read(usuarioProvider.notifier).refresh(),
                      child: ListView.builder(
                        padding: const EdgeInsets.only(bottom: 80),
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return UserCardWidget(
                            user: user,
                            onEdit: () =>
                                _showFormDialog(context, user: user),
                            onDelete: () => _confirmDelete(user),
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

  Widget _buildEmptyState() {
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
              _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 64,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _searchQuery.isEmpty
                ? 'No hay usuarios registrados'
                : 'No se encontraron resultados',
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
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
            PrimaryButton(
              label: 'Reintentar',
              onPressed: () => ref.refresh(usuarioProvider),
            ),
          ],
        ),
      ),
    );
  }
}
