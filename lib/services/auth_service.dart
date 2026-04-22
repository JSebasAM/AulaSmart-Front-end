import 'dart:async';

import 'package:aulasmart_front_end/models/user.dart';

class LoginResult {
  final bool success;
  final String message;

  const LoginResult({
    required this.success,
    required this.message,
  });
}

class AuthService {
  Future<LoginResult> login(User user) async {
    try {
      // TODO: Reemplazar por POST real al backend.
      // Endpoint sugerido: /api/auth/login
      // Payload esperado: user.toJson() -> {codigo, password}
      await Future<void>.delayed(const Duration(milliseconds: 700));

      if (user.codigo.trim().isEmpty || user.password.trim().isEmpty) {
        return const LoginResult(
          success: false,
          message: 'Codigo de usuario y contraseña son obligatorios.',
        );
      }

      return const LoginResult(
        success: true,
        message: 'Estructura de login lista para integrar backend.',
      );
    } catch (_) {
      return const LoginResult(
        success: false,
        message: 'No fue posible iniciar sesion.',
      );
    }
  }
}
