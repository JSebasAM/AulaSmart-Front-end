import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';

class AdminIncidenciasScreen extends ConsumerWidget {
  const AdminIncidenciasScreen({super.key});

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'DANO_FISICO':
        return Colors.red.shade100;
      case 'QUEJA':
        return Colors.orange.shade100;
      case 'RECLAMO':
        return Colors.yellow.shade100;
      case 'RECOMENDACION':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _textoPorTipo(String tipo) {
    switch (tipo) {
      case 'DANO_FISICO':
        return Colors.red.shade800;
      case 'QUEJA':
        return Colors.orange.shade800;
      case 'RECLAMO':
        return Colors.yellow.shade800;
      case 'RECOMENDACION':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendientesAsync = ref.watch(incidenciasPendientesProvider);
    final countAsync = ref.watch(incidenciasCountProvider);

    final badge = countAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Incidencias Pendientes',
                style: TextStyle(fontWeight: FontWeight.w700)),
            if (badge > 0) ...[
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.danger,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('$badge',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ],
        ),
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
              const Text('Error al cargar incidencias'),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () =>
                    ref.invalidate(incidenciasPendientesProvider),
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
                  Icon(Icons.celebration, size: 64, color: Colors.green),
                  SizedBox(height: 16),
                  Text('No hay incidencias pendientes',
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(incidenciasPendientesProvider);
              await ref.read(incidenciasPendientesProvider.future);
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendientes.length,
              itemBuilder: (context, index) =>
                  _IncidenciaCard(incidencia: pendientes[index]),
            ),
          );
        },
      ),
    );
  }
}

class _IncidenciaCard extends ConsumerWidget {
  final IncidenciaEntity incidencia;
  const _IncidenciaCard({required this.incidencia});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      shadowColor: AppColors.primary.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _colorPorTipo(incidencia.tipoIncidencia),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    incidencia.displayTipo,
                    style: TextStyle(
                      color: _textoPorTipo(incidencia.tipoIncidencia),
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm', 'es')
                      .format(incidencia.fechaReporte),
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.meeting_room_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text('Aula ${incidencia.codigoAula}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 15)),
                const Spacer(),
                Text('ID #${incidencia.id}',
                    style:
                        TextStyle(color: Colors.grey.shade500, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 8),
            Text(incidencia.descripcionBreve,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 14, height: 1.4)),
            if (incidencia.cartaFormalGenerada != null &&
                incidencia.cartaFormalGenerada!.isNotEmpty) ...[
              const SizedBox(height: 8),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Ver Carta Formal',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary)),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cartaBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      incidencia.cartaFormalGenerada!,
                      style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
            if (incidencia.urlImagen != null &&
                incidencia.urlImagen!.isNotEmpty) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _mostrarImagen(context, ref),
                icon: const Icon(Icons.image, size: 18),
                label: const Text('Ver Evidencia'),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => _responderModal(context, ref),
                icon: const Icon(Icons.reply, size: 18),
                label: const Text('RESPONDER'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorPorTipo(String tipo) {
    switch (tipo) {
      case 'DANO_FISICO':
        return Colors.red.shade100;
      case 'QUEJA':
        return Colors.orange.shade100;
      case 'RECLAMO':
        return Colors.yellow.shade100;
      case 'RECOMENDACION':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade200;
    }
  }

  Color _textoPorTipo(String tipo) {
    switch (tipo) {
      case 'DANO_FISICO':
        return Colors.red.shade800;
      case 'QUEJA':
        return Colors.orange.shade800;
      case 'RECLAMO':
        return Colors.yellow.shade800;
      case 'RECOMENDACION':
        return Colors.green.shade800;
      default:
        return Colors.grey.shade700;
    }
  }

  void _mostrarImagen(BuildContext context, WidgetRef ref) {
    final repo = ref.read(incidenciaRepositoryProvider);
    final url = repo.imageUrl(incidencia.urlImagen!);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(url, fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _responderModal(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Responder Incidencia #${incidencia.id}',
                  style: Theme.of(ctx)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Aula ${incidencia.codigoAula} \u2022 '
                  '${incidencia.displayTipo}'),
              const SizedBox(height: 4),
              Text(incidencia.descripcionBreve,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade600)),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Escribe la respuesta para el usuario...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    final resp = controller.text.trim();
                    if (resp.isEmpty) return;
                    try {
                      await responderIncidencia(
                          ref, incidencia.id.toString(), resp);
                      if (ctx.mounted) Navigator.pop(ctx);
                      ref.invalidate(incidenciasPendientesProvider);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Respuesta enviada exitosamente'),
                              backgroundColor: Colors.green),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.danger),
                        );
                      }
                    }
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('ENVIAR RESPUESTA',
                      style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
