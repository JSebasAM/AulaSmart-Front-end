import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF4F63FF);
  static const Color primaryDark = Color(0xFF3648D8);
  static const Color secondary = Color(0xFF8557D2);
  static const Color pageCard = Color(0xFFF4F4FA);
  static const Color textPrimary = Color(0xFF27369C);
  static const Color textSecondary = Color(0xFF7080E4);

  // Colores para el modal de carta/reporte
  static const Color cartaPrimary = Color(0xFF5E66F2);
  static const Color cartaPrimaryDark = Color(0xFF4B4FA6);
  static const Color cartaSecondary = Color(0xFF99A6F2);
  static const Color cartaBackground = Color(0xFFF9FAFB);

  static const Color accent = Color(0xFF8A67E8);
  static const Color background = Color(0xFFF4F2FF);
  static const Color surface = Color(0xFFF7F7FD);
  static const Color border = Color(0xFFD8DEFF);

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF4E69FF),
      Color(0xFF674CC5),
      Color(0xFF825ED3),
    ],
  );

  static const LinearGradient activeIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6E86FF),
      Color(0xFF4A5BEA),
    ],
  );

  static const LinearGradient cartaButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5E66F2),
      Color(0xFF6B7FF2),
    ],
  );
}
