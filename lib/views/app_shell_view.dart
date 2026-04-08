import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/views/home_view.dart';
import 'package:aulasmart_front_end/views/perfil_view.dart';
import 'package:aulasmart_front_end/views/reportes_view.dart';
import 'package:aulasmart_front_end/views/reservas_view.dart';
import 'package:aulasmart_front_end/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

class AppShellView extends StatefulWidget {
  const AppShellView({super.key});

  @override
  State<AppShellView> createState() => _AppShellViewState();
}

class _AppShellViewState extends State<AppShellView> {
  int _currentIndex = 0;

  late final List<Widget> _pages = const [
    HomeView(),
    ReservasView(),
    ReportesView(),
    PerfilView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _pages,
                ),
              ),
              AppBottomNav(
                currentIndex: _currentIndex,
                onTap: (value) {
                  setState(() {
                    _currentIndex = value;
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
