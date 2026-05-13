import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_text_styles.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panel Administrativo', style: AppTextStyles.sectionTitle.copyWith(fontSize: 22)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, Administrador',
                  style: AppTextStyles.pageTitle.copyWith(fontSize: 24),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Selecciona una sección para gestionar el sistema.',
                  style: AppTextStyles.sectionBody,
                ),
                const SizedBox(height: 32),
                Expanded(
                  child: ListView.separated(
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final sections = [
                        _SectionData('Usuarios', Icons.badge_rounded, AppColors.primary, '/admin/usuarios'),
                        _SectionData('Incidencias', Icons.warning_amber_rounded, AppColors.danger, '/admin/incidencias'),
                        _SectionData('Aulas', Icons.meeting_room_rounded, AppColors.success, '/admin/aulas'),
                        _SectionData('Reservas', Icons.calendar_today_rounded, AppColors.info, '/admin/reservas'),
                      ];
                      return _buildSectionCard(context, sections[index]);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, _SectionData section) {
    return Card(
      elevation: 2,
      shadowColor: section.color.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => context.push(section.route),
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: section.color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(section.icon, size: 28, color: section.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  section.title,
                  style: AppTextStyles.cardTitle.copyWith(fontSize: 17),
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: section.color.withOpacity(0.6), size: 28),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionData {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  const _SectionData(this.title, this.icon, this.color, this.route);
}
