import 'package:flutter/material.dart';

class AppColors {
  // Colores Principales
  static const Color primary = Color(0xFF5E66F2);
  static const Color primaryDark = Color(0xFF4B4FA6);
  static const Color primaryLight = Color(0xFF7C86F5);
  static const Color secondary = Color(0xFF7C86F5);
  
  // Colores de Texto
  static const Color textPrimary = Color(0xFF3D47AA);
  static const Color textSecondary = Color(0xFF7F8DE8);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  // Colores de Superficie
  static const Color background = Color(0xFFF7F5FF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3FE);
  static const Color pageCard = Color(0xFFF8F8FD);
  
  // Colores de Estado
  static const Color success = Color(0xFF24C89A);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF6B11A);
  static const Color info = Color(0xFF4F63FF);
  static const Color neutral = Color(0xFF6B7280);
  
  // Elementos UI
  static const Color border = Color(0xFFE3E7FF);
  static const Color shadow = Color(0x0A000000);
  static const Color accent = Color(0xFF6B7FF2);
  static const Color disabled = Color(0xFF9CA3AF);

  // Colores para el modal de carta/reporte
  static const Color cartaPrimary = Color(0xFF5E66F2);
  static const Color cartaPrimaryDark = Color(0xFF4B4FA6);
  static const Color cartaSecondary = Color(0xFF99A6F2);
  static const Color cartaBackground = Color(0xFFF7F5FF);

  // Gradientes Premium
  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFF7F5FF),
      Color(0xFFF1EFFA),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF5E66F2),
      Color(0xFF7C86F5),
    ],
  );

  static const LinearGradient activeIconGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6E86FF),
      Color(0xFF4F63FF),
    ],
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF24C89A),
      Color(0xFF1CB389),
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

  static const LinearGradient dangerButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF6B6B),
      Color(0xFFEF4444),
    ],
  );
}
