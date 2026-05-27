import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';

class AdminIncidenciasScreen extends ConsumerStatefulWidget {
  const AdminIncidenciasScreen({super.key});

  @override
  ConsumerState<AdminIncidenciasScreen> createState() => _AdminIncidenciasScreenState();
}

class _AdminIncidenciasScreenState extends ConsumerState<AdminIncidenciasScreen>
    with WidgetsBindingObserver {
  Timer? _pollingTimer;

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
    _pollingTimer = Timer.periodic(const Duration(seconds: 20), (_) => _refresh());
  }

  Future<void> _refresh() async {
    try {
      ref.invalidate(incidenciasPendientesProvider);
      await ref.read(incidenciasPendientesProvider.future);
    } catch (_) {}
  }

  Color _chipBg(TipoIncidencia t) => switch (t) {
        TipoIncidencia.HARDWARE => Colors.red.shade100,
        TipoIncidencia.SOFTWARE => Colors.blue.shade100,
        TipoIncidencia.INFRAESTRUCTURA => Colors.amber.shade100,
        TipoIncidencia.OTRO => Colors.grey.shade300,
      };

  Color _chipFg(TipoIncidencia t) => switch (t) {
        TipoIncidencia.HARDWARE => Colors.red.shade800,
        TipoIncidencia.SOFTWARE => Colors.blue.shade800,
        TipoIncidencia.INFRAESTRUCTURA => Colors.orange.shade800,
        TipoIncidencia.OTRO => Colors.grey.shade700,
      };

  IconData _tipoIcon(TipoIncidencia t) => switch (t) {
        TipoIncidencia.HARDWARE => Icons.computer,
        TipoIncidencia.SOFTWARE => Icons.code,
        TipoIncidencia.INFRAESTRUCTURA => Icons.account_balance,
        TipoIncidencia.OTRO => Icons.help_outline,
      };

  @override
  Widget build(BuildContext context) {
    final pendientes = ref.watch(incidenciasPendientesProvider);
    final count = ref.watch(incidenciasCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(mainAxisSize: MainAxisSize.min, children: [
          const Text('Incidencias Pendientes', style: TextStyle(fontWeight: FontWeight.w700)),
          if (count > 0) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(12)),
              child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
          ],
        ]),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: pendientes.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Error al cargar incidencias'), const SizedBox(height: 8),
          ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
        ])),
        data: (list) {
          if (list.isEmpty) return const Center(child: Text('No hay incidencias pendientes', style: TextStyle(fontSize: 18)));
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: list.length,
              itemBuilder: (_, i) => _Card(incidencia: list[i]),
            ),
          );
        },
      ),
    );
  }
}

class _Card extends ConsumerWidget {
  final IncidenciaEntity incidencia;
  const _Card({required this.incidencia});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.read(incidenciaRepoProvider);
    final urgente = incidencia.esUrgente;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        title: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Chip(visualDensity: VisualDensity.compact, label: Text(incidencia.displayTipo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _chipFg(incidencia.tipoIncidencia))), backgroundColor: _chipBg(incidencia.tipoIncidencia), avatar: Icon(_tipoIcon(incidencia.tipoIncidencia), size: 16, color: _chipFg(incidencia.tipoIncidencia))),
              const SizedBox(height: 6),
              Text('Aula ${incidencia.codigoAula}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(DateFormat('dd/MM/yyyy HH:mm', 'es').format(incidencia.fechaReporte), style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            ]),
          ),
          if (urgente) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)), child: const Text('URGENTE', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w700, fontSize: 10))),
        ]),
        children: [
          const Divider(),
          Text(incidencia.descripcionBreve, style: const TextStyle(fontSize: 14, height: 1.4)),
          if (incidencia.cartaFormalGenerada != null && incidencia.cartaFormalGenerada!.isNotEmpty) ...[
            const SizedBox(height: 8),
            ExpansionTile(tilePadding: EdgeInsets.zero, title: const Text('Carta Formal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)), children: [
              Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12)), child: Text(incidencia.cartaFormalGenerada!, style: const TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic))),
            ]),
          ],
          if (incidencia.urlImagen != null && incidencia.urlImagen!.isNotEmpty) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(onPressed: () => _img(context, repo.imageUrl(incidencia.urlImagen!)), icon: const Icon(Icons.image, size: 18), label: const Text('Ver Evidencia')),
          ],
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton.icon(onPressed: () => _responder(context, ref), icon: const Icon(Icons.reply, size: 17), label: const Text('Responder'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(onPressed: () => _cerrar(ref), icon: const Icon(Icons.check_circle, size: 17), label: const Text('Cerrar'), style: FilledButton.styleFrom(backgroundColor: Colors.green))),
          ]),
        ],
      ),
    );
  }

  Color _chipBg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Colors.red.shade100, TipoIncidencia.SOFTWARE => Colors.blue.shade100, TipoIncidencia.INFRAESTRUCTURA => Colors.amber.shade100, TipoIncidencia.OTRO => Colors.grey.shade300, };
  Color _chipFg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Colors.red.shade800, TipoIncidencia.SOFTWARE => Colors.blue.shade800, TipoIncidencia.INFRAESTRUCTURA => Colors.orange.shade800, TipoIncidencia.OTRO => Colors.grey.shade700, };
  IconData _tipoIcon(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Icons.computer, TipoIncidencia.SOFTWARE => Icons.code, TipoIncidencia.INFRAESTRUCTURA => Icons.account_balance, TipoIncidencia.OTRO => Icons.help_outline, };

  void _responder(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))), builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Responder Incidencia #${incidencia.id}', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(incidencia.descripcionBreve, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 16),
        TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(hintText: 'Escribe la respuesta...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 16),
        SizedBox(width: double.infinity, child: FilledButton(
          onPressed: () async {
            if (ctrl.text.trim().isEmpty) return;
            await responderIncidencia(ref, incidencia.id.toString(), ctrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
            ref.invalidate(incidenciasPendientesProvider);
          },
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('ENVIAR RESPUESTA', style: TextStyle(fontWeight: FontWeight.w700)),
        )),
        const SizedBox(height: 16),
      ]),
    ));
  }

  void _cerrar(WidgetRef ref) async {
    await actualizarIncidencia(ref, incidencia.id.toString(), {'estado': 'CERRADA'});
    ref.invalidate(incidenciasPendientesProvider);
  }

  void _img(BuildContext context, String url) {
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(height: 200, color: Colors.grey.shade200, child: const Center(child: Icon(Icons.broken_image, size: 48, color: Colors.grey))))),
        Padding(padding: const EdgeInsets.all(8), child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
      ]),
    ));
  }
}
