import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';

class ComingSoonView extends StatelessWidget {
  final String featureName;
  
  const ComingSoonView({
    super.key, 
    required this.featureName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.construction_rounded,
                size: 80,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              featureName,
              style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 12),
            const Text(
              'Esta sección está actualmente en desarrollo.',
              style: AppTextStyles.pageSubtitle,
            ),
            const SizedBox(height: 8),
            const Text(
              '¡Vuelve pronto para ver las novedades!',
              style: AppTextStyles.sectionBody,
            ),
          ],
        ),
      ),
    );
  }
}
