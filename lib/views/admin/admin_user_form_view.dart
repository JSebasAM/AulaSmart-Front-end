import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario.dart';
import '../../services/usuario/usuario_notifier.dart';
import '../../widgets/admin/user_form_widget.dart';

class AdminUserFormView extends ConsumerStatefulWidget {
  final User? user;
  final String? fixedRole;
  final VoidCallback onSaved;

  const AdminUserFormView({
    super.key,
    this.user,
    this.fixedRole,
    required this.onSaved,
  });

  @override
  ConsumerState<AdminUserFormView> createState() => _AdminUserFormViewState();
}

class _AdminUserFormViewState extends ConsumerState<AdminUserFormView> {
  bool _isLoading = false;

  Future<void> _handleFormSubmit(Map<String, dynamic> formData) async {
    setState(() => _isLoading = true);

    try {
      final notifier = ref.read(usuarioProvider.notifier);

      if (widget.user != null) {
        // Editar usuario existente
        await notifier.editar(widget.user!.codigo, formData);
      } else {
        // Crear nuevo usuario
        await notifier.create(formData);
      }

      if (mounted) {
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.user != null
                ? 'Usuario actualizado correctamente'
                : 'Usuario registrado correctamente'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.user != null
                          ? 'Editar ${widget.fixedRole ?? 'Usuario'}'
                          : 'Nuevo ${widget.fixedRole ?? 'Usuario'}',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: AppColors.neutral),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.neutral.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  child: UserFormWidget(
                    onSubmit: () {},
                    onFormSubmit: _handleFormSubmit,
                    fixedRole: widget.fixedRole,
                    submitButtonLabel:
                        widget.user != null ? 'Guardar Cambios' : 'Crear Usuario',
                    initialData: widget.user != null
                        ? {
                            'nombre': widget.user!.nombre,
                            'apellido': widget.user!.apellido,
                            'email': widget.user!.email,
                            'password': widget.user!.password,
                            'rol': widget.user!.rol,
                          }
                        : null,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_isLoading)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
          ),
      ],
    );
  }
}
