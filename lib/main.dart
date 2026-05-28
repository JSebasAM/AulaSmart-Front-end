import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:aulasmart_front_end/core/routes/app_routes.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/core/themes/app_theme.dart';
import 'package:aulasmart_front_end/core/auth/session_provider.dart';
import 'package:aulasmart_front_end/core/storage/storage_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initializeDateFormatting('es', null);
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<bool>(sessionExpiredProvider, (_, expired) {
      if (!expired) return;
      final nav = navigatorKey.currentState;
      if (nav == null) return;
      nav.push(RawDialogRoute(
        barrierDismissible: false,
        pageBuilder: (ctx, _, __) => PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            title: const Icon(Icons.timer_off_rounded, size: 48, color: AppColors.warning),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Sesión expirada', style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
                SizedBox(height: 8),
                Text('Tu sesión ha expirado. Debes iniciar sesión nuevamente para continuar.',
                    style: AppTextStyles.sectionBody, textAlign: TextAlign.center),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await StorageService().clearAll();
                    ref.read(sessionExpiredProvider.notifier).state = false;
                    if (ctx.mounted) {
                      Navigator.of(ctx).pop();
                      routerProvider.go('/login');
                    }
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Iniciar sesión', style: TextStyle(color: AppColors.textOnPrimary)),
                ),
              ),
            ],
          ),
        ),
      ));
    });

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AulaSmart',
      theme: AppTheme.light(),
      routerConfig: routerProvider,
    );
  }
}
