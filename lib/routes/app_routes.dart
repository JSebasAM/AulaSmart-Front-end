import 'package:aulasmart_front_end/views/admin/admin_dashboard_view.dart';
import 'package:aulasmart_front_end/views/app_shell_view.dart';
import 'package:aulasmart_front_end/views/coming_soon_view.dart';
import 'package:aulasmart_front_end/views/evidence_view.dart';
import 'package:aulasmart_front_end/views/login_view.dart';
import 'package:aulasmart_front_end/features/aulas/presentation/views/aulas_screen.dart';
import 'package:aulasmart_front_end/features/aulas/presentation/views/aulas_admin_screen.dart';
import 'package:aulasmart_front_end/features/usuarios/presentation/views/usuarios_screen.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/views/admin_reservas_screen.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/views/admin_incidencias_screen.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/views/mis_incidencias_screen.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/views/incidencia_detail_screen.dart';
import 'package:aulasmart_front_end/services/storage_service.dart';
import 'package:aulasmart_front_end/services/rbac.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();


final GoRouter routerProvider = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/login',
  redirect: (context, state) async {
    final path = state.matchedLocation;
    if (!path.startsWith('/admin')) return null;
    final storage = StorageService();
    final userInfo = await storage.getUserInfo();
    final role = (userInfo?['rol'] ?? '').toString().toLowerCase();
    if (!Rbac.isAdmin(role)) return '/aulas';
    return null;
  },
  errorBuilder: (context, state) => const ComingSoonView(featureName: 'Ruta no encontrada'),
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, _) => '/aulas',
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginView(),
    ),
    GoRoute(
      path: '/aulas',
      builder: (_, _) => const AulasScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, _) => const AppShellView(),
    ),
    GoRoute(
      path: '/evidence',
      builder: (_, _) => const EvidenceView(),
    ),
    GoRoute(
      path: '/incidencias',
      builder: (_, _) => const MisIncidenciasScreen(),
    ),
    GoRoute(
      path: '/incidencias/:id',
      builder: (_, state) => IncidenciaDetailScreen(id: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (_, _) => const AdminDashboardView(),
    ),
    GoRoute(
      path: '/admin/usuarios',
      builder: (_, _) => const AdminUsersView(),
    ),
    GoRoute(
      path: '/admin/incidencias',
      builder: (_, _) => const AdminIncidenciasScreen(),
    ),
    GoRoute(
      path: '/admin/aulas',
      builder: (_, _) => const AulasAdminScreen(),
    ),
    GoRoute(
      path: '/admin/reservas',
      builder: (_, _) => const AdminReservasScreen(),
    ),
    
  ],
);
