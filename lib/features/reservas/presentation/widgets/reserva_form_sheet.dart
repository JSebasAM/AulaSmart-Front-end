import 'package:flutter/material.dart';
import 'package:aulasmart_front_end/features/aulas/domain/entities/aula_entity.dart';

class ReservaFormData {
  final DateTime fecha;
  final TimeOfDay horaInicio;
  final TimeOfDay horaFin;
  final String titulo;
  final String grupo;
  final String programa;

  ReservaFormData({
    required this.fecha,
    required this.horaInicio,
    required this.horaFin,
    required this.titulo,
    this.grupo = '',
    this.programa = '',
  });

  DateTime get fechaHoraInicio => DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horaInicio.hour,
        horaInicio.minute,
      );

  DateTime get fechaHoraFin => DateTime(
        fecha.year,
        fecha.month,
        fecha.day,
        horaFin.hour,
        horaFin.minute,
      );
}

class ReservaFormSheet extends StatefulWidget {
  final AulaEntity aula;
  final DateTime fechaInicial;
  final bool puedeReservar;

  const ReservaFormSheet({
    super.key,
    required this.aula,
    required this.fechaInicial,
    required this.puedeReservar,
  });

  @override
  State<ReservaFormSheet> createState() => _ReservaFormSheetState();
}

class _ReservaFormSheetState extends State<ReservaFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _fecha;
  late TimeOfDay _horaInicio;
  late TimeOfDay _horaFin;
  final _tituloController = TextEditingController();
  final _grupoController = TextEditingController();
  final _programaController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fecha = widget.fechaInicial;
    final now = TimeOfDay.now();
    final rounded = TimeOfDay(hour: now.hour, minute: 0);
    _horaInicio = rounded;
    _horaFin = TimeOfDay(
        hour: (rounded.hour + 1) % 24, minute: rounded.minute);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _grupoController.dispose();
    _programaController.dispose();
    super.dispose();
  }

  ReservaFormData get formData => ReservaFormData(
        fecha: _fecha,
        horaInicio: _horaInicio,
        horaFin: _horaFin,
        titulo: _tituloController.text.trim(),
        grupo: _grupoController.text.trim(),
        programa: _programaController.text.trim(),
      );

  bool get _horarioValido {
    final inicio = _horaInicio.hour * 60 + _horaInicio.minute;
    final fin = _horaFin.hour * 60 + _horaFin.minute;
    return fin > inicio;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fecha,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _fecha = picked);
    }
  }

  Future<void> _pickTime(bool isInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isInicio ? _horaInicio : _horaFin,
    );
    if (picked != null) {
      setState(() {
        if (isInicio) {
          _horaInicio = picked;
        } else {
          _horaFin = picked;
        }
      });
    }
  }

  String _formatFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/${fecha.month.toString().padLeft(2, '0')}/${fecha.year}';
  }

  String _formatHora(TimeOfDay hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:${hora.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return _InfoTile(icon: icon, label: label, value: value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(left: 24, right: 24, top: 24, bottom: bottomInset + 24),
      child: Form(
        key: _formKey,
        child: RepaintBoundary(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _DragHandle(),
                const SizedBox(height: 16),
                _AulaHeader(aula: widget.aula),
                if (!widget.puedeReservar) ...[
                  const SizedBox(height: 12),
                  const _WarningBanner(),
                ],
              const SizedBox(height: 20),
              if (widget.aula.requiereAutorizacion)
                _buildInfoRow(
                    Icons.shield_outlined, 'Tipo', 'Requiere autorizacion'),
              _buildInfoRow(Icons.meeting_room_outlined, 'Aula',
                  '${widget.aula.nombreAula} (${widget.aula.codigoAula})'),
              _buildInfoRow(Icons.category_outlined, 'Tipo',
                  widget.aula.tipoAula.nombre),
              const SizedBox(height: 20),
              Text('Fecha',
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              InkWell(
                onTap: widget.puedeReservar ? _pickDate : null,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 10),
                      Text(_formatFecha(_fecha)),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hora inicio',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: widget.puedeReservar
                              ? () => _pickTime(true)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 8),
                                Text(_formatHora(_horaInicio)),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
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
                        Text('Hora fin',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        InkWell(
                          onTap: widget.puedeReservar
                              ? () => _pickTime(false)
                              : null,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 14),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.access_time, size: 18),
                                const SizedBox(width: 8),
                                Text(_formatHora(_horaFin)),
                                const Spacer(),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!_horarioValido) ...[
                const SizedBox(height: 6),
                Text(
                  'La hora de fin debe ser posterior a la de inicio',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 14),
              TextFormField(
                controller: _tituloController,
                enabled: widget.puedeReservar,
                decoration: InputDecoration(
                  labelText: 'Titulo de la reserva',
                  hintText: 'Ej: Clase de Matematicas',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'El titulo es requerido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _programaController,
                      enabled: widget.puedeReservar,
                      decoration: InputDecoration(
                        labelText: 'Programa',
                        hintText: 'Ej: ING-SIS',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _grupoController,
                      enabled: widget.puedeReservar,
                      decoration: InputDecoration(
                        labelText: 'Grupo',
                        hintText: 'Ej: A',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: FilledButton.icon(
                  onPressed: (!widget.puedeReservar ||
                          _isSubmitting ||
                          !_horarioValido)
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pop(formData);
                          }
                        },
                  icon: _isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_outline),
                  label: Text(_isSubmitting
                      ? 'Reservando...'
                      : 'Confirmar Reserva'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

class _DragHandle extends StatelessWidget {
  const _DragHandle();
  @override
  Widget build(BuildContext context) => Center(
        child: Container(
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)),
        ),
      );
}

class _AulaHeader extends StatelessWidget {
  final AulaEntity aula;
  const _AulaHeader({required this.aula});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Reservar ${aula.nombreAula}',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text('${aula.bloque.nombre} \u2022 Capacidad: ${aula.capacidad}',
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
    ]);
  }
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner();
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
        ),
        child: const Row(children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          SizedBox(width: 10),
          Expanded(child: Text('Esta aula requiere autorizacion. Los estudiantes no pueden reservarla directamente.',
              style: TextStyle(color: Color(0xFFE65100), fontSize: 12))),
        ]),
      );
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
        Flexible(child: Text(value)),
      ]);
}
