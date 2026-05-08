import 'package:aulasmart_front_end/themes/app_colors.dart';
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
    // Vista obligatoria para todos
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
        label: 'Admin',
        icon: Icons.admin_panel_settings_rounded,
        page: AdminUsersView(),
        subItems: [
          NavSubItem(label: 'Usuarios', icon: Icons.people_alt_rounded, index: 3),
          NavSubItem(label: 'Docentes', icon: Icons.badge_rounded, index: 5),
          NavSubItem(label: 'Estudiantes', icon: Icons.school_rounded, index: 6),
        ],
      ),
      const NavItemData(
          label: 'Perfil', icon: Icons.person_outline, page: PerfilView()),
      const NavItemData(
          label: 'Docentes', icon: Icons.badge_rounded, page: AdminUsersView(roleFilter: 'Docente'), showInNavBar: false),
      const NavItemData(
          label: 'Estudiantes', icon: Icons.school_rounded, page: AdminUsersView(roleFilter: 'Estudiante'), showInNavBar: false),
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
