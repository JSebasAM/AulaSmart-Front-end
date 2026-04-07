import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      ('Inicio', Icons.grid_view_rounded),
      ('Reservas', Icons.calendar_month_outlined),
      ('Reportes', Icons.warning_amber_rounded),
      ('Perfil', Icons.person_outline),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 12),
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(color: Color(0x26000000), blurRadius: 18, offset: Offset(0, 6)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (index) {
            final isActive = index == currentIndex;
            final item = items[index];

            return GestureDetector(
              onTap: () => onTap(index),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: isActive ? 56 : 34,
                    height: isActive ? 48 : 34,
                    decoration: BoxDecoration(
                      gradient: isActive ? AppColors.primaryButtonGradient : null,
                      borderRadius: BorderRadius.circular(18),
                      border: isActive ? Border.all(color: AppColors.primaryDark.withValues(alpha: 0.45)) : null,
                    ),
                    child: Icon(item.$2, color: isActive ? Colors.white : AppColors.textSecondary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$1,
                    style: TextStyle(
                      color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      height: 1.0,
                    ),
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
