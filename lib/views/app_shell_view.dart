import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/views/home_view.dart';
import 'package:aulasmart_front_end/views/perfil_view.dart';
import 'package:aulasmart_front_end/views/reportes_view.dart';
import 'package:aulasmart_front_end/views/reservas_view.dart';
import 'package:aulasmart_front_end/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/services/storage_service.dart';

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
    final storage = ref.read(storageServiceProvider);
    final userInfo = await storage.getUserInfo();
    final rol = userInfo?['rol'] as String? ?? '';

    // Vista obligatoria para todos
    final items = [
      const NavItemData(label: 'Inicio', icon: Icons.grid_view_rounded, page: HomeView()),
    ];

    // Lógica RBAC (Control de Acceso Basado en Roles)
    final r = rol.toLowerCase();
    
    if (r == 'docente' || r == 'administrativo') {
      items.add(const NavItemData(label: 'Reservas', icon: Icons.calendar_month_outlined, page: ReservasView()));
    }

    if (r == 'soporte' || r == 'administrativo') {
      items.add(const NavItemData(label: 'Reportes', icon: Icons.warning_amber_rounded, page: ReportesView()));
    }

    // Vista obligatoria para todos
    items.add(const NavItemData(label: 'Perfil', icon: Icons.person_outline, page: PerfilView()));

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
                child: IndexedStack(
                  index: _currentIndex,
                  children: _navItems.map((e) => e.page).toList(),
                ),
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
