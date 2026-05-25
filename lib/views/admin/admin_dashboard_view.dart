import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/incidencias/presentation/providers/incidencia_provider.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countAsync = ref.watch(incidenciasCountProvider);
    final pendingCount = countAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrativo',
            style:
                AppTextStyles.sectionTitle.copyWith(fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration:
            const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, Administrador',
                  style:
                      AppTextStyles.pageTitle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona una seccion para gestionar el sistema.',
                  style: AppTextStyles.sectionBody,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1.1,
                    children: [
                      _DashboardCard(
                        icon: Icons.badge_rounded,
                        label: 'Usuarios',
                        color: AppColors.primary,
                        onTap: () => context.push('/admin/usuarios'),
                      ),
                      _DashboardCard(
                        icon: Icons.warning_amber_rounded,
                        label: 'Incidencias',
                        color: Colors.orange,
                        badge: pendingCount,
                        onTap: () =>
                            context.push('/admin/incidencias'),
                      ),
                      _DashboardCard(
                        icon: Icons.meeting_room_rounded,
                        label: 'Aulas',
                        color: AppColors.success,
                        onTap: () => context.push('/admin/aulas'),
                      ),
                      _DashboardCard(
                        icon: Icons.calendar_today_rounded,
                        label: 'Reservas',
                        color: AppColors.info,
                        onTap: () =>
                            context.push('/admin/reservas'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final int? badge;

  const _DashboardCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: color.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 32, color: color),
                  ),
                  if (badge != null && badge! > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: const BoxDecoration(
                          color: AppColors.danger,
                          shape: BoxShape.circle,
                        ),
                        constraints:
                            const BoxConstraints(minWidth: 22, minHeight: 22),
                        child: Center(
                          child: Text(
                            badge! > 99 ? '99+' : '$badge',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: AppTextStyles.cardTitle.copyWith(fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
