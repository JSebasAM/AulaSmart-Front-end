import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/themes/app_styles.dart';

class AdminReservasScreen extends ConsumerWidget {
  const AdminReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(reservasPendientesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reservasPendientesProvider);
          await ref.read(reservasPendientesProvider.future);
        },
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: 80,
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
                      shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'Reservas',
                        style: AppTextStyles.pageTitle.copyWith(color: Colors.white, letterSpacing: -0.02),
                      ),
                    ),
                    AppGaps.hSm,
                    Container(width: 24, height: 2, decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: AppShapes.circular20)),
                    AppGaps.hXs,
                    Text('Solicitudes y turnos', style: AppTextStyles.pageSubtitle.copyWith(height: 1.5)),
                  ],
                ),
              ),
            ),
          ),
          pendientesAsync.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Error al cargar reservas pendientes', style: AppTextStyles.sectionBody),
                  AppGaps.hSm,
                  ElevatedButton(
                    onPressed: () => ref.invalidate(reservasPendientesProvider),
                    child: const Text('Reintentar'),
                  ),
                ]),
              ),
            ),
            data: (pendientes) {
              if (pendientes.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                      AppGaps.hLg,
                      const Text('No hay reservas pendientes', style: AppTextStyles.sectionTitle),
                    ]),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _PendienteCard(reserva: pendientes[index]),
                  childCount: pendientes.length,
                ),
              );
            },
          ),
        ],
      ),
      ),
    );
  }
}

class _PendienteCard extends ConsumerWidget {
  final ReservaEntity reserva;
  const _PendienteCard({required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.circular24,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 10), spreadRadius: -3,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 4), spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: AppColors.warning)),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: AppShapes.circular16,
                        ),
                        alignment: Alignment.center,
                        child: const Text('P', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.warning)),
                      ),
                      AppGaps.wMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reserva.displayTitulo, style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                            AppGaps.hXs2,
                            Text(reserva.displayAula, style: AppTextStyles.cardSubtitle),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.12),
                          borderRadius: AppShapes.circular20,
                        ),
                        child: const Text('PENDIENTE', style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 12)),
                      ),
                    ],
                  ),
                  AppGaps.hMd,
                  _InfoRow(icon: Icons.person_outline, label: 'Solicitante', value: reserva.displaySolicitante),
                  AppGaps.hXs,
                  _InfoRow(icon: Icons.access_time, label: 'Horario', value: '${reserva.displayFecha}  ${reserva.displayHorario}'),
                  if (reserva.displayPrograma != '-') ...[
                    AppGaps.hXs,
                    _InfoRow(icon: Icons.school, label: 'Programa', value: reserva.displayPrograma),
                  ],
                  if (reserva.displayGrupo != '-') ...[
                    AppGaps.hXs,
                    _InfoRow(icon: Icons.group, label: 'Grupo', value: reserva.displayGrupo),
                  ],
                  AppGaps.hMd,
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _rechazar(context, ref),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Rechazar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.danger,
                            side: const BorderSide(color: AppColors.danger),
                            shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
                          ),
                        ),
                      ),
                      AppGaps.wMd,
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => _confirmar(context, ref),
                          icon: const Icon(Icons.check, size: 18),
                          label: const Text('Confirmar'),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.success,
                            shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmar(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(confirmarReservaProvider);
      await useCase.call(reserva.id);
      ref.invalidate(reservasPendientesProvider);
      ref.invalidate(todasLasReservasProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva confirmada'), backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }

  Future<void> _rechazar(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(rechazarReservaProvider);
      await useCase.call(reserva.id);
      ref.invalidate(reservasPendientesProvider);
      ref.invalidate(todasLasReservasProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reserva rechazada'), backgroundColor: AppColors.warning),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.danger),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.neutral),
        AppGaps.wXs,
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.neutral)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
      ],
    );
  }
}
