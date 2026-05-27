import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/aula_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/widgets/reserva_form_sheet.dart';
import 'package:aulasmart_front_end/features/auth/presentation/providers/user_role_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
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
    if (rol == 'estudiante') {
      final tipo = widget.aula.tipoAula.codigoTipoAula;
      return tipo == '78' || tipo == '79';
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

      ref.invalidate(todasLasReservasProvider);
      await ref.read(todasLasReservasProvider.future);

      ref.invalidate(reservasPorAulaProvider(widget.aula.id));
      ref.invalidate(reservasEventsProvider(widget.aula.id));
      await ref.read(reservasEventsProvider(widget.aula.id).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reserva creada exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } on DioException catch (e) {
      if (!mounted) return;
      final response = e.response;
      if (response == null) {
        _showSnack('Error de conexion. Verifica tu internet.', isError: true);
        return;
      }

      final statusCode = response.statusCode;
      final data = response.data as Map<String, dynamic>?;
      final message = data?['message']?.toString() ?? '';

      switch (statusCode) {
        case 400:
          final detalles = data?['detalle']?.toString();
          if (detalles != null && detalles.contains('LocalDateTime')) {
            _showSnack('Formato de fecha invalido. Use AAAA-MM-DDTHH:mm:ss', isError: true);
          } else {
            final errores = data?['error'] ?? data?['errores'];
            String content;
            if (errores is List) {
              content = errores.map((e) => '\u2022 $e').join('\n');
            } else {
              content = message.isNotEmpty ? message : 'Verifica los campos ingresados.';
            }
            _showDialog('Datos incorrectos', content);
          }
        case 401:
          if (mounted) {
            context.go('/login');
          }
        case 403:
          _showSnack('No tienes permisos para realizar esta accion.', isError: true);
        case 404:
          _showSnack(message.isNotEmpty ? message : 'El aula o la reserva no existe.', isError: true);
        case 409:
          if (message.contains('modificada')) {
            _showDialog('Datos desactualizados', '$message\nDeseas recargar los datos?', actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  _onRefresh();
                },
                child: const Text('Recargar'),
              ),
            ]);
          } else {
            _showDialog('Aula no disponible', message.isNotEmpty ? message : 'El horario seleccionado ya esta ocupado. Elige otro.');
          }
        case 500:
          _showSnack('Error del servidor. Intenta mas tarde.', isError: true);
        default:
          _showSnack('Error ${statusCode ?? ""}: $message', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Error inesperado: $e', isError: true);
      }
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.danger : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ));
  }

  void _showDialog(String title, String content, {List<Widget>? actions}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: actions ??
            [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Aceptar'))],
      ),
    );
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
      floatingActionButton: _puedeReservar
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormularioReserva,
              icon: const Icon(Icons.add),
              label: const Text('Reservar'),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            )
          : null,
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
                                  style: AppTextStyles.pageTitle),
                              const SizedBox(height: 6),
                              Text(
                                  '${aula.bloque.nombre} \u2022 Capacidad: ${aula.capacidad}',
                                  style: AppTextStyles.sectionBody),
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
                                    AppColors.warning.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(20)),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined,
                                    size: 14, color: AppColors.warning),
                                const SizedBox(width: 4),
                                Text('Requiere autorizacion',
                                    style: AppTextStyles.smallLabel.copyWith(
                                            color: AppColors.warning,
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
                      calendarStyle: CalendarStyle(
                        markerDecoration: BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
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
                                style: AppTextStyles.sectionBody)),
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
                  Text('-', style: TextStyle(color: AppColors.neutral)),
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
                      style: AppTextStyles.cardSubtitle),
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
                style: AppTextStyles.tinyLabel.copyWith(color: AppColors.neutral)),
          ),
        ],
      ),
    );
  }
}
