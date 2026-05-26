import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';

class MisIncidenciasScreen extends ConsumerWidget {
  const MisIncidenciasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todas = ref.watch(todasLasIncidenciasProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Incidencias', style: TextStyle(fontWeight: FontWeight.w700)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: todas.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Error al cargar'), const SizedBox(height: 8),
          ElevatedButton(onPressed: () => ref.invalidate(todasLasIncidenciasProvider), child: const Text('Reintentar')),
        ])),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('No has reportado incidencias', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => context.push('/incidencias/create'),
                  icon: const Icon(Icons.add),
                  label: const Text('Reportar Incidencia'),
                ),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: () async { ref.invalidate(todasLasIncidenciasProvider); await ref.read(todasLasIncidenciasProvider.future); },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _IncidenciaCard(incidencia: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _IncidenciaCard extends StatelessWidget {
  final IncidenciaEntity incidencia;
  const _IncidenciaCard({required this.incidencia});

  Color _chipBg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Colors.red.shade100, TipoIncidencia.SOFTWARE => Colors.blue.shade100, TipoIncidencia.INFRAESTRUCTURA => Colors.amber.shade100, TipoIncidencia.OTRO => Colors.grey.shade300, };
  Color _chipFg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Colors.red.shade800, TipoIncidencia.SOFTWARE => Colors.blue.shade800, TipoIncidencia.INFRAESTRUCTURA => Colors.orange.shade800, TipoIncidencia.OTRO => Colors.grey.shade700, };
  IconData _tipoIcon(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Icons.computer, TipoIncidencia.SOFTWARE => Icons.code, TipoIncidencia.INFRAESTRUCTURA => Icons.account_balance, TipoIncidencia.OTRO => Icons.help_outline, };
  Color? _estadoBg(EstadoIncidencia e) => switch (e) { EstadoIncidencia.PENDIENTE => Colors.orange.shade100, EstadoIncidencia.REVISADA => Colors.blue.shade100, EstadoIncidencia.CERRADA => Colors.green.shade100, };

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: () => context.push('/incidencias/${incidencia.id}'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Chip(visualDensity: VisualDensity.compact, label: Text(incidencia.displayTipo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _chipFg(incidencia.tipoIncidencia))), backgroundColor: _chipBg(incidencia.tipoIncidencia), avatar: Icon(_tipoIcon(incidencia.tipoIncidencia), size: 16, color: _chipFg(incidencia.tipoIncidencia))),
              const Spacer(),
              Chip(visualDensity: VisualDensity.compact, label: Text(incidencia.displayEstado, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)), backgroundColor: _estadoBg(incidencia.estado)),
            ]),
            const SizedBox(height: 8),
            Text('Aula ${incidencia.codigoAula}', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(incidencia.descripcionBreve, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Row(children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey.shade500),
              const SizedBox(width: 4),
              Text(DateFormat('dd/MM/yyyy').format(incidencia.fechaReporte), style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              if (incidencia.urlImagen != null && incidencia.urlImagen!.isNotEmpty) ...[const Spacer(), Icon(Icons.image, size: 14, color: Colors.blue)],
            ]),
          ]),
        ),
      ),
    );
  }
}
