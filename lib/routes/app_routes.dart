import 'package:aulasmart_front_end/views/app_shell_view.dart';
import 'package:aulasmart_front_end/views/evidence_view.dart';
import 'package:aulasmart_front_end/views/login_view.dart';
import 'package:go_router/go_router.dart';

final GoRouter routerProvider = GoRouter(
  initialLocation: '/login',
  routes: [
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
  ],
);

