import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/features/reservas/domain/entities/reserva_entity.dart';
import 'package:aulasmart_front_end/features/reservas/presentation/providers/reservas_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';

class AdminReservasScreen extends ConsumerWidget {
  const AdminReservasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(reservasPendientesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reservas Pendientes',
            style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: pendientesAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Error al cargar reservas pendientes'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(reservasPendientesProvider),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
        data: (pendientes) {
          if (pendientes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle_outline,
                      size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No hay reservas pendientes',
                      style: TextStyle(fontSize: 16)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(reservasPendientesProvider);
              await ref.read(reservasPendientesProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendientes.length,
              itemBuilder: (context, index) {
                return _PendienteCard(reserva: pendientes[index]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _PendienteCard extends ConsumerWidget {
  final ReservaEntity reserva;
  const _PendienteCard({required this.reserva});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('P',
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reserva.displayTitulo,
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(reserva.displayAula,
                          style: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text('PENDIENTE',
                      style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w700,
                          fontSize: 12)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _InfoRow(
                icon: Icons.person_outline,
                label: 'Solicitante',
                value: reserva.displaySolicitante),
            const SizedBox(height: 4),
            _InfoRow(
                icon: Icons.access_time,
                label: 'Horario',
                value:
                    '${reserva.displayFecha}  ${reserva.displayHorario}'),
            if (reserva.displayPrograma != '-') ...[
              const SizedBox(height: 4),
              _InfoRow(
                  icon: Icons.school,
                  label: 'Programa',
                  value: reserva.displayPrograma),
            ],
            if (reserva.displayGrupo != '-') ...[
              const SizedBox(height: 4),
              _InfoRow(
                  icon: Icons.group,
                  label: 'Grupo',
                  value: reserva.displayGrupo),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _rechazar(context, ref),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _confirmar(context, ref),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Confirmar'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmar(
      BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(confirmarReservaProvider);
      await useCase.call(reserva.id);
      ref.invalidate(reservasPendientesProvider);
      ref.invalidate(todasLasReservasProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reserva confirmada'),
              backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _rechazar(BuildContext context, WidgetRef ref) async {
    try {
      final useCase = ref.read(rechazarReservaProvider);
      await useCase.call(reserva.id);
      ref.invalidate(reservasPendientesProvider);
      ref.invalidate(todasLasReservasProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reserva rechazada'),
              backgroundColor: Colors.orange),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red),
        );
      }
    }
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 6),
        Text('$label: ',
            style: const TextStyle(
                fontSize: 13, color: Colors.grey)),
        Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13))),
      ],
    );
  }
}
