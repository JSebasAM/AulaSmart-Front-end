import 'package:flutter/material.dart';
import '../../domain/entities/aula_entity.dart';
import '../views/aula_detail_screen.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withOpacity(0.5),
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
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.business_rounded, size: 16, color: colorScheme.onSecondaryContainer),
                            const SizedBox(width: 6),
                            Text(
                              aula.bloque.nombre,
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: colorScheme.onSecondaryContainer,
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
                                  color: colorScheme.errorContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.security_rounded, color: colorScheme.error, size: 16),
                              ),
                            ),
                          if (onEdit != null || onDelete != null)
                            PopupMenuButton<String>(
                              padding: EdgeInsets.zero,
                              iconSize: 20,
                              icon: Icon(Icons.more_vert_rounded, color: colorScheme.onSurfaceVariant),
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
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    aula.tipoAula.nombre.toUpperCase(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildInfoBadge(
                        context,
                        icon: Icons.people_alt_rounded,
                        label: '${aula.capacidad} asientos',
                        color: colorScheme.tertiary,
                        bgColor: colorScheme.tertiaryContainer,
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: colorScheme.primary,
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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
