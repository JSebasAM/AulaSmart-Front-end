import 'package:aulasmart_front_end/views/home_view.dart';
import 'package:aulasmart_front_end/views/login_view.dart';
import 'package:go_router/go_router.dart';

final GoRouter routerProvider = GoRouter(
  routes: [
    GoRoute(
      path: '/login',
      builder: (_, _) => const LoginView(),
    ),
    GoRoute(
      path: '/home',
      builder: (_, _) => const HomeView(),
    ),
  ],
);

