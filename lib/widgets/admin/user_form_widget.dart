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
    selectedRol = widget.initialData?['rol'] ?? 'estudiante';
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            label: 'Nombre',
            hintText: 'Ingresa el nombre',
            controller: nombreController,
            icon: Icons.person,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: 'Apellido',
            hintText: 'Ingresa el apellido',
            controller: apellidoController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: 'Email',
            hintText: 'correo@ejemplo.com',
            controller: emailController,
            icon: Icons.email,
          ),
          const SizedBox(height: 20),
          AuthTextField(
            label: 'Contraseña',
            hintText: 'Ingresa una contraseña',
            controller: passwordController,
            icon: Icons.lock,
            obscureText: true,
          ),
          const SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rol',
                style: TextStyle(
                  color: Color(0xFF28356F),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButton<String>(
                  value: selectedRol,
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'estudiante', child: Text('Estudiante')),
                    DropdownMenuItem(value: 'profesor', child: Text('Profesor')),
                    DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedRol = value ?? 'estudiante';
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: widget.submitButtonLabel,
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }
}
