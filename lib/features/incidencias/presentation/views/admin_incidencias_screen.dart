import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/core/themes/app_styles.dart';

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
        TipoIncidencia.HARDWARE => AppColors.danger.withValues(alpha: 0.12),
        TipoIncidencia.SOFTWARE => AppColors.primary.withValues(alpha: 0.12),
        TipoIncidencia.INFRAESTRUCTURA => AppColors.warning.withValues(alpha: 0.12),
        TipoIncidencia.OTRO => AppColors.neutral.withValues(alpha: 0.12),
      };

  Color _chipFg(TipoIncidencia t) => switch (t) {
        TipoIncidencia.HARDWARE => AppColors.danger,
        TipoIncidencia.SOFTWARE => AppColors.primary,
        TipoIncidencia.INFRAESTRUCTURA => AppColors.warning,
        TipoIncidencia.OTRO => AppColors.neutral,
      };

  Color _tipoAccent(TipoIncidencia t) => switch (t) {
        TipoIncidencia.HARDWARE => AppColors.danger,
        TipoIncidencia.SOFTWARE => AppColors.primary,
        TipoIncidencia.INFRAESTRUCTURA => AppColors.warning,
        TipoIncidencia.OTRO => AppColors.neutral,
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
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverAppBar(
            toolbarHeight: 80,
            floating: false,
            pinned: false,
            backgroundColor: Colors.transparent,
            forceMaterialTransparency: true,
            title: Padding(
              padding: const EdgeInsets.only(left: 24, top: 8),
              child: DefaultTextStyle(
                style: const TextStyle(),
                softWrap: true,
                overflow: TextOverflow.visible,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                          child: Text(
                            'Incidencias',
                            style: AppTextStyles.pageTitle.copyWith(color: Colors.white, letterSpacing: -0.02),
                          ),
                        ),
                        if (count > 0) ...[
                          AppGaps.wSm,
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.danger, borderRadius: AppShapes.circular12),
                            child: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700)),
                          ),
                        ],
                      ],
                    ),
                    AppGaps.hSm,
                    Container(width: 24, height: 2, decoration: BoxDecoration(color: AppColors.textSecondary, borderRadius: AppShapes.circular20)),
                    AppGaps.hXs,
                    Text('Reportes pendientes', style: AppTextStyles.pageSubtitle.copyWith(height: 1.5)),
                  ],
                ),
              ),
            ),
          ),
          pendientes.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Text('Error al cargar incidencias', style: AppTextStyles.sectionBody),
                AppGaps.hSm,
                ElevatedButton(onPressed: _refresh, child: const Text('Reintentar')),
              ])),
            ),
            data: (list) {
              if (list.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.check_circle_outline, size: 64, color: AppColors.success),
                      AppGaps.hLg,
                      const Text('No hay incidencias pendientes', style: AppTextStyles.sectionTitle),
                    ]),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => _Card(incidencia: list[i]),
                  childCount: list.length,
                ),
              );
            },
          ),
        ],
      ),
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.circular24,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 10), spreadRadius: -3,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02), blurRadius: 6, offset: const Offset(0, 4), spreadRadius: -2,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: _tipoAccent(incidencia.tipoIncidencia))),
            ExpansionTile(
              tilePadding: const EdgeInsets.fromLTRB(20, 8, 8, 8),
              childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              shape: const Border(),
              collapsedShape: const Border(),
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: _chipBg(incidencia.tipoIncidencia), borderRadius: AppShapes.circular20),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_tipoIcon(incidencia.tipoIncidencia), size: 14, color: _chipFg(incidencia.tipoIncidencia)),
                                AppGaps.wXs,
                                Text(incidencia.displayTipo, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11, color: _chipFg(incidencia.tipoIncidencia))),
                              ],
                            ),
                          ),
                          if (urgente) ...[
                            AppGaps.wXs,
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: AppColors.danger.withValues(alpha: 0.1), borderRadius: AppShapes.circular8),
                              child: const Text('URGENTE', style: TextStyle(color: AppColors.danger, fontWeight: FontWeight.w700, fontSize: 10)),
                            ),
                          ],
                        ],
                      ),
                      AppGaps.hSm,
                      Text('Aula ${incidencia.codigoAula}', style: AppTextStyles.cardTitle),
                      AppGaps.hXs2,
                      Text(DateFormat('dd/MM/yyyy HH:mm', 'es').format(incidencia.fechaReporte), style: AppTextStyles.cardSubtitle),
                    ]),
                  ),
                ],
              ),
              children: [
                const Divider(color: AppColors.border),
                AppGaps.hSm,
                Text(incidencia.descripcionBreve, style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textPrimary)),
                if (incidencia.cartaFormalGenerada != null && incidencia.cartaFormalGenerada!.isNotEmpty) ...[
                  AppGaps.hSm,
                  ExpansionTile(
                    tilePadding: EdgeInsets.zero,
                    title: const Text('Carta Formal', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                    shape: const Border(),
                    collapsedShape: const Border(),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: AppColors.surfaceVariant, borderRadius: AppShapes.circular12),
                        child: Text(incidencia.cartaFormalGenerada!, style: const TextStyle(fontSize: 13, height: 1.5, fontStyle: FontStyle.italic, color: AppColors.textPrimary)),
                      ),
                    ],
                  ),
                ],
                if (incidencia.urlImagen != null && incidencia.urlImagen!.isNotEmpty) ...[
                  AppGaps.hSm,
                  OutlinedButton.icon(
                    onPressed: () => _img(context, repo.imageUrl(incidencia.urlImagen!)),
                    icon: const Icon(Icons.image, size: 18),
                    label: const Text('Ver Evidencia'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
                    ),
                  ),
                ],
                AppGaps.hMd,
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _responder(context, ref),
                      icon: const Icon(Icons.reply, size: 17),
                      label: const Text('Responder'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
                      ),
                    ),
                  ),
                  AppGaps.wMd,
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _cerrar(ref),
                      icon: const Icon(Icons.check_circle, size: 17),
                      label: const Text('Cerrar'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.success,
                        shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
                      ),
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _chipBg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => AppColors.danger.withValues(alpha: 0.12), TipoIncidencia.SOFTWARE => AppColors.primary.withValues(alpha: 0.12), TipoIncidencia.INFRAESTRUCTURA => AppColors.warning.withValues(alpha: 0.12), TipoIncidencia.OTRO => AppColors.neutral.withValues(alpha: 0.12), };
  Color _chipFg(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => AppColors.danger, TipoIncidencia.SOFTWARE => AppColors.primary, TipoIncidencia.INFRAESTRUCTURA => AppColors.warning, TipoIncidencia.OTRO => AppColors.neutral, };
  Color _tipoAccent(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => AppColors.danger, TipoIncidencia.SOFTWARE => AppColors.primary, TipoIncidencia.INFRAESTRUCTURA => AppColors.warning, TipoIncidencia.OTRO => AppColors.neutral, };
  IconData _tipoIcon(TipoIncidencia t) => switch (t) { TipoIncidencia.HARDWARE => Icons.computer, TipoIncidencia.SOFTWARE => Icons.code, TipoIncidencia.INFRAESTRUCTURA => Icons.account_balance, TipoIncidencia.OTRO => Icons.help_outline, };

  void _responder(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Responder Incidencia #${incidencia.id}', style: AppTextStyles.sectionTitle),
          AppGaps.hSm,
          Text(incidencia.descripcionBreve, style: AppTextStyles.sectionBody, maxLines: 2, overflow: TextOverflow.ellipsis),
          AppGaps.hLg,
          TextField(controller: ctrl, maxLines: 4, decoration: InputDecoration(hintText: 'Escribe la respuesta...', border: OutlineInputBorder(borderRadius: AppShapes.circular12), filled: true, fillColor: AppColors.surfaceVariant)),
          AppGaps.hLg,
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () async {
                if (ctrl.text.trim().isEmpty) return;
                await responderIncidencia(ref, incidencia.id.toString(), ctrl.text.trim());
                if (ctx.mounted) Navigator.pop(ctx);
                ref.invalidate(incidenciasPendientesProvider);
              },
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12)),
              child: const Text('ENVIAR RESPUESTA', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
          AppGaps.hLg,
        ]),
      ),
    );
  }

  void _cerrar(WidgetRef ref) async {
    await actualizarIncidencia(ref, incidencia.id.toString(), {'estado': 'CERRADA'});
    ref.invalidate(incidenciasPendientesProvider);
  }

  void _img(BuildContext context, String url) {
    showDialog(context: context, builder: (_) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: AppShapes.circular16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, __, ___) => Container(height: 200, color: AppColors.surfaceVariant, child: const Center(child: Icon(Icons.broken_image, size: 48, color: AppColors.neutral)))),
        ),
        Padding(padding: const EdgeInsets.all(8), child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))),
      ]),
    ));
  }
}
