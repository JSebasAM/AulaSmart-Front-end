import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';
import '../../../../widgets/auth_text_field.dart';
import '../../../../widgets/primary_button.dart';

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
  String? _passwordError;
  bool get _isEditing => widget.initialData != null;

  @override
  void initState() {
    super.initState();
    nombreController = TextEditingController(text: widget.initialData?['nombre'] ?? '');
    apellidoController = TextEditingController(text: widget.initialData?['apellido'] ?? '');
    emailController = TextEditingController(text: widget.initialData?['email'] ?? '');
    passwordController = TextEditingController();
    selectedRol = widget.fixedRole ?? widget.initialData?['rol'] ?? 'Estudiante';
  }

  @override
  void dispose() {
    nombreController.dispose();
    apellidoController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length < 8) return 'Minimo 8 caracteres';
    if (!value.contains(RegExp(r'[A-Z]'))) return 'Debe contener al menos una mayuscula';
    if (!value.contains(RegExp(r'[a-z]'))) return 'Debe contener al menos una minuscula';
    if (!value.contains(RegExp(r'[0-9]'))) return 'Debe contener al menos un numero';
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) return 'Debe contener un caracter especial';
    return null;
  }

  void _submitForm() {
    final pwd = passwordController.text.trim();
    setState(() => _passwordError = _validatePassword(pwd));
    if (_passwordError != null) return;

    final formData = <String, dynamic>{
      'nombre': nombreController.text,
      'apellido': apellidoController.text,
      'email': emailController.text,
      'rol': widget.fixedRole ?? selectedRol,
    };
    if (pwd.isNotEmpty) {
      formData['password'] = pwd;
    }
    widget.onFormSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    final codigo = widget.initialData?['codigo']?.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (codigo != null && codigo.isNotEmpty) ...[
            AuthTextField(
              label: 'ID Usuario',
              hintText: codigo,
              controller: TextEditingController(text: codigo),
              icon: Icons.badge_outlined,
              enabled: false,
            ),
            const SizedBox(height: 16),
          ],
          AuthTextField(
            label: 'Nombre',
            hintText: 'Ej. Juan',
            controller: nombreController,
            icon: Icons.person_rounded,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Apellido',
            hintText: 'Ej. Perez',
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
            label: 'Contrasena',
            hintText: _isEditing ? 'Dejar vacio para mantener la actual' : 'Minimo 8 caracteres',
            controller: passwordController,
            icon: Icons.lock_rounded,
            obscureText: _hidePassword,
            errorText: _passwordError,
            onChanged: (_) => setState(() => _passwordError = null),
            suffixIcon: IconButton(
              icon: Icon(
                _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: AppColors.textSecondary,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          if (widget.fixedRole == null) ...[
            const SizedBox(height: 20),
            const Text(
              'Rol del usuario',
              style: TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedRol,
                  isExpanded: true,
                  icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                  items: const [
                    DropdownMenuItem(value: 'Estudiante', child: Text('Estudiante')),
                    DropdownMenuItem(value: 'Docente', child: Text('Docente')),
                    DropdownMenuItem(value: 'Administrativo', child: Text('Administrativo')),
                    DropdownMenuItem(value: 'Administrador', child: Text('Administrador')),
                    DropdownMenuItem(value: 'Monitor', child: Text('Monitor')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => selectedRol = value);
                  },
                ),
              ),
            ),
          ],
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
