import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import '../../../reservas/presentation/providers/reservas_provider.dart';
import '../../../reservas/domain/entities/reserva_entity.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';

class AulaAdminDetailScreen extends ConsumerStatefulWidget {
  final AulaEntity aula;

  const AulaAdminDetailScreen({super.key, required this.aula});

  @override
  ConsumerState<AulaAdminDetailScreen> createState() =>
      _AulaAdminDetailScreenState();
}

class _AulaAdminDetailScreenState
    extends ConsumerState<AulaAdminDetailScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final reservasAsync = ref.watch(reservasPorAulaProvider(widget.aula.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.aula.nombreAula),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildDatePicker(),
            const SizedBox(height: 16),
            reservasAsync.when(
              data: (reservas) => _buildReservasList(reservas),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('Error al cargar reservas: $e'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    final aula = widget.aula;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.pageCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Código: ${aula.codigoAula}',
                  style: AppTextStyles.smallLabel.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Spacer(),
              if (aula.requiereAutorizacion)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: AppColors.warning),
                      const SizedBox(width: 4),
                      Text('Requiere Auth',
                          style: AppTextStyles.smallLabel.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            aula.nombreAula,
            style: AppTextStyles.pageTitle,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(aula.bloque.nombre,
                    style: AppTextStyles.cardSubtitle),
              ),
              const SizedBox(width: 16),
              Icon(Icons.people_alt_rounded, size: 16, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Flexible(
                child: Text('${aula.capacidad} asientos',
                    style: AppTextStyles.cardSubtitle),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              aula.tipoAula.nombre.toUpperCase(),
              style: AppTextStyles.smallLabel.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
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
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              Icon(Icons.event_busy_rounded, size: 48, color: AppColors.neutral),
              const SizedBox(height: 12),
              Text(
                'No hay reservas para esta fecha',
                style: AppTextStyles.sectionBody,
              ),
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
        const SizedBox(height: 12),
        ...diaReservas.map((r) => _ReservaItem(reserva: r)),
      ],
    );
  }
}

class _ReservaItem extends StatelessWidget {
  final ReservaEntity reserva;

  const _ReservaItem({required this.reserva});

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

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(reserva.estado);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(_formatTime(reserva.horaInicio),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                Text('-', style: TextStyle(color: AppColors.neutral, fontSize: 12)),
                Text(_formatTime(reserva.horaFin),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reserva.tituloApi ?? 'Reserva',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: 4),
                if (reserva.nombreUsuarioResponsable != null)
                  Text(
                    reserva.nombreUsuarioResponsable!,
                    style: AppTextStyles.cardSubtitle,
                  ),
                const SizedBox(height: 2),
                Text(
                  '${reserva.codigoPrograma} · Grupo ${reserva.grupo}',
                  style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.neutral),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              reserva.estado,
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
