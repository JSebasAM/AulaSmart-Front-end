import 'package:aulasmart_front_end/models/reserva.dart';
import 'package:aulasmart_front_end/services/reserva_service.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class ReservasView extends StatefulWidget {
  const ReservasView({super.key});

  @override
  State<ReservasView> createState() => _ReservasViewState();
}

class _ReservasViewState extends State<ReservasView> {
  final ReservaService _reservaService = ReservaService();
  late final Future<List<Reserva>> _futureReservas;

  @override
  void initState() {
    super.initState();
    _futureReservas = _reservaService.listarReservas();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: FutureBuilder<List<Reserva>>(
          future: _futureReservas,
          builder: (context, snapshot) {
            final reservas = snapshot.data ?? const <Reserva>[];
            final proximas = reservas.where((reserva) => !reserva.estaPendiente).toList();
            final pendientes = reservas.where((reserva) => reserva.estaPendiente).toList();

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mis Reservas', style: AppTextStyles.pageTitle),
                  const SizedBox(height: 10),
                  const Text(
                    'Administra tus reservas de aulas y eventos proximos',
                    style: AppTextStyles.pageSubtitle,
                  ),
                  const SizedBox(height: 28),
                  const _SectionTitle(title: 'Reservas Proximas'),
                  const SizedBox(height: 12),
                  if (snapshot.connectionState == ConnectionState.waiting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 28),
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (proximas.isEmpty)
                    const _EmptyState(text: 'No hay reservas proximas disponibles.')
                  else
                    ...proximas.map(
                      (reserva) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ReservaCard(data: reserva),
                      ),
                    ),
                  const SizedBox(height: 10),
                  const _SectionTitle(title: 'Pendiente de Aprobacion'),
                  const SizedBox(height: 12),
                  if (pendientes.isEmpty)
                    const _EmptyState(text: 'No hay reservas pendientes.')
                  else
                    ...pendientes.map(
                      (reserva) => Padding(
                        padding: const EdgeInsets.only(bottom: 14),
                        child: _ReservaCard(data: reserva),
                      ),
                    ),
                ],
              ),
            );
          },
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
    return Text(title, style: AppTextStyles.sectionTitle);
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppTextStyles.cardSubtitle,
      ),
    );
  }
}

class _ReservaCard extends StatelessWidget {
  const _ReservaCard({required this.data});

  final Reserva data;

  @override
  Widget build(BuildContext context) {
    final estadoColor = _estadoColor(data.estado);

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
                  style: AppTextStyles.cardTitle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: estadoColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  data.estado,
                  style: AppTextStyles.smallLabel.copyWith(color: Colors.black),
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
                    Flexible(child: _InlineText(text: '${data.asistentes} asistentes')),
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

  Color _estadoColor(String estado) {
    if (estado.toLowerCase() == 'pendiente') {
      return const Color(0xFFF6B11A);
    }

    return const Color(0xFF24C89A);
  }
}

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.cardSubtitle,
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
      style: AppTextStyles.cardSubtitle,
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
