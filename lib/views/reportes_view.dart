import 'package:flutter/material.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/views/new_report_modal_view.dart';

class ReportesView extends StatefulWidget {
  const ReportesView({super.key});

  @override
  State<ReportesView> createState() => _ReportesViewState();
}

class _ReportesViewState extends State<ReportesView> {
  bool _showNewReportOverlay = false;

  void _openOverlay() {
    setState(() {
      _showNewReportOverlay = true;
    });
  }

  void _closeOverlay() {
    setState(() {
      _showNewReportOverlay = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reportar Incidencia',
                style: AppTextStyles.pageTitle.copyWith(fontSize: 33),
              ),
              const SizedBox(height: 6),
              Text(
                'Ayudanos a mantener nuestras instalaciones en perfecto estado',
                style: AppTextStyles.pageSubtitle,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _openOverlay,
                borderRadius: BorderRadius.circular(22),
                child: _softCard(
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          gradient: AppColors.activeIconGradient,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.5)),
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 34),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Nuevo Reporte',
                              style: AppTextStyles.sectionTitle,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Reporta un problema en cualquier area del campus',
                              style: AppTextStyles.sectionBody,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _softCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E7E1),
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: const Center(child: Text('⚠️', style: TextStyle(fontSize: 18))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '¿Qué puedes reportar?',
                            style: AppTextStyles.pageTitle,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    const _BulletLine(
                      emoji: '🔨',
                      title: 'Daños Fisicos',
                      text: 'Muebles rotos, equipos dañados, infraestructura deteriorada',
                    ),
                    const SizedBox(height: 10),
                    const _BulletLine(
                      emoji: '🥱',
                      title: 'Quejas',
                      text: 'Ruido excesivo, mal servicio, inconformidades generales',
                    ),
                    const SizedBox(height: 10),
                    const _BulletLine(
                      emoji: '💡',
                      title: 'Recomendaciones',
                      text: 'Sugerencias para mejorar instalaciones y servicios',
                    ),
                    const SizedBox(height: 10),
                    const _BulletLine(
                      emoji: '🙏',
                      title: 'Peticiones',
                      text: 'Solicitudes de nuevos recursos o mejoras',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _softCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6E8FB),
                            borderRadius: BorderRadius.circular(21),
                          ),
                          child: const Icon(Icons.location_on_outlined, color: AppColors.primaryDark),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Mapa del Campus',
                            style: AppTextStyles.sectionTitle,
                            maxLines: 2,
                            softWrap: true,
                            overflow: TextOverflow.visible,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Vista interactiva de las instalaciones',
                      style: AppTextStyles.sectionBody,
                    ),
                    const SizedBox(height: 12),
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9ECFC),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxLeft = constraints.maxWidth - 84;

                          double safeLeft(double value) {
                            return value.clamp(0, maxLeft).toDouble();
                          }

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.5,
                                  child: CustomPaint(painter: _GridPainter()),
                                ),
                              ),
                              Positioned(
                                left: safeLeft(constraints.maxWidth * 0.10),
                                top: 86,
                                child: const _BuildingChip(code: 'A-101', subtitle: 'Ingenieria'),
                              ),
                              Positioned(
                                left: safeLeft(constraints.maxWidth * 0.40),
                                top: 62,
                                child: const _BuildingChip(code: 'B-205', subtitle: 'Ciencias'),
                              ),
                              Positioned(
                                left: safeLeft(constraints.maxWidth * 0.72),
                                top: 98,
                                child: const _BuildingChip(code: 'C-301', subtitle: 'Admin'),
                              ),
                              Positioned(
                                left: safeLeft(constraints.maxWidth * 0.24),
                                top: 152,
                                child: const _BuildingChip(code: 'D-102', subtitle: 'Humanidades'),
                              ),
                              Positioned(
                                left: 10,
                                bottom: 12,
                                right: 10,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(color: const Color(0xFFA6B4FF)),
                                    ),
                                    child: Text(
                                      '●  Toca un edificio para seleccionar',
                                      style: AppTextStyles.smallLabel.copyWith(
                                        color: AppColors.primaryDark,
                                        fontSize: 11,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showNewReportOverlay) ...[
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeOverlay,
              child: Container(color: Colors.black.withValues(alpha: 0.28)),
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Material(
                    color: Colors.white,
                    child: NewReportModalView(onClose: _closeOverlay),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SoftCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _SoftCard({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.pageCard,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

Widget _softCard({required Widget child, EdgeInsetsGeometry? padding}) =>
  _SoftCard(padding: padding, child: child);

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
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.cardTitle,
              ),
              Text(
                text,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BuildingChip extends StatelessWidget {
  final String code;
  final String subtitle;

  const _BuildingChip({required this.code, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFB0C0FF), Color(0xFF8FA5F2)],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              code,
              style: AppTextStyles.smallLabel.copyWith(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              subtitle,
              style: AppTextStyles.tinyLabel.copyWith(
                color: const Color(0xFFEAF0FF),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD2D8F7)
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
