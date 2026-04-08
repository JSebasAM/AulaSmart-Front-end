import 'package:aulasmart_front_end/routes/app_routes.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/widgets/auth_text_field.dart';
import 'package:aulasmart_front_end/widgets/primary_button.dart';
import 'package:flutter/material.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isStudent = true;
  bool _hidePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _register() {
    Navigator.pushReplacementNamed(context, AppRoutes.app);
  }

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.sizeOf(context);
    final panelWidth = mediaSize.width < 448 ? mediaSize.width - 32 : 416.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF4EFFB),
              Color(0xFFECE4F9),
              Color(0xFFD9D6F6),
            ],
            stops: [0.0, 0.44, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: mediaSize.height - 60),
              child: Center(
                child: Container(
                  width: panelWidth,
                  constraints: const BoxConstraints(maxWidth: 416),
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.74),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.82), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A7B4CEB),
                        blurRadius: 30,
                        offset: Offset(0, 12),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF8B60EF), Color(0xFFF04CD6)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x448B60EF),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Crea tu Cuenta',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 31,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Únete a AulaSmart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Row(
                        children: [
                          Expanded(
                            child: _RoleButton(
                              label: 'Estudiante',
                              selected: _isStudent,
                              onTap: () => setState(() => _isStudent = true),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _RoleButton(
                              label: 'Docente',
                              selected: !_isStudent,
                              onTap: () => setState(() => _isStudent = false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      AuthTextField(
                        label: 'Nombre Completo',
                        hintText: 'Juan Pérez',
                        controller: _nameController,
                        icon: Icons.person_outline_rounded,
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        label: 'Correo Institucional',
                        hintText: 'usuario@uceva.edu.co',
                        controller: _emailController,
                        icon: Icons.email_outlined,
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        label: 'Contraseña',
                        hintText: '••••••••',
                        controller: _passwordController,
                        icon: Icons.lock_outline_rounded,
                        obscureText: _hidePassword,
                        suffixIcon: IconButton(
                          onPressed: () => setState(() => _hidePassword = !_hidePassword),
                          icon: Icon(
                            _hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton(
                        label: 'Registrarse',
                        icon: Icons.person_add_alt_1_rounded,
                        onPressed: _register,
                      ),
                      const SizedBox(height: 22),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          const Text(
                            '¿Ya tienes cuenta? ',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(
                                color: AppColors.primaryDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryDark, size: 16),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF8C62F0), Color(0xFFF04AD8)],
    );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 56,
        decoration: BoxDecoration(
          gradient: selected ? gradient : null,
          color: selected ? null : Colors.white.withValues(alpha: 0.80),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? Colors.transparent : const Color(0xFFE5E9FB),
            width: 1.0,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x4A9C4CF1),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                  ),
                ]
              : const [],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
