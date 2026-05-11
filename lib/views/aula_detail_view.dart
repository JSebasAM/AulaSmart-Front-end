import 'package:aulasmart_front_end/models/aula.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class AulaDetailView extends StatelessWidget {
  const AulaDetailView({super.key, required this.aula});

  final Aula aula;

  @override
  Widget build(BuildContext context) {
    //final disponible = aula.disponible;
    //final accentColor = disponible ? AppColors.success : AppColors.danger;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.pageGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _TopBar(onBack: () => Navigator.of(context).pop()),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: AspectRatio(
                    aspectRatio: 1.35,
                    child: Image.network(
                      aula.imagenUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, _, __) {
                        return Container(
                          color: AppColors.surface.withValues(alpha: 0.65),
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported_outlined, color: AppColors.primary, size: 42),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.72),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              aula.nombre,
                              style: AppTextStyles.sectionTitle.copyWith(fontSize: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: aula.estaLibre ? const Color(0xFF34D399) : const Color(0xFFF87171),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              aula.estado,
                              style: AppTextStyles.smallLabel.copyWith(color: AppColors.surface),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${aula.edificio} • Piso ${aula.piso}',
                        style: AppTextStyles.sectionBody,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _descripcionPara(aula),
                        style: AppTextStyles.sectionBody.copyWith(height: 1.45),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _InfoTile(icon: Icons.people_outline, title: 'Capacidad', value: '${aula.capacidad} estudiantes')),
                    const SizedBox(width: 10),
                    Expanded(child: _InfoTile(icon: Icons.wifi_rounded, title: 'Internet', value: aula.tieneWifi ? 'WiFi de Alta Velocidad' : 'No disponible')),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _InfoTile(icon: Icons.videocam_outlined, title: 'Equipamiento', value: aula.tieneVideo ? 'Proyector HD' : 'Sin proyector')),
                    const SizedBox(width: 10),
                    Expanded(child: _InfoTile(icon: Icons.place_outlined, title: 'Ubicación', value: aula.ubicacion)),
                  ],
                ),
                const SizedBox(height: 14),
                _ActionButton(
                  label: 'Reservar Aula',
                  icon: Icons.event_available_outlined,
                  gradient: AppColors.cartaButtonGradient,
                  onTap: () {},
                ),
                const SizedBox(height: 10),
                _ActionButton(
                  label: 'Reportar Incidencia',
                  icon: Icons.warning_amber_rounded,
                  gradient: AppColors.dangerButtonGradient,
                  onTap: () {},
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface.withValues(alpha: 0.68),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Horario de Hoy', style: AppTextStyles.sectionTitle.copyWith(fontSize: 17)),
                      const SizedBox(height: 4),
                      Text('Martes, 22 de Abril, 2026', style: AppTextStyles.cardSubtitle),
                      const SizedBox(height: 12),
                      _ScheduleItem(
                        time: '07:00 - 09:00',
                        title: 'Cálculo I - Dr. Mario García',
                        status: 'Completada',
                        statusColor: AppColors.neutral,
                      ),
                      const SizedBox(height: 10),
                      _ScheduleItem(
                        time: '09:00 - 11:00',
                        title: 'Disponible',
                        status: 'Libre',
                        statusColor: AppColors.success,
                      ),
                      const SizedBox(height: 10),
                      _ScheduleItem(
                        time: '11:00 - 13:00',
                        title: 'Física II - Dr. Juan Pérez',
                        status: 'Ocupada',
                        statusColor: AppColors.danger,
                      ),
                      const SizedBox(height: 10),
                      _ScheduleItem(
                        time: '13:00 - 15:00',
                        title: 'Disponible',
                        status: 'Libre',
                        statusColor: AppColors.success,
                      ),
                      const SizedBox(height: 10),
                      _ScheduleItem(
                        time: '15:00 - 17:00',
                        title: 'Diseño de Ingeniería',
                        status: 'Programada',
                        statusColor: AppColors.info,
                      ),
                      const SizedBox(height: 10),
                      _ScheduleItem(
                        time: '17:00 - 19:00',
                        title: 'Disponible',
                        status: 'Libre',
                        statusColor: AppColors.success,
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

  String _descripcionPara(Aula aula) {
    return 'Aula amplia ideal para clases magistrales, presentaciones y actividades de grupos grandes. Conserva el mismo lenguaje visual de la app y aprovecha la infraestructura disponible del edificio.';
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onBack,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.surface, size: 14),
                const SizedBox(width: 4),
                Text(
                  'Volver',
                  style: AppTextStyles.smallLabel.copyWith(color: AppColors.surface),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.title, required this.value});

  final IconData icon;
  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.smallLabel.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.label, required this.icon, required this.gradient, required this.onTap});

  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.surface, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppTextStyles.cardTitle.copyWith(color: AppColors.surface, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScheduleItem extends StatelessWidget {
  const _ScheduleItem({required this.time, required this.title, required this.status, required this.statusColor});

  final String time;
  final String title;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: statusColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(Icons.access_time_rounded, color: statusColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(time, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(title, style: AppTextStyles.cardSubtitle),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              status,
              style: AppTextStyles.smallLabel.copyWith(color: AppColors.surface),
            ),
          ),
        ],
      ),
    );
  }
}
