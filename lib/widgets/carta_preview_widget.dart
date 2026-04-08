import 'package:flutter/material.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';

class CartaPreviewWidget extends StatelessWidget {
  final String tipo;
  final String ubicacion;
  final String titulo;
  final String descripcion;
  final VoidCallback? onEditar;
  final VoidCallback? onDescargar;
  final VoidCallback? onEnviar;

  const CartaPreviewWidget({
    required this.tipo,
    required this.ubicacion,
    required this.titulo,
    required this.descripcion,
    this.onEditar,
    this.onDescargar,
    this.onEnviar,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            _buildHeader(context),
            const SizedBox(height: 24),

            // Contenedor de la carta
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: _buildCartaContent(),
              ),
            ),
            const SizedBox(height: 16),

            // Nota AI
            _buildAINota(),
            const SizedBox(height: 32),

            // Botones de acción
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.cartaPrimary.withOpacity(0.1),
            AppColors.cartaSecondary.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.cartaSecondary.withOpacity(0.2),
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cartaPrimary,
                  AppColors.cartaSecondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vista Previa de la Carta',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.cartaPrimaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Revisa antes de enviar',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.cartaSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.cartaSecondary.withOpacity(0.3),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEditar,
                borderRadius: BorderRadius.circular(8),
                child: const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: AppColors.cartaPrimary,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Editar',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.cartaPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartaContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado formal
        _buildEncabezado(),
        const SizedBox(height: 24),
        Divider(
          color: AppColors.cartaSecondary.withOpacity(0.2),
        ),
        const SizedBox(height: 16),

        // Cuerpo
        _buildCuerpo(),

        const SizedBox(height: 24),
        Divider(
          color: AppColors.cartaSecondary.withOpacity(0.2),
        ),
        const SizedBox(height: 16),

        // Cierre
        _buildCierre(),
      ],
    );
  }

  Widget _buildEncabezado() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'UNIVERSIDAD CENTRAL DEL VALLE DEL CAUCA - UCEVA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.cartaPrimaryDark,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'AulaSmart - Sistema de Gestión de Aulas',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.cartaSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildEncabezadoInfo('Fecha', _getCurrentDate()),
            _buildEncabezadoInfo('Asunto', '$tipo - ${titulo.length}'),
          ],
        ),
      ],
    );
  }

  Widget _buildEncabezadoInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.cartaSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.cartaPrimaryDark,
          ),
        ),
      ],
    );
  }

  Widget _buildCuerpo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Estimado(a) Responsable de Infraestructura:',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.cartaPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Por medio de este escrito, me dirijo a usted con el propósito de reportar una situación que requiere su atención inmediata en las instalaciones de nuestra institución educativa.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.cartaPrimaryDark,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 12),
        _buildDetallesCuerpo(),
        const SizedBox(height: 12),
        Text(
          descripcion,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.cartaPrimaryDark,
            height: 1.5,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildDetallesCuerpo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cartaBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.cartaSecondary.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetalleRow('Tipo de Reporte:', tipo),
          const SizedBox(height: 8),
          _buildDetalleRow('Ubicación:', ubicacion),
          const SizedBox(height: 8),
          _buildDetalleRow('Título:', titulo),
        ],
      ),
    );
  }

  Widget _buildDetalleRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.cartaPrimaryDark,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.cartaSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCierre() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Agradezco de antemano su atención a este importante asunto y quedo atento a cualquier información adicional que pueda requerir.',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.cartaPrimaryDark,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Atentamente,',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.cartaPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 60,
          height: 2,
          color: AppColors.cartaSecondary.withOpacity(0.3),
        ),
        const SizedBox(height: 8),
        Text(
          'Usuario de AulaSmart',
          style: TextStyle(
            fontSize: 11,
            color: AppColors.cartaPrimaryDark,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'UCEVA',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.cartaSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Fecha de generación: ${_getCurrentDate()}',
          style: TextStyle(
            fontSize: 9,
            color: AppColors.cartaSecondary,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildAINota() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: AppColors.cartaSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.cartaSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.auto_awesome,
            size: 14,
            color: AppColors.cartaSecondary,
          ),
          const SizedBox(width: 8),
          Text(
            'Generado con Inteligencia Artificial',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.cartaSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.cartaPrimary,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onDescargar,
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.download,
                      color: AppColors.cartaPrimary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Descargar',
                      style: TextStyle(
                        color: AppColors.cartaPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.cartaButtonGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cartaPrimary.withOpacity(0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEnviar,
                borderRadius: BorderRadius.circular(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Enviar',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    final dia = now.day;
    const meses = [
      'enero',
      'febrero',
      'marzo',
      'abril',
      'mayo',
      'junio',
      'julio',
      'agosto',
      'septiembre',
      'octubre',
      'noviembre',
      'diciembre'
    ];
    return '$dia de ${meses[now.month - 1]} de ${now.year}';
  }
}
