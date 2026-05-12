import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import '../../../../models/reserva.dart';
import 'package:table_calendar/table_calendar.dart';

class AulaDetailScreen extends ConsumerStatefulWidget {
  final AulaEntity aula;
  const AulaDetailScreen({super.key, required this.aula});

  @override
  ConsumerState<AulaDetailScreen> createState() => _AulaDetailScreenState();
}

class _AulaDetailScreenState extends ConsumerState<AulaDetailScreen> {
  late DateTime _selectedDate;
  late List<DateTime> _dateOptions;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
    _dateOptions = List.generate(14, (i) => DateTime.now().add(Duration(days: i)));
  }

  Future<void> _onRefresh() async {
    // Force provider to refresh
    // Invalidate providers then await the fresh future
    ref.invalidate(reservasPorAulaProvider(widget.aula.id));
    ref.invalidate(reservasEventsProvider(widget.aula.id));
    await ref.read(reservasPorAulaProvider(widget.aula.id).future);
  }
  // grouping moved to provider (uses compute/isolate)

  @override
  Widget build(BuildContext context) {
    final aula = widget.aula;
    final reservasAsync = ref.watch(reservasPorAulaProvider(aula.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(aula.nombreAula),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: reservasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error cargando reservas: $e')),
        data: (reservas) {
          final eventsAsync = ref.watch(reservasEventsProvider(aula.id));
          return eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => Center(child: Text('Error agrupando reservas: $e')),
            data: (eventsMapJson) {
              // Convert eventsMapJson keys back to DateTime keyed map for the calendar
              final eventsMap = <DateTime, List<Reserva>>{};
              eventsMapJson.forEach((k, list) {
                final parts = k.split('-');
                if (parts.length != 3) return;
                final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
                eventsMap[dt] = list.map((e) => Reserva.fromJson(Map<String, dynamic>.from(e))).toList();
              });

              // Reservations for the selected date
              final selected = eventsMap[DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)] ?? [];
              selected.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Small header row with basic info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(aula.nombreAula, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('${aula.bloque.nombre} • Capacidad: ${aula.capacidad}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                          child: Text('Disponible', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.green, fontWeight: FontWeight.bold)),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Monthly calendar with event markers (uses precomputed eventsMap)
                    TableCalendar<Reserva>(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _selectedDate,
                      selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                      ),
                      eventLoader: (day) => eventsMap[DateTime(day.year, day.month, day.day)] ?? [],
                      headerStyle: HeaderStyle(formatButtonVisible: false, titleCentered: true),
                    ),

                    const SizedBox(height: 16),

                    // Reservations list for selected date
                    if (selected.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(child: Text('No hay reservas para esta fecha', style: Theme.of(context).textTheme.bodyLarge)),
                      )
                    else ...selected.map((r) => _ReservaExpansion(reserva: r)).toList(),

                    const SizedBox(height: 24),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _weekdayLabel(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mie';
      case DateTime.thursday:
        return 'Jue';
      case DateTime.friday:
        return 'Vie';
      case DateTime.saturday:
        return 'Sab';
      case DateTime.sunday:
        return 'Dom';
      default:
        return '';
    }
  }
}

class _ReservaCard extends StatelessWidget {
  final Reserva reserva;
  const _ReservaCard({required this.reserva});

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

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(reserva.estado);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Time block
            Container(
              width: 72,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${reserva.horaInicio.hour.toString().padLeft(2,'0')}:${reserva.horaInicio.minute.toString().padLeft(2,'0')}", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('-', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Text("${reserva.horaFin.hour.toString().padLeft(2,'0')}:${reserva.horaFin.minute.toString().padLeft(2,'0')}", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(reserva.titulo ?? reserva.descripcion ?? 'Reserva', style: TextStyle(fontWeight: FontWeight.bold))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(reserva.estado, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Responsable: ${reserva.codigoPrograma} • ${reserva.grupo}'),
                  const SizedBox(height: 6),
                  Text('Solicitante: ${reserva.rolSolicitante} • ID ${reserva.idSolicitante}'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReservaExpansion extends StatelessWidget {
  final Reserva reserva;
  const _ReservaExpansion({required this.reserva});

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

  @override
  Widget build(BuildContext context) {
    final color = _estadoColor(reserva.estado);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        childrenPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${reserva.horaInicio.hour.toString().padLeft(2,'0')}:${reserva.horaInicio.minute.toString().padLeft(2,'0')}", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('-', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text("${reserva.horaFin.hour.toString().padLeft(2,'0')}:${reserva.horaFin.minute.toString().padLeft(2,'0')}", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reserva.tituloApi?.isNotEmpty == true ? reserva.tituloApi! : reserva.descripcion, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text('${reserva.codigoPrograma} • Grupo ${reserva.grupo}', style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(reserva.estado, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text("Responsable: ${reserva.nombreUsuarioResponsable ?? 'N/A'}")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text('Solicitante: ${reserva.rolSolicitante} • ID ${reserva.idSolicitante}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.source_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text("Origen: ${reserva.origen ?? 'N/A'}")),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('ID: ${reserva.id}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
