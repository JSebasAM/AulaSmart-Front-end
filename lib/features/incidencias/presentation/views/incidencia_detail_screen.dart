import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';

class IncidenciaDetailScreen extends ConsumerWidget {
  final String id;
  const IncidenciaDetailScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inc = ref.watch(incidenciaByIdProvider(id));

    return inc.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $e')),
      ),
      data: (incidencia) => Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: incidencia.urlImagen != null ? 250 : 120,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: Text('Incidencia #${incidencia.id}'),
                background: incidencia.urlImagen != null
                    ? Image.network(
                        ref.read(incidenciaRepoProvider).imageUrl(incidencia.urlImagen!),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_chipBg(incidencia.tipoIncidencia), _chipBg(incidencia.tipoIncidencia).withValues(alpha: 0.5)],
                            ),
                          ),
                        ),
                      )
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_chipBg(incidencia.tipoIncidencia), _chipBg(incidencia.tipoIncidencia).withValues(alpha: 0.5)],
                          ),
                        ),
                      ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Chip(label: Text(incidencia.displayTipo), backgroundColor: _chipBg(incidencia.tipoIncidencia)),
                    const SizedBox(width: 8),
                    Chip(label: Text(incidencia.displayEstado), backgroundColor: _estadoBg(incidencia.estado)),
                  ]),
                  const SizedBox(height: 12),
                  Text('Aula ${incidencia.codigoAula}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(DateFormat('dd/MM/yyyy HH:mm', 'es').format(incidencia.fechaReporte), style: TextStyle(color: Colors.grey.shade600)),
                  const Divider(height: 32),
                  _Section(title: 'Descripcion', child: Text(incidencia.descripcionBreve, style: const TextStyle(fontSize: 15, height: 1.5))),
                  if (incidencia.cartaFormalGenerada != null && incidencia.cartaFormalGenerada!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Section(title: 'Carta Formal Generada', child: Container(
                      width: double.infinity, padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                      child: Text(incidencia.cartaFormalGenerada!, style: const TextStyle(fontSize: 14, height: 1.6, fontFamily: 'monospace')),
                    )),
                  ],
                  if (incidencia.respuestaAdministracion != null && incidencia.respuestaAdministracion!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _Section(title: 'Respuesta de Administracion', child: Container(
                      width: double.infinity, padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(incidencia.respuestaAdministracion!, style: const TextStyle(fontSize: 14, height: 1.5)),
                        if (incidencia.fechaRespuesta != null) ...[
                          const SizedBox(height: 8),
                          Text('Respondido el ${DateFormat('dd/MM/yyyy').format(incidencia.fechaRespuesta!)}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                        ],
                      ]),
                    )),
                  ],
                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
        floatingActionButton: incidencia.estaPendiente
            ? FloatingActionButton.extended(
                onPressed: () => _confirmDelete(context, ref, incidencia),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Eliminar'),
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
              )
            : null,
        persistentFooterButtons: incidencia.estaPendiente ? [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _responder(context, ref, incidencia),
              icon: const Icon(Icons.reply),
              label: const Text('Responder'),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
            ),
          ),
        ] : null,
      ),
    );
  }

  Color _chipBg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Colors.red.shade100, TipoIncidencia.SOFTWARE => Colors.blue.shade100, TipoIncidencia.INFRAESTRUCTURA => Colors.amber.shade100, TipoIncidencia.OTRO => Colors.grey.shade300, };
  Color? _estadoBg(EstadoIncidencia e) => switch (e) { EstadoIncidencia.PENDIENTE => Colors.orange.shade100, EstadoIncidencia.REVISADA => Colors.blue.shade100, EstadoIncidencia.CERRADA => Colors.green.shade100, };

  void _responder(BuildContext context, WidgetRef ref, IncidenciaEntity inc) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Responder Incidencia', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(hintText: 'Escribe la respuesta...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: () async {
              if (ctrl.text.trim().isEmpty) return;
              await responderIncidencia(ref, inc.id.toString(), ctrl.text.trim());
              if (ctx.mounted) Navigator.pop(ctx);
              ref.invalidate(incidenciaByIdProvider(id));
            },
            child: const Text('ENVIAR'),
          )),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, IncidenciaEntity inc) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar incidencia'),
        content: const Text('Esta accion no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () async {
              await eliminarIncidencia(ref, inc.id.toString());
              if (ctx.mounted) Navigator.pop(ctx);
              ref.invalidate(todasLasIncidenciasProvider);
              if (context.mounted) { context.pop(); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incidencia eliminada'), backgroundColor: Colors.green)); }
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
    const SizedBox(height: 8),
    child,
  ]);
}
