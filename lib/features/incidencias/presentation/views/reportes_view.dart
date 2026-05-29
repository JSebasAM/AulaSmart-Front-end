import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aulasmart_front_end/core/themes/app_colors.dart';
import 'package:aulasmart_front_end/core/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/core/themes/app_styles.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/views/new_report_modal_view.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  void _openOverlay() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.28),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.3,
          maxChildSize: 0.95,
          expand: false,
          builder: (_, scrollCtrl) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: Material(
              color: AppColors.surface,
              child: NewReportModalView(
                onClose: () => Navigator.of(ctx).pop(),
                scrollController: scrollCtrl,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // HEADER
          SliverAppBar(
            toolbarHeight: 125,
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
                    ShaderMask(
                      shaderCallback: (bounds) =>
                          AppColors.primaryGradient.createShader(bounds),
                      child: Text(
                        'Reportes',
                        style: AppTextStyles.pageTitle.copyWith(
                          color: Colors.white,
                          letterSpacing: -0.02,
                        ),
                      ),
                    ),

                    AppGaps.hSm,

                    Container(
                      width: 24,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.textSecondary,
                        borderRadius: AppShapes.circular20,
                      ),
                    ),

                    AppGaps.hXs,

                    Text(
                      'Ayúdanos a mantener nuestras instalaciones',
                      style: AppTextStyles.pageSubtitle.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SPACE FIX
          const SliverToBoxAdapter(child: SizedBox(height: 8)),

          // ACTION BUTTONS
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      icon: Icons.add,
                      label: 'Nuevo Reporte',
                      gradient: AppColors.activeIconGradient,
                      onTap: _openOverlay,
                    ),
                  ),

                  AppGaps.wMd,

                  Expanded(
                    child: _ActionCard(
                      icon: Icons.list_alt_rounded,
                      label: 'Mis Incidencias',
                      color: AppColors.info,
                      onTap: () => context.push('/incidencias'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // INFO CARD
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _InfoCard(
                icon: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: AppShapes.circular12,
                  ),
                  child: const Center(
                    child: Text('⚠️', style: TextStyle(fontSize: 18)),
                  ),
                ),
                title: '¿Qué puedes reportar?',
                children: [
                  _BulletLine(
                    emoji: '🔨',
                    title: 'Daños Físicos',
                    text:
                        'Muebles rotos, equipos dañados, infraestructura deteriorada',
                  ),

                  AppGaps.hMd,

                  _BulletLine(
                    emoji: '🥱',
                    title: 'Quejas',
                    text:
                        'Ruido excesivo, mal servicio, inconformidades generales',
                  ),

                  AppGaps.hMd,

                  _BulletLine(
                    emoji: '💡',
                    title: 'Recomendaciones',
                    text: 'Sugerencias para mejorar instalaciones y servicios',
                  ),

                  AppGaps.hMd,

                  _BulletLine(
                    emoji: '🙏',
                    title: 'Peticiones',
                    text: 'Solicitudes de nuevos recursos o mejoras',
                  ),
                ],
              ),
            ),
          ),

          // MAP CARD
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: _MapCard(),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final LinearGradient? gradient;
  final Color? color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    this.gradient,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.circular16,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.circular16,
          border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, 10),
              spreadRadius: -3,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 4),
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: gradient,
                color: color?.withValues(alpha: 0.15),
                borderRadius: AppShapes.circular12,
              ),
              child: Icon(
                icon,
                color: gradient != null ? AppColors.textOnPrimary : color,
                size: 28,
              ),
            ),

            AppGaps.hSm,

            Text(
              label,
              style: AppTextStyles.sectionBody.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final Widget icon;
  final String title;
  final List<Widget> children;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular16,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: AppColors.primary),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    icon,
                    AppGaps.wSm,
                    Expanded(
                      child: Text(title, style: AppTextStyles.sectionTitle),
                    ),
                  ],
                ),

                AppGaps.hMd,

                ...children,
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BulletLine extends StatelessWidget {
  final String emoji;
  final String title;
  final String text;

  const _BulletLine({
    required this.emoji,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),

        AppGaps.wSm,

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.cardTitle),

              Text(text, style: AppTextStyles.cardSubtitle),
            ],
          ),
        ),
      ],
    );
  }
}

class _MapCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular16,
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 10),
            spreadRadius: -3,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: Container(width: 4, color: AppColors.info),
          ),

          Padding(
            padding: const EdgeInsets.only(
              left: 20,
              top: 16,
              right: 16,
              bottom: 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: AppShapes.circular12,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.primaryDark,
                      ),
                    ),

                    AppGaps.wSm,

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Mapa del Campus',
                            style: AppTextStyles.sectionTitle,
                          ),

                          Text(
                            'Vista interactiva de las instalaciones',
                            style: AppTextStyles.sectionBody,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                AppGaps.hMd,

                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: AppShapes.circular16,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.hourglass_empty_outlined,
                        size: 48,
                        color: AppColors.textSecondary.withValues(alpha: 0.5),
                      ),

                      AppGaps.hMd,

                      Text(
                        'Próximamente',
                        style: AppTextStyles.sectionTitle.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      AppGaps.hXs,

                      Text(
                        'Vista interactiva de las instalaciones',
                        style: AppTextStyles.sectionBody.copyWith(
                          color: AppColors.textSecondary.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
