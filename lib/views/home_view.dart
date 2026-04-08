import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Inicio',
        style: TextStyle(
          color: Colors.white,
          fontSize: 30,
          fontWeight: FontWeight.w700,
          shadows: [
            Shadow(color: AppColors.secondary, blurRadius: 6),
          ],
        ),
      ),
    );
  }
}
