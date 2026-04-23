import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class ReservasView extends StatelessWidget {
  const ReservasView({super.key});

  @override
  Widget build(BuildContext context) {
    const proximas = <_ReservaCardData>[
      _ReservaCardData(
        titulo: 'Clase de Fisica 101',
        estado: 'Confirmado',
        aula: 'Aula Magin A-101',
        fecha: 'martes, 31 de marzo de 2025',
        horario: '09:00 - 11:00',
        asistentes: '85 asistentes',
        descripcion: 'Clase magistral sobre fundamentos de Mecanica Cuantica',
        estadoColor: Color(0xFF24C89A),
      ),
      _ReservaCardData(
        titulo: 'Presentacion de Proyecto de Ingenieria',
        estado: 'Confirmado',
        aula: 'Sala de Conferencias B-301 Edificio Administrativo',
        fecha: 'jueves, 2 de abril de 2025',
        horario: '14:00 - 16:00',
        asistentes: '45 asistentes',
        descripcion: 'Presentaciones de proyectos de ultimo ano de estudiantes de Ingenieria',
        estadoColor: Color(0xFF24C89A),
      ),
    ];

    const pendientes = <_ReservaCardData>[
      _ReservaCardData(
        titulo: 'Sesion de Laboratorio de Quimica',
        estado: 'Pendiente',
        aula: 'Laboratorio B-205 - Edificio de Ciencias',
        fecha: 'sabado, 4 de abril de 2025',
        horario: '10:00 - 12:00',
        asistentes: '30 asistentes',
        descripcion: 'Trabajo practico de laboratorio sobre experimentos de quimica organica',
        estadoColor: Color(0xFFF6B11A),
      ),
    ];

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mis Reservas',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 33,
                  fontWeight: FontWeight.w800,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Administra tus reservas de aulas y eventos proximos',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 28),
              const _SectionTitle(title: 'Reservas Proximas'),
              const SizedBox(height: 12),
              ...proximas.map(
                (reserva) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _ReservaCard(data: reserva),
                ),
              ),
              const SizedBox(height: 10),
              const _SectionTitle(title: 'Pendiente de Aprobacion'),
              const SizedBox(height: 12),
              ...pendientes.map((reserva) => _ReservaCard(data: reserva)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  const _ReservaCard({required this.data});

  final _ReservaCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x28111118),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  data.titulo,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: data.estadoColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  data.estado,
                  style: const TextStyle(
                    color: Colors.black , 
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _CardIconButton(icon: Icons.edit_square),
              const SizedBox(width: 6),
              _CardIconButton(icon: Icons.delete_outline, isDanger: true),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _InfoBlock(label: data.aula),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: _InfoBlock(label: data.fecha),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, color: AppColors.primaryDark, size: 14),
                    const SizedBox(width: 4),
                    Flexible(child: _InlineText(text: data.horario)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.group_outlined, color: AppColors.primaryDark, size: 14),
                    const SizedBox(width: 4),
                    Flexible(child: _InlineText(text: data.asistentes)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE2E5F4),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              data.descripcion,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        height: 1.25,
      ),
    );
  }
}

class _InlineText extends StatelessWidget {
  const _InlineText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _CardIconButton extends StatelessWidget {
  const _CardIconButton({required this.icon, this.isDanger = false});

  final IconData icon;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: isDanger ? const Color(0x1AFB2C36) : const Color(0x1A5E66F2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: 14,
        color: isDanger ? const Color(0xFFFB2C36) : AppColors.primary,
      ),
    );
  }
}

class _ReservaCardData {
  const _ReservaCardData({
    required this.titulo,
    required this.estado,
    required this.aula,
    required this.fecha,
    required this.horario,
    required this.asistentes,
    required this.descripcion,
    required this.estadoColor,
  });

  final String titulo;
  final String estado;
  final String aula;
  final String fecha;
  final String horario;
  final String asistentes;
  final String descripcion;
  final Color estadoColor;
}
