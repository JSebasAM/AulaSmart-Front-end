import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReservasView extends ConsumerStatefulWidget {
  const ReservasView({super.key});

  @override
  ConsumerState<ReservasView> createState() => _ReservasViewState();
}

class _ReservasViewState extends ConsumerState<ReservasView> {
  @override
  Widget build(BuildContext context) {
    final reservasAsync = ref.watch(todasLasReservasProvider);

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: reservasAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          ),
          error: (error, _) => _ErrorState(
            message: 'Error al cargar reservas',
            onRetry: () => ref.invalidate(todasLasReservasProvider),
          ),
          data: (reservas) {
            final proximas =
                reservas.where((r) => !r.estaPendiente).toList();
            final pendientes =
                reservas.where((r) => r.estaPendiente).toList();

            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(todasLasReservasProvider);
                await ref.read(todasLasReservasProvider.future);
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
                children: [
                  const Text('Mis Reservas', style: AppTextStyles.pageTitle),
                  const SizedBox(height: 10),
                  const Text(
                    'Administra tus reservas de aulas y eventos proximos',
                    style: AppTextStyles.pageSubtitle,
                  ),
                  const SizedBox(height: 28),
                  if (proximas.isEmpty && pendientes.isEmpty)
                    const _EmptyState(
                        text: 'No tienes reservas registradas.')
                  else ...[
                    if (proximas.isNotEmpty) ...[
                      const _SectionTitle(title: 'Reservas Proximas'),
                      const SizedBox(height: 12),
                      ...proximas.map(
                        (reserva) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ReservaCard(data: reserva),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (pendientes.isNotEmpty) ...[
                      const _SectionTitle(title: 'Pendiente de Aprobacion'),
                      const SizedBox(height: 12),
                      ...pendientes.map(
                        (reserva) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _ReservaCard(data: reserva),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, style: AppTextStyles.cardSubtitle),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.sectionTitle);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.cardSubtitle,
      ),
    );
  }
}

class _ReservaCard extends ConsumerWidget {
  const _ReservaCard({required this.data});
  final ReservaEntity data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPendiente = data.estaPendiente;
    final estadoColor = isPendiente
        ? const Color(0xFFF6B11A)
        : const Color(0xFF24C89A);
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        estadoColor.withValues(alpha: 0.2),
                        estadoColor.withValues(alpha: 0.08),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        data.displayHoraInicio,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: estadoColor,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.horaFin.hour.toString().padLeft(2, '0')}:${data.horaFin.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: estadoColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.displayTitulo,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryDark, height: 1.25),
                          maxLines: 2, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(data.displayAula,
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(color: estadoColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
                  child: Text(data.estado, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: estadoColor)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: [
              _InfoChip(icon: Icons.calendar_today_rounded, label: data.displayFecha),
              const SizedBox(width: 8),
              _InfoChip(icon: Icons.access_time_rounded, label: data.displayHorario),
            ]),
          ),
          const SizedBox(height: 12),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.primaryDark),
              const SizedBox(width: 6),
              Expanded(child: Text(data.displayAula, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryDark), overflow: TextOverflow.ellipsis)),
              if (data.displaySolicitante.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(data.displaySolicitante, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary), overflow: TextOverflow.ellipsis),
                ),
              ],
              if (data.displayGrupo != '-') ...[const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: const Color(0xFF24C89A).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text('Grupo ${data.displayGrupo}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF24C89A))),
                ),
              ],
            ]),
          ),
          if (isPendiente) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelarReserva(context, ref),
                  icon: const Icon(Icons.close, size: 16, color: Colors.red),
                  label: const Text('Cancelar reserva', style: TextStyle(color: Colors.red, fontSize: 13)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                ),
              ),
            ),
          ],
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  void _cancelarReserva(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar reserva'),
        content: Text('Deseas cancelar la reserva "${data.displayTitulo}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
          FilledButton(
            onPressed: () async {
              try {
                await cancelarReserva(ref, data.id);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(todasLasReservasProvider);
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reserva cancelada'), backgroundColor: Colors.green));
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
              }
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Si, cancelar'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primaryDark),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
