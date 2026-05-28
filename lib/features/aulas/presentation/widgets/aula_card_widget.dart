import 'package:flutter/material.dart';
import '../../domain/entities/aula_entity.dart';
import '../views/aula_detail_screen.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_styles.dart';

class AulaCardWidget extends StatelessWidget {
  final AulaEntity aula;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AulaCardWidget({
    super.key,
    required this.aula,
    this.onEdit,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap ?? () {
          Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => AulaDetailScreen(aula: aula),
          ));
        },
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: AppShapes.circular16,
            border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.shadow.withValues(alpha: 0.25),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0, top: 0, bottom: 0,
                child: Container(width: 4, color: AppColors.success),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24, top: 20, right: 20, bottom: 20),
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildBloqueBadge(),
                    const Spacer(),
                    if (aula.requiereAutorizacion)
                      Tooltip(
                        message: 'Requiere Autorización',
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.danger.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.security_rounded, color: AppColors.danger, size: 16),
                        ),
                      ),
                    if (onEdit != null || onDelete != null)
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 20,
                        icon: Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                        onSelected: (value) {
                          if (value == 'edit') onEdit?.call();
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (_) => [
                          if (onEdit != null)
                            const PopupMenuItem(value: 'edit', child: Text('Editar')),
                          if (onDelete != null)
                            const PopupMenuItem(value: 'delete', child: Text('Eliminar')),
                        ],
                      ),
                  ],
                ),
                AppGaps.hMd,
                Text(
                  aula.nombreAula,
                  style: AppTextStyles.cardTitle.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                AppGaps.hXs,
                Text(
                  aula.tipoAula.nombre.toUpperCase(),
                  style: AppTextStyles.cardSubtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                AppGaps.hMd,
                const Divider(height: 1),
                AppGaps.hMd,
                Row(
                  children: [
                    Icon(Icons.people_alt_rounded, size: 20, color: AppColors.textSecondary),
                    AppGaps.wSm,
                    Text(
                      '${aula.capacidad} asientos',
                      style: AppTextStyles.sectionBody.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  ),
);
  }

  Widget _buildBloqueBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.8),
        borderRadius: AppShapes.circular8,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.domain, size: 18, color: AppColors.textPrimary),
          AppGaps.wXs,
          Text(
            aula.bloque.nombre,
            style: AppTextStyles.cardSubtitle.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
