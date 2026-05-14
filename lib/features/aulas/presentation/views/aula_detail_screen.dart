import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/widgets/reserva_form_sheet.dart';
import 'package:aulasmart_front_end/features/auth/presentation/providers/user_role_provider.dart';
import 'package:table_calendar/table_calendar.dart';

class AulaDetailScreen extends ConsumerStatefulWidget {
  final AulaEntity aula;
  const AulaDetailScreen({super.key, required this.aula});

  @override
  ConsumerState<AulaDetailScreen> createState() => _AulaDetailScreenState();
}

class _AulaDetailScreenState extends ConsumerState<AulaDetailScreen> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(reservasPorAulaProvider(widget.aula.id));
    ref.invalidate(reservasEventsProvider(widget.aula.id));
    await ref.read(reservasPorAulaProvider(widget.aula.id).future);
  }

  bool get _puedeReservar {
    final rolAsync = ref.read(currentUserRoleProvider);
    final rol = rolAsync.value ?? '';
    if (rol == 'estudiante' && widget.aula.requiereAutorizacion) {
      return false;
    }
    return true;
  }

  Future<void> _mostrarFormularioReserva() async {
    final result = await showModalBottomSheet<ReservaFormData>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ReservaFormSheet(
        aula: widget.aula,
        fechaInicial: _selectedDate,
        puedeReservar: _puedeReservar,
      ),
    );

    if (result == null || !mounted) return;

    try {
      final useCase = ref.read(createReservaProvider);

      String formatDt(DateTime dt) {
        return '${dt.year.toString().padLeft(4, '0')}-'
            '${dt.month.toString().padLeft(2, '0')}-'
            '${dt.day.toString().padLeft(2, '0')}T'
            '${dt.hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')}:00';
      }

      final body = <String, dynamic>{
        'aulaId': widget.aula.id,
        'horaInicio': formatDt(result.fechaHoraInicio),
        'horaFin': formatDt(result.fechaHoraFin),
        'titulo': result.titulo,
      };

      if (result.programa.isNotEmpty) {
        body['codigoPrograma'] = result.programa;
      }
      if (result.grupo.isNotEmpty) {
        body['grupo'] = result.grupo;
      }

      await useCase.call(body);

      ref.invalidate(reservasPorAulaProvider(widget.aula.id));
      ref.invalidate(reservasEventsProvider(widget.aula.id));
      ref.invalidate(todasLasReservasProvider);

      await ref.read(reservasPorAulaProvider(widget.aula.id).future);
      ref.invalidate(reservasEventsProvider(widget.aula.id));
      await ref.read(reservasEventsProvider(widget.aula.id).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final statusCode = e.response?.statusCode;
      String mensaje;
      switch (statusCode) {
        case 409:
          mensaje = 'Conflicto de horario: ya existe una reserva que se solapa en ese horario.';
          break;
        case 400:
          mensaje = 'Datos invalidos. Verifica los campos ingresados.';
          break;
        default:
          mensaje = 'Error al crear reserva: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_puedeReservar) {
            _mostrarFormularioReserva();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'Esta aula requiere autorizacion. Los estudiantes no pueden reservarla directamente.'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Reservar'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: reservasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error cargando reservas: $e')),
        data: (reservas) {
          final eventsAsync = ref.watch(reservasEventsProvider(aula.id));
          return eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) =>
                Center(child: Text('Error agrupando reservas: $e')),
            data: (eventsMapJson) {
              final eventsMap = <DateTime, List<ReservaEntity>>{};
              eventsMapJson.forEach((k, list) {
                final parts = k.split('-');
                if (parts.length != 3) return;
                final dt = DateTime(int.parse(parts[0]),
                    int.parse(parts[1]), int.parse(parts[2]));
                eventsMap[dt] = list
                    .map((e) =>
                        ReservaEntity.fromJson(Map<String, dynamic>.from(e)))
                    .toList();
              });

              final selected =
                  eventsMap[DateTime(_selectedDate.year, _selectedDate.month,
                          _selectedDate.day)] ??
                      [];
              selected
                  .sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(aula.nombreAula,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                          fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(
                                  '${aula.bloque.nombre} \u2022 Capacidad: ${aula.capacidad}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (aula.requiereAutorizacion)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                                color:
                                    Colors.orange.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined,
                                    size: 14, color: Colors.orange[700]),
                                const SizedBox(width: 4),
                                Text('Requiere autorizacion',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TableCalendar<ReservaEntity>(
                      firstDay:
                          DateTime.now().subtract(const Duration(days: 365)),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _selectedDate,
                      selectedDayPredicate: (day) =>
                          isSameDay(day, _selectedDate),
                      onDaySelected: (selectedDay, focusedDay) {
                        setState(() {
                          _selectedDate = selectedDay;
                        });
                      },
                      calendarStyle: const CalendarStyle(
                        markerDecoration: BoxDecoration(
                            color: Colors.blue, shape: BoxShape.circle),
                      ),
                      eventLoader: (day) =>
                          eventsMap[DateTime(
                              day.year, day.month, day.day)] ??
                          [],
                      headerStyle: HeaderStyle(
                          formatButtonVisible: false, titleCentered: true),
                    ),
                    const SizedBox(height: 16),
                    if (selected.isEmpty)
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: 24.0),
                        child: Center(
                            child: Text(
                                'No hay reservas para esta fecha',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge)),
                      )
                    else
                      ...selected
                          .map((r) => _ReservaExpansion(reserva: r))
                          .toList(),
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
}

class _ReservaExpansion extends StatelessWidget {
  final ReservaEntity reserva;
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
        collapsedShape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        childrenPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        title: Row(
          children: [
            Container(
              width: 64,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(reserva.displayHoraInicio,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text('-', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(
                      '${reserva.horaFin.hour.toString().padLeft(2, '0')}:${reserva.horaFin.minute.toString().padLeft(2, '0')}',
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(reserva.displayTitulo,
                      style:
                          const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(
                      '${reserva.displayPrograma} \u2022 Grupo ${reserva.displayGrupo}',
                      style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(reserva.estado,
                  style: TextStyle(
                      color: color, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      "Responsable: ${reserva.displaySolicitante}")),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(
                      'Solicitante: ${reserva.rolSolicitante} \u2022 ID ${reserva.idSolicitante}')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.source_outlined, size: 18),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      Text("Origen: ${reserva.displayOrigen}")),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text('ID: ${reserva.id}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey)),
          ),
        ],
      ),
    );
  }
}
