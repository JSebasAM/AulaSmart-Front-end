import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../auth_text_field.dart';
import '../../widgets/primary_button.dart';

class UserFormWidget extends StatefulWidget {
  final VoidCallback onSubmit;
  final Function(Map<String, dynamic>) onFormSubmit;
  final String submitButtonLabel;
  final Map<String, dynamic>? initialData;
  final String? fixedRole;

  const UserFormWidget({
    super.key,
    required this.onSubmit,
    required this.onFormSubmit,
    this.submitButtonLabel = 'Registrar',
    this.initialData,
    this.fixedRole,
  });

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  String selectedRol = 'Estudiante';
  bool _hidePassword = true;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.initialData?['nombre'] ?? '');
    apellidoController = TextEditingController(text: widget.initialData?['apellido'] ?? '');
    emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    passwordController = TextEditingController(text: widget.initialData?['password'] ?? '');
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final formData = {
      'nombre': nombreController.text,
      'apellido': apellidoController.text,
      'email': emailController.text,
      'password': passwordController.text,
      'rol': widget.fixedRole,
    };
    widget.onFormSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            label: 'Nombre',
            hintText: 'Ej. Juan',
            controller: nombreController,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Apellido',
            hintText: 'Ej. Pérez',
            controller: apellidoController,
            icon: Icons.person_outline_rounded,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Email',
            hintText: 'correo@estudiante.com',
            controller: emailController,
            icon: Icons.email_rounded,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Contraseña',
            hintText: 'Mínimo 8 caracteres',
            controller: passwordController,
            icon: Icons.lock_rounded,
            obscureText: _hidePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),

          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: PrimaryButton(
              label: widget.submitButtonLabel,
              onPressed: _submitForm,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
