import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario.dart';
import '../../services/usuario/usuario_notifier.dart';
import '../../themes/app_colors.dart';
import '../../widgets/admin/user_card_widget.dart';
import '../../widgets/primary_button.dart';
import 'admin_user_form_view.dart';

class AdminUsersView extends ConsumerWidget {
  const AdminUsersView({super.key});

  void _showFormDialog(BuildContext context, WidgetRef ref, {User? user}) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: AdminUserFormView(
          user: user,
          onSaved: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          '¿Estás seguro de que deseas eliminar a ${user.nombre} ${user.apellido}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              ref.read(usuarioProvider.notifier).remove(user.codigo);
              Navigator.pop(context);
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Color(0xFFEF4444)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usuariosAsync = ref.watch(usuarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Estudiantes'),
        backgroundColor: const Color(0xFF28356F),
        foregroundColor: Colors.white,
      ),
      body: usuariosAsync.when(
        data: (usuarios) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total: ${usuarios.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                      child: PrimaryButton(
                        label: '+ Nuevo',
                        onPressed: () => _showFormDialog(context, ref),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: usuarios.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_add,
                              size: 64,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay estudiantes registrados',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => ref.read(usuarioProvider.notifier).refresh(),
                        child: ListView.builder(
                          itemCount: usuarios.length,
                          itemBuilder: (context, index) {
                            final user = usuarios[index];
                            return UserCardWidget(
                              user: user,
                              onEdit: () =>
                                  _showFormDialog(context, ref, user: user),
                              onDelete: () =>
                                  _confirmDelete(context, ref, user),
                            );
                          },
                        ),
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $err'),
              const SizedBox(height: 20),
              PrimaryButton(
                label: 'Reintentar',
                onPressed: () => ref.refresh(usuarioProvider),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
