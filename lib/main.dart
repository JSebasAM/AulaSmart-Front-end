import 'package:flutter/material.dart';
import 'package:aulasmart_front_end/views/app_shell_view.dart';

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
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const AppShellView(),
    );
  }
}
