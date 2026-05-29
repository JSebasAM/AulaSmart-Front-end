import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/presentation/admin_dashboard_view.dart';
import 'package:aulasmart_front_end/features/aulas/presentation/views/aulas_screen.dart';
import 'package:aulasmart_front_end/features/usuarios/presentation/views/perfil_view.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/views/reportes_view.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/views/reservas_view.dart';
import 'package:aulasmart_front_end/core/widgets/app_bottom_nav.dart';
import 'package:aulasmart_front_end/features/chat/presentation/widgets/chat_overlay.dart';
import 'package:aulasmart_front_end/features/auth/presentation/providers/user_role_provider.dart';
import 'package:aulasmart_front_end/core/auth/rbac.dart';
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
    final role = await ref.read(currentUserRoleProvider.future);
    final canAdmin = Rbac.isAdmin(role);

    final items = <NavItemData>[
      const NavItemData(
          label: 'Aulas', icon: Icons.grid_view_rounded, page: AulasScreen()),
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
      if (canAdmin)
        const NavItemData(
          label: 'Gestion',
          icon: Icons.admin_panel_settings_rounded,
          page: AdminDashboardView(),
        ),
    ];

    setState(() {
      _navItems = items;
      _loading = false;
    });
  }

  void _openChat() {
    Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => const ChatOverlay(),
      ),
    );
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
      floatingActionButton: FloatingActionButton(
        onPressed: _openChat,
        child: const Icon(Icons.smart_toy_rounded),
      ),
    );
  }
}
