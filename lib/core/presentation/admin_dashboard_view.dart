import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../themes/app_styles.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: 100,
            floating: false,
            pinned: false,
            backgroundColor: Colors.transparent,
            forceMaterialTransparency: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 24, top: 8),
              child: DefaultTextStyle(
                style: const TextStyle(),
                softWrap: true,
                overflow: TextOverflow.visible,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'Gestión',
                        style: AppTextStyles.pageTitle.copyWith(
                          color: Colors.white,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ),
                    AppGaps.hSm,
                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: AppShapes.circular20,
                      ),
                    ),
                    AppGaps.hXs,
                    Text(
                      'Administración del sistema',
                      style: AppTextStyles.pageSubtitle.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                children: [
                  _SectionCard(
                    title: 'Usuarios',
                    icon: Icons.badge_rounded,
                    color: AppColors.primary,
                    route: '/admin/usuarios',
                  ),
                  AppGaps.hMd,
                  _SectionCard(
                    title: 'Incidencias',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.danger,
                    route: '/admin/incidencias',
                  ),
                  AppGaps.hMd,
                  _SectionCard(
                    title: 'Aulas',
                    icon: Icons.meeting_room_rounded,
                    color: AppColors.success,
                    route: '/admin/aulas',
                  ),
                  AppGaps.hMd,
                  _SectionCard(
                    title: 'Reservas',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.info,
                    route: '/admin/reservas',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular24,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: color)),
          InkWell(
            onTap: () => context.push(route),
            borderRadius: AppShapes.circular24,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: AppShapes.circular16,
                    ),
                    child: Icon(icon, color: color, size: 24),
                  ),
                  AppGaps.wMd,
                  Expanded(
                    child: Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 17)),
                  ),
                  Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.6), size: 28),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
