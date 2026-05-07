import 'package:aulasmart_front_end/services/auth/auth_notifier.dart';
import 'package:aulasmart_front_end/services/auth/auth_state.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/widgets/auth_text_field.dart';
import 'package:aulasmart_front_end/widgets/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class LoginView extends ConsumerStatefulWidget {
  const LoginView({super.key});

  @override
  ConsumerState<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  final _codigoController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _hidePassword = true;

  @override
  void dispose() {
    _codigoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _enterApp() {
    final codigo = _codigoController.text.trim();
    final password = _passwordController.text.trim();

    if (codigo.isEmpty || password.isEmpty) {
      _showMessage('Codigo de usuario y contraseña son obligatorios.');
      return;
    }

    ref.read(authNotifierProvider.notifier).login(codigo, password);
  }

  void _showMessage(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? Colors.redAccent : AppColors.primaryDark,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next is AuthError) {
        _showMessage(next.message);
      } else if (next is AuthSuccess) {
        _showMessage('Login exitoso', isError: false);
        context.go('/home');
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState is AuthLoading;

    final mediaSize = MediaQuery.sizeOf(context);
    final panelWidth = mediaSize.width < 448 ? mediaSize.width - 32 : 416.0;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
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
                    color: Colors.white.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.82), width: 1.2),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A5A48C6),
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
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x44676AF8),
                              blurRadius: 18,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 38),
                      ),
                      const SizedBox(height: 28),
                      const Text(
                        'Bienvenido',
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
                        'Ingresa a tu cuenta de AulaSmart',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 30),
                      AuthTextField(
                        label: 'Codigo de usuario',
                        hintText: '',
                        controller: _codigoController,
                        icon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: 18),
                      AuthTextField(
                        label: 'Contraseña',
                        hintText: '',
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
                      if (isLoading)
                        const SizedBox(
                          height: 56,
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.primary),
                          ),
                        )
                      else
                        PrimaryButton(
                          label: 'Iniciar Sesión',
                          onPressed: _enterApp,
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
