import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../auth_text_field.dart';
import '../../widgets/primary_button.dart';

class UserFormWidget extends StatefulWidget {
  final VoidCallback onSubmit;
  final Function(Map<String, dynamic>) onFormSubmit;
  final String submitButtonLabel;
  final Map<String, dynamic>? initialData;

  const UserFormWidget({
    super.key,
    required this.onSubmit,
    required this.onFormSubmit,
    this.submitButtonLabel = 'Registrar',
    this.initialData,
  });

  @override
  State<UserFormWidget> createState() => _UserFormWidgetState();
}

class _UserFormWidgetState extends State<UserFormWidget> {
  late TextEditingController nombreController;
  late TextEditingController apellidoController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  String selectedRol = 'estudiante';

  @override
  void initState() {
    super.initState();
    nombreController =
        TextEditingController(text: widget.initialData?['nombre'] ?? '');
    apellidoController =
        TextEditingController(text: widget.initialData?['apellido'] ?? '');
    emailController =
        TextEditingController(text: widget.initialData?['email'] ?? '');
    passwordController =
        TextEditingController(text: widget.initialData?['password'] ?? '');
    selectedRol = widget.initialData?['rol'] ?? 'Estudiante';
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
      'rol': selectedRol,
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
            obscureText: true,
          ),
          const SizedBox(height: 20),
          const Text(
            'Rol del usuario',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedRol,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12),
                items: const [
                  DropdownMenuItem(value: 'Estudiante', child: Text('Estudiante')),
                  DropdownMenuItem(value: 'Docente', child: Text('Docente')),
                  DropdownMenuItem(value: 'Administrativo', child: Text('Administrativo')),
                  DropdownMenuItem(value: 'Monitor', child: Text('Monitor')),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedRol = value ?? 'Estudiante';
                  });
                },
              ),
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
