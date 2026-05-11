import 'package:aulasmart_front_end/views/admin/admin_dashboard_view.dart';
import 'package:aulasmart_front_end/views/admin/admin_users_view.dart';
import 'package:aulasmart_front_end/views/app_shell_view.dart';
import 'package:aulasmart_front_end/views/coming_soon_view.dart';
import 'package:aulasmart_front_end/views/evidence_view.dart';
import 'package:aulasmart_front_end/views/login_view.dart';
import 'package:go_router/go_router.dart';

final GoRouter routerProvider = GoRouter(
  initialLocation: '/login',
  errorBuilder: (context, state) => const ComingSoonView(featureName: 'Ruta no encontrada'),
  routes: [
    GoRoute(
      path: '/',
      redirect: (_, _) => '/home',
    ),
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginView(),
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
      path: '/admin/dashboard',
      builder: (_, _) => const AdminDashboardView(),
    ),
    GoRoute(
      path: '/admin/docentes',
      builder: (_, _) => const AdminUsersView(roleFilter: 'Docente'),
    ),
    GoRoute(
      path: '/admin/estudiantes',
      builder: (_, _) => const AdminUsersView(roleFilter: 'Estudiante'),
    ),
    GoRoute(
      path: '/admin/users',
      builder: (_, _) => const AdminUsersView(),
    ),
    GoRoute(
      path: '/admin/incidencias',
      builder: (_, _) => const ComingSoonView(featureName: 'Gestión de Incidencias'),
    ),
    GoRoute(
      path: '/admin/aulas',
      builder: (_, _) => const ComingSoonView(featureName: 'Gestión de Aulas'),
    ),
  ],
);
