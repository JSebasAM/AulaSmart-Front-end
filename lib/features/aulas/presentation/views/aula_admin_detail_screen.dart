import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/aula_entity.dart';
import '../../../reservas/presentation/providers/reservas_provider.dart';
import '../../../reservas/domain/entities/reserva_entity.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';
import '../../../../themes/app_styles.dart';

class AulaAdminDetailScreen extends ConsumerStatefulWidget {
  final AulaEntity aula;

  const AulaAdminDetailScreen({super.key, required this.aula});

  @override
  ConsumerState<AulaAdminDetailScreen> createState() => _AulaAdminDetailScreenState();
}

class _AulaAdminDetailScreenState extends ConsumerState<AulaAdminDetailScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(reservasPorAulaProvider(widget.aula.id));
    await ref.read(reservasPorAulaProvider(widget.aula.id).future);
  }

  @override
  Widget build(BuildContext context) {
    final reservasAsync = ref.watch(reservasPorAulaProvider(widget.aula.id));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
          child: Text(
            widget.aula.nombreAula,
            style: AppTextStyles.pageTitle.copyWith(color: Colors.white, fontSize: 22),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: reservasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildError(e),
        data: (reservas) => RefreshIndicator(
          onRefresh: _onRefresh,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
              _buildInfoCard(),
              AppGaps.hXxl,
              _buildDatePicker(),
              AppGaps.hLg,
              _buildReservasList(reservas),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final aula = widget.aula;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular16,
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
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: AppColors.primary)),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, right: 16, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            aula.nombreAula,
                            style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w800),
                          ),
                          AppGaps.hXs,
                          Text(
                            '${aula.bloque.nombre} • Capacidad: ${aula.capacidad}',
                            style: AppTextStyles.sectionBody.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                AppGaps.hMd,
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _MiniBadge(icon: Icons.domain, label: aula.bloque.nombre),
                    _MiniBadge(icon: Icons.people_alt_rounded, label: '${aula.capacidad} asientos'),
                    _MiniBadge(icon: Icons.category_outlined, label: aula.tipoAula.nombre),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) {
          setState(() => _selectedDate = picked);
        }
      },
      borderRadius: AppShapes.circular12,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: AppShapes.circular12,
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.primary),
            AppGaps.wMd,
            Text(
              DateFormat('EEEE d \'de\' MMMM, yyyy', 'es').format(_selectedDate),
              style: AppTextStyles.cardTitle,
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildReservasList(List<ReservaEntity> reservas) {
    final diaReservas = reservas.where((r) {
      return r.horaInicio.year == _selectedDate.year &&
          r.horaInicio.month == _selectedDate.month &&
          r.horaInicio.day == _selectedDate.day;
    }).toList();

    diaReservas.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

    if (diaReservas.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 48, color: AppColors.neutral),
              AppGaps.hMd,
              Text('No hay reservas para esta fecha', style: AppTextStyles.sectionBody.copyWith(color: AppColors.neutral)),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${diaReservas.length} reserva${diaReservas.length == 1 ? '' : 's'}',
          style: AppTextStyles.sectionTitle,
        ),
        AppGaps.hMd,
        ...diaReservas.map((r) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _ReservaTile(reserva: r),
        )),
      ],
    );
  }

  Widget _buildError(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.wifi_off_outlined, size: 64, color: AppColors.danger),
            AppGaps.hLg,
            const Text('Error al cargar reservas', style: AppTextStyles.sectionTitle),
            AppGaps.hSm,
            Text(error.toString(), style: AppTextStyles.sectionBody, textAlign: TextAlign.center),
            AppGaps.hXxl,
            FilledButton.tonalIcon(
              onPressed: _onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.8),
        borderRadius: AppShapes.circular8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textPrimary),
          AppGaps.wXs,
          Text(
            label,
            style: AppTextStyles.tinyLabel.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _ReservaTile extends StatelessWidget {
  final ReservaEntity reserva;

  const _ReservaTile({required this.reserva});

  Color _estadoColor(String estado) {
    switch (estado.toLowerCase()) {
      case 'confirmada':
        return AppColors.success;
      case 'pendiente':
        return AppColors.warning;
      case 'rechazada':
        return AppColors.danger;
      default:
        return AppColors.neutral;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(reserva.estado);

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular16,
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
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: color)),
          ExpansionTile(
            tilePadding: const EdgeInsets.only(left: 20, right: 16, top: 8, bottom: 8),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 16, 16),
            shape: const RoundedRectangleBorder(),
            collapsedShape: const RoundedRectangleBorder(),
            collapsedBackgroundColor: Colors.transparent,
            backgroundColor: Colors.transparent,
            iconColor: AppColors.textSecondary,
            collapsedIconColor: AppColors.textSecondary,
            title: Row(
              children: [
                Container(
                  width: 64,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: AppDecorations.statusDot(color: color),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        reserva.displayHoraInicio,
                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
                      ),
                      AppGaps.hXs,
                      Text('-', style: TextStyle(color: AppColors.neutral, fontSize: 11)),
                      AppGaps.hXs,
                      Text(
                        '${reserva.horaFin.hour.toString().padLeft(2, '0')}:${reserva.horaFin.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 13),
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
                        reserva.displayTitulo,
                        style: AppTextStyles.cardTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      AppGaps.hSm,
                      Text(
                        '${reserva.displayPrograma} • Grupo ${reserva.displayGrupo}',
                        style: AppTextStyles.cardSubtitle,
                      ),
                    ],
                  ),
                ),
                AppGaps.wSm,
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: AppShapes.circular20,
                  ),
                  child: Text(
                    reserva.estado,
                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
                  ),
                ),
              ],
            ),
            children: [
              const Divider(height: 1),
              AppGaps.hMd,
              _DetailRow(
                icon: Icons.person_outline,
                label: 'Responsable: ${reserva.displaySolicitante}',
              ),
              AppGaps.hSm,
              _DetailRow(
                icon: Icons.badge_outlined,
                label: 'Solicitante: ${reserva.rolSolicitante} • ID ${reserva.idSolicitante}',
              ),
              AppGaps.hSm,
              _DetailRow(
                icon: Icons.source_outlined,
                label: 'Origen: ${reserva.displayOrigen}',
              ),
              AppGaps.hSm,
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'ID: ${reserva.id}',
                  style: AppTextStyles.tinyLabel.copyWith(color: AppColors.neutral),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _DetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        AppGaps.wSm,
        Expanded(
          child: Text(label, style: AppTextStyles.sectionBody),
        ),
      ],
    );
  }
}
