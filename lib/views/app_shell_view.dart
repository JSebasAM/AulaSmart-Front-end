import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/views/admin/admin_dashboard_view.dart';
import 'package:aulasmart_front_end/views/admin/admin_users_view.dart';
import 'package:aulasmart_front_end/views/home_view.dart';
import 'package:aulasmart_front_end/views/perfil_view.dart';
import 'package:aulasmart_front_end/views/reportes_view.dart';
import 'package:aulasmart_front_end/views/reservas_view.dart';
import 'package:aulasmart_front_end/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShellView extends ConsumerStatefulWidget {
  const AppShellView({super.key});

  @override
  ConsumerState<AppShellView> createState() => _AppShellViewState();
}

class _AppShellViewState extends ConsumerState<AppShellView> {
  int _currentIndex = 0;
  List<NavItemData> _navItems = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final items = [
      const NavItemData(
          label: 'Inicio', icon: Icons.grid_view_rounded, page: HomeView()),
      const NavItemData(
          label: 'Reservas',
          icon: Icons.calendar_month_outlined,
          page: ReservasView()),
      const NavItemData(
          label: 'Reportes',
          icon: Icons.warning_amber_rounded,
          page: ReportesView()),
      const NavItemData(
          label: 'Perfil', icon: Icons.person_outline, page: PerfilView()),
      const NavItemData(
        label: 'Gestión',
        icon: Icons.admin_panel_settings_rounded,
        page: AdminDashboardView(),
      ),
    ];

    setState(() {
      _navItems = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: _navItems[_currentIndex].page,
              ),
              AppBottomNav(
                currentIndex: _currentIndex,
                items: _navItems,
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
