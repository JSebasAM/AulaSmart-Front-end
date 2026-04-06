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
    const labels = ['Inicio', 'Reservas', 'Reportes', 'Perfil'];
    const icons = [
      Icons.grid_view_rounded,
      Icons.calendar_month_outlined,
      Icons.warning_amber_rounded,
      Icons.person_outline,
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(14, 0, 14, 10),
      child: Container(
        height: 102,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.pageCard,
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x30000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(labels.length, (index) {
            final isActive = index == currentIndex;

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
                      gradient: isActive ? AppColors.activeIconGradient : null,
                      borderRadius: BorderRadius.circular(18),
                      border: isActive
                        ? Border.all(color: AppColors.primaryDark.withValues(alpha: 0.45))
                          : null,
                    ),
                    child: Icon(
                      icons[index],
                      color: isActive ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isActive ? AppColors.primaryDark : AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                      height: 1.0,
                    ),
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.visible,
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
