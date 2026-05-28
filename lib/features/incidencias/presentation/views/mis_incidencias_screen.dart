import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';

class MisIncidenciasScreen extends ConsumerStatefulWidget {
  const MisIncidenciasScreen({super.key});

  @override
  ConsumerState<MisIncidenciasScreen> createState() => _MisIncidenciasScreenState();
}

class _MisIncidenciasScreenState extends ConsumerState<MisIncidenciasScreen>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;
  Map<int, EstadoIncidencia> _lastState = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startPolling();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pollingTimer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _refresh();
      _startPolling();
    }
  }

  void _startPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      ref.invalidate(todasLasIncidenciasProvider);
      final nuevas = await ref.read(todasLasIncidenciasProvider.future);
      if (!mounted) return;
      for (final inc in nuevas) {
        final prev = _lastState[inc.id];
        if (prev == EstadoIncidencia.PENDIENTE && inc.esRevisada) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tu incidencia del aula ${inc.codigoAula} tiene una nueva respuesta'),
              backgroundColor: Colors.blue,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 5),
            ),
          );
        }
        _lastState[inc.id] = inc.estado;
      }
    } catch (_) {
      // error silencioso, reintenta en el siguiente ciclo
    }
  }

  @override
  Widget build(BuildContext context) {
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
          ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
        ])),
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('No has reportado incidencias', style: TextStyle(fontSize: 16, color: Colors.grey)),
              ]),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
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
