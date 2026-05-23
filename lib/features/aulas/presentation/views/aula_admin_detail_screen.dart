import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import '../../../reservas/presentation/providers/reservas_provider.dart';
import '../../../reservas/domain/entities/reserva_entity.dart';

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
    final theme = Theme.of(context);

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
            _buildInfoCard(theme),
            const SizedBox(height: 24),
            _buildDatePicker(theme),
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

  Widget _buildInfoCard(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final aula = widget.aula;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
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
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Código: ${aula.codigoAula}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              const Spacer(),
              if (aula.requiereAutorizacion)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.shield_outlined, size: 14, color: Colors.orange[700]),
                      const SizedBox(width: 4),
                      Text('Requiere Auth',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.orange[700],
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
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.business_rounded, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text(aula.bloque.nombre,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
              const SizedBox(width: 16),
              Icon(Icons.people_alt_rounded, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Text('${aula.capacidad} asientos',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  )),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              aula.tipoAula.nombre.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker(ThemeData theme) {
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
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Text(
              '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Icon(Icons.arrow_drop_down, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildReservasList(List<ReservaEntity> reservas) {
    final theme = Theme.of(context);
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
              Icon(Icons.event_busy_rounded, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 12),
              Text(
                'No hay reservas para esta fecha',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
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
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
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
        return Colors.green;
      case 'pendiente':
        return Colors.orange;
      case 'rechazada':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _estadoColor(reserva.estado);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
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
                const Text('-', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (reserva.nombreUsuarioResponsable != null)
                  Text(
                    reserva.nombreUsuarioResponsable!,
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                const SizedBox(height: 2),
                Text(
                  '${reserva.codigoPrograma} · Grupo ${reserva.grupo}',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
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
