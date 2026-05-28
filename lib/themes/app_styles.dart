import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppGaps {
  static const double xs2 = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;

  static const SizedBox hXs = SizedBox(height: xs);
  static const SizedBox hXs2 = SizedBox(height: xs2);
  static const SizedBox hSm = SizedBox(height: sm);
  static const SizedBox hMd = SizedBox(height: md);
  static const SizedBox hLg = SizedBox(height: lg);
  static const SizedBox hXl = SizedBox(height: xl);
  static const SizedBox hXxl = SizedBox(height: xxl);
  static const double xxxl = 32;
  static const SizedBox hXxxl = SizedBox(height: xxxl);

  static const SizedBox wXs = SizedBox(width: xs);
  static const SizedBox wSm = SizedBox(width: sm);
  static const SizedBox wMd = SizedBox(width: md);
  static const SizedBox wLg = SizedBox(width: lg);
  static const SizedBox wXl = SizedBox(width: xl);
}

class AppShapes {
  static const BorderRadius circular8 = BorderRadius.all(Radius.circular(8));
  static const BorderRadius circular12 = BorderRadius.all(Radius.circular(12));
  static const BorderRadius circular16 = BorderRadius.all(Radius.circular(16));
  static const BorderRadius circular20 = BorderRadius.all(Radius.circular(20));
  static const BorderRadius circular24 = BorderRadius.all(Radius.circular(24));
  static const BorderRadius circular28 = BorderRadius.all(Radius.circular(28));
  static const BorderRadius circular32 = BorderRadius.all(Radius.circular(32));

  static const RoundedRectangleBorder chipShape =
      RoundedRectangleBorder(borderRadius: circular20);
}

class AppDecorations {
  static BoxDecoration card({
    Color color = AppColors.surface,
    Color borderColor = AppColors.border,
    double borderOpacity = 0.5,
    Color shadowColor = AppColors.shadow,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: AppShapes.circular24,
      border: Border.all(color: borderColor.withValues(alpha: borderOpacity)),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  static BoxDecoration simpleCard({
    Color color = AppColors.surface,
    Color borderColor = AppColors.border,
    double borderOpacity = 0.5,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: AppShapes.circular16,
      border: Border.all(color: borderColor.withValues(alpha: borderOpacity)),
    );
  }

  static BoxDecoration badge({
    Color color = AppColors.surfaceVariant,
    double opacity = 1.0,
    BorderRadius borderRadius = AppShapes.circular12,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration pill({
    required Color color,
    double opacity = 0.12,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: AppShapes.circular20,
    );
  }

  static BoxDecoration statusDot({
    required Color color,
    double opacity = 0.1,
    BorderRadius borderRadius = AppShapes.circular12,
  }) {
    return BoxDecoration(
      color: color.withValues(alpha: opacity),
      borderRadius: borderRadius,
    );
  }

  static BoxDecoration dropdown({
    Color color = AppColors.surface,
    Color borderColor = AppColors.neutral,
    double borderOpacity = 0.2,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: AppShapes.circular12,
      border: Border.all(color: borderColor.withValues(alpha: borderOpacity)),
    );
  }
}

class AppInputStyles {
  static InputDecoration search({
    String hint = 'Buscar aula...',
    Color fillColor = AppColors.surfaceVariant,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: const Icon(Icons.search),
      filled: true,
      fillColor: fillColor,
      border: OutlineInputBorder(
        borderRadius: AppShapes.circular12,
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 12),
    );
  }

  static TextStyle dropdownLabel = const TextStyle(
    color: AppColors.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.bold,
  );
}

class AppChipStyles {
  static TextStyle label({required bool selected}) {
    return TextStyle(
      fontWeight: selected ? FontWeight.bold : FontWeight.w600,
      color: selected ? AppColors.textOnPrimary : AppColors.textSecondary,
    );
  }
}

class AppButtonStyles {
  static ButtonStyle tonal = FilledButton.styleFrom(
    shape: RoundedRectangleBorder(borderRadius: AppShapes.circular20),
  );
}
