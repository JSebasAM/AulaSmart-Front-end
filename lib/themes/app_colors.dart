import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF5B6CF9);
  static const Color primaryDark = Color(0xFF4656EC);
  static const Color accent = Color(0xFF8A67E8);
  static const Color background = Color(0xFFF4F2FF);
  static const Color surface = Color(0xFFF7F7FD);
  static const Color textPrimary = Color(0xFF2B2F5D);
  static const Color textSecondary = Color(0xFF8A97DB);
  static const Color border = Color(0xFFD8DEFF);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF1EEF9),
      Color(0xFFE7E4F5),
      Color(0xFFD9D2F0),
    ],
    stops: [0.0, 0.45, 1.0],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF6575F4), Color(0xFF8A5CEB)],
  );
}
