import 'package:flutter/material.dart';
import '../../domain/entities/aula_entity.dart';
import '../views/aula_detail_screen.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';

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
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: AppColors.border.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap ?? () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => AulaDetailScreen(aula: aula)));
            },
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_rounded, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              aula.bloque.nombre,
                              style: AppTextStyles.cardSubtitle.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (aula.requiereAutorizacion)
                            Tooltip(
                              message: 'Requiere Autorización',
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.danger.withOpacity(0.12),
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
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    aula.nombreAula,
                    style: AppTextStyles.cardTitle.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),                                      
                  ),
                  const SizedBox(height: 6),
                  Text(
                    aula.tipoAula.nombre.toUpperCase(),
                    style: AppTextStyles.smallLabel.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoBadge(
                        context,
                        icon: Icons.people_alt_rounded,
                        label: '${aula.capacidad} asientos',
                        color: AppColors.info,
                        bgColor: AppColors.surfaceVariant,
                        
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, {required IconData icon, required String label, required Color color, required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.smallLabel.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
