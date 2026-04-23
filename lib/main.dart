import 'package:flutter/material.dart';
import 'package:aulasmart_front_end/views/app_shell_view.dart';
import 'package:aulasmart_front_end/routes/app_routes.dart';
import 'package:aulasmart_front_end/themes/app_theme.dart';
import 'package:aulasmart_front_end/views/login_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AulaSmart',
      theme: AppTheme.light(),
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginView(),
        AppRoutes.app: (_) => const AppShellView(),
      },
    );
  }
}
