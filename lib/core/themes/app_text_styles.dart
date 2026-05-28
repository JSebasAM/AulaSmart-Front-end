import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  static const TextStyle pageTitle = TextStyle(
    color: AppColors.primaryDark,
    fontSize: 33,
    fontWeight: FontWeight.w800,
    height: 1.0,
  );

  static const TextStyle pageSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 18,
    fontWeight: FontWeight.w500,
    height: 1.2,
  );

  static const TextStyle sectionTitle = TextStyle(
    color: AppColors.primaryDark,
    fontSize: 18,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle sectionBody = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle cardTitle = TextStyle(
    color: AppColors.primaryDark,
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle cardSubtitle = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle smallLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 10,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle tinyLabel = TextStyle(
    color: AppColors.textSecondary,
    fontSize: 9,
    fontWeight: FontWeight.w600,
  );
}
