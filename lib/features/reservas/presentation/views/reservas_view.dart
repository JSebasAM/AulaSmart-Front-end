import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/core/themes/app_styles.dart';
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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: reservasAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, _) => _ErrorState(
          message: 'Error al cargar reservas',
          onRetry: () => ref.invalidate(todasLasReservasProvider),
        ),
        data: (reservas) {
          final proximas = reservas.where((r) => !r.estaPendiente).toList();
          final pendientes = reservas.where((r) => r.estaPendiente).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(todasLasReservasProvider);
              await ref.read(todasLasReservasProvider.future);
            },
            child: CustomScrollView(
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
                              'Reservas',
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
                            'Administra tus reservas',
                            style: AppTextStyles.pageSubtitle.copyWith(
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (proximas.isEmpty && pendientes.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(text: 'No tienes reservas registradas.'),
                  )
                else ...[
                  if (proximas.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Text('Historial de Reservas',
                            style: AppTextStyles.sectionTitle),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ReservaCard(data: proximas[index]),
                          ),
                          childCount: proximas.length,
                        ),
                      ),
                    ),
                  ],
                  if (pendientes.isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                        child: Text('Pendiente de Aprobación',
                            style: AppTextStyles.sectionTitle),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _ReservaCard(data: pendientes[index]),
                          ),
                          childCount: pendientes.length,
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 32)),
                ],
              ],
            ),
          );
        },
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
          Icon(Icons.wifi_off_outlined, size: 64, color: AppColors.danger),
          AppGaps.hLg,
          Text(
            'No pudimos cargar las reservas',
            style: AppTextStyles.sectionTitle,
            textAlign: TextAlign.center,
          ),
          AppGaps.hSm,
          Text(
            message,
            style: AppTextStyles.sectionBody,
            textAlign: TextAlign.center,
          ),
          AppGaps.hXxl,
          FilledButton.tonalIcon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy_outlined, size: 64, color: AppColors.neutral),
          AppGaps.hLg,
          Text(
            text,
            style: AppTextStyles.sectionBody.copyWith(color: AppColors.neutral),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ReservaCard extends ConsumerWidget {
  const _ReservaCard({required this.data});
  final ReservaEntity data;

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'pendiente':
        return AppColors.warning;
      case 'cancelada':
        return AppColors.danger;
      default:
        return AppColors.neutral;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPendiente = data.estaPendiente;
    final estadoColor = _estadoColor(data.estado);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular16,
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
          Positioned(
            left: 0, top: 0, bottom: 0,
            child: Container(width: 4, color: estadoColor),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
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
                        borderRadius: AppShapes.circular16,
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
                          AppGaps.hXs2,
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
                    AppGaps.wMd,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.displayTitulo,
                            style: AppTextStyles.cardTitle.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          AppGaps.hXs,
                          Text(
                            data.displayAula,
                            style: AppTextStyles.sectionBody.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppGaps.wSm,
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: estadoColor.withValues(alpha: 0.12),
                        borderRadius: AppShapes.circular20,
                      ),
                      child: Text(
                        data.estado,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: estadoColor,
                        ),
                      ),
                    ),
                  ],
                ),
                AppGaps.hMd,
                Row(children: [
                  _InfoChip(icon: Icons.calendar_today_rounded, label: data.displayFecha),
                  AppGaps.wSm,
                  _InfoChip(icon: Icons.access_time_rounded, label: data.displayHorario),
                ]),
                AppGaps.hMd,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: AppShapes.circular12,
                  ),
                  child: Row(children: [
                    const Icon(Icons.meeting_room_outlined, size: 16, color: AppColors.primaryDark),
                    AppGaps.wSm,
                    Expanded(
                      child: Text(
                        data.displayAula,
                        style: AppTextStyles.smallLabel.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (data.displaySolicitante.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: AppShapes.circular8,
                        ),
                        child: Text(
                          data.displaySolicitante,
                          style: AppTextStyles.tinyLabel.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (data.displayGrupo != '-') ...[
                      AppGaps.wSm,
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: AppShapes.circular8,
                        ),
                        child: Text(
                          'Grupo ${data.displayGrupo}',
                          style: AppTextStyles.tinyLabel.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ]),
                ),
                if (isPendiente) ...[
                  AppGaps.hMd,
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelarReserva(context, ref),
                      icon: const Icon(Icons.close, size: 16, color: AppColors.danger),
                      label: const Text('Cancelar reserva',
                          style: TextStyle(color: AppColors.danger, fontSize: 13)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.danger),
                        shape: RoundedRectangleBorder(
                            borderRadius: AppShapes.circular12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelarReserva(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppShapes.circular16),
        title: const Text('Cancelar reserva'),
        content: Text('¿Deseas cancelar la reserva "${data.displayTitulo}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('No'),
          ),
          FilledButton(
            onPressed: () async {
              try {
                await cancelarReserva(ref, data.id);
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(todasLasReservasProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reserva cancelada'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Sí, cancelar'),
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
          borderRadius: AppShapes.circular8,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.primaryDark),
            AppGaps.wSm,
            Flexible(
              child: Text(
                label,
                style: AppTextStyles.smallLabel.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
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
