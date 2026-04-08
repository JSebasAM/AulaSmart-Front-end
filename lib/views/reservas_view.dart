import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ReservasView extends StatelessWidget {
  const ReservasView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Reservas',
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
