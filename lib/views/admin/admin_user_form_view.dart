import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/usuario.dart';
import '../../services/usuario/usuario_notifier.dart';
import '../../widgets/admin/user_form_widget.dart';

class AdminUserFormView extends ConsumerStatefulWidget {
  final User? user;
  final VoidCallback onSaved;

  const AdminUserFormView({
    super.key,
    this.user,
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
                ? 'Estudiante actualizado correctamente'
                : 'Estudiante registrado correctamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
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
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  widget.user != null
                      ? 'Editar Estudiante'
                      : 'Registrar Nuevo Estudiante',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF28356F),
                  ),
                ),
              ),
              UserFormWidget(
                onSubmit: () {},
                onFormSubmit: _handleFormSubmit,
                submitButtonLabel:
                    widget.user != null ? 'Actualizar' : 'Registrar',
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
            ],
          ),
        ),
        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
      ],
    );
  }
}
