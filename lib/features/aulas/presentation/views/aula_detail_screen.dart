import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/aula_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/widgets/reserva_form_sheet.dart';
import 'package:aulasmart_front_end/features/auth/presentation/providers/user_role_provider.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/core/themes/app_styles.dart';
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppColors.primaryGradient.createShader(bounds),
          child: Text(
            aula.nombreAula,
            style: AppTextStyles.pageTitle.copyWith(
              color: Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: _puedeReservar
          ? FloatingActionButton.extended(
              onPressed: _mostrarFormularioReserva,
              icon: const Icon(Icons.add),
              label: const Text('Reservar'),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            )
          : null,
      body: reservasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => _buildError(e),
        data: (reservas) {
          final eventsAsync = ref.watch(reservasEventsProvider(aula.id));
          return eventsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, st) => _buildError(e),
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

              final selected = eventsMap[
                      DateTime(_selectedDate.year, _selectedDate.month,
                          _selectedDate.day)] ??
                  [];
              selected.sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  children: [
                    _buildAulaInfo(aula),
                    AppGaps.hLg,
                    TableCalendar<ReservaEntity>(
                      firstDay: DateTime.now().subtract(const Duration(days: 365)),
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
                        todayDecoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        selectedDecoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        todayTextStyle: const TextStyle(
                            color: AppColors.primary, fontWeight: FontWeight.bold),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: false,
                        titleCentered: true,
                        titleTextStyle: AppTextStyles.sectionTitle,
                      ),
                      eventLoader: (day) =>
                          eventsMap[DateTime(day.year, day.month, day.day)] ?? [],
                    ),
                    AppGaps.hLg,
                    if (selected.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(Icons.event_busy_outlined,
                                  size: 48, color: AppColors.neutral),
                              AppGaps.hMd,
                              Text(
                                'No hay reservas para esta fecha',
                                style: AppTextStyles.sectionBody.copyWith(
                                    color: AppColors.neutral),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...selected.map((r) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ReservaTile(reserva: r),
                      )),
                    AppGaps.hXxl,
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAulaInfo(AulaEntity aula) {
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
            child: Container(width: 4, color: AppColors.primary),
          ),
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
                            style: AppTextStyles.sectionBody.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (aula.requiereAutorizacion)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: AppDecorations.pill(color: AppColors.warning),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield_outlined, size: 14, color: AppColors.warning),
                            AppGaps.wXs,
                            Text('Requiere autorización',
                                style: AppTextStyles.tinyLabel.copyWith(
                                    color: AppColors.warning,
                                    fontWeight: FontWeight.bold)),
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

  Widget _buildError(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            error.toString(),
            style: AppTextStyles.sectionBody,
            textAlign: TextAlign.center,
          ),
          AppGaps.hXxl,
          FilledButton.tonalIcon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.icon, required this.label});
  final IconData icon;
  final String label;

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
            child: Container(width: 4, color: color),
          ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 13,
                        ),
                      ),
                      AppGaps.hXs,
                      Text(
                        '-',
                        style: TextStyle(color: AppColors.neutral, fontSize: 11),
                      ),
                      AppGaps.hXs,
                      Text(
                        '${reserva.horaFin.hour.toString().padLeft(2, '0')}:${reserva.horaFin.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontSize: 13,
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
                        reserva.displayTitulo,
                        style: AppTextStyles.cardTitle.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
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
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
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
  const _DetailRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

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
