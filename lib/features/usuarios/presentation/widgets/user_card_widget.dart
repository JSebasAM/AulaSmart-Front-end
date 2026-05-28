import 'package:flutter/material.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../../../themes/app_colors.dart';
import '../../../../themes/app_text_styles.dart';
import '../../../../themes/app_styles.dart';

class UserCardWidget extends StatelessWidget {
  final UsuarioEntity user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final String initials = (user.nombre.isNotEmpty ? user.nombre[0] : '') +
        (user.apellido.isNotEmpty ? user.apellido[0] : '');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: AppShapes.circular24,
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
            Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: _rolAccentColor(user.rol))),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEdit,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 4, 14),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _rolAccentColor(user.rol),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initials.toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ),
                      ),
                      AppGaps.wMd,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('${user.nombre} ${user.apellido}', style: AppTextStyles.cardTitle.copyWith(fontSize: 16)),
                            AppGaps.hXs2,
                            Text(user.email, style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.textSecondary.withValues(alpha: 0.8))),
                            AppGaps.hSm,
                            _buildRoleBadge(user.rol),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') onEdit();
                          if (value == 'delete') onDelete();
                        },
                        icon: const Icon(Icons.more_vert, color: AppColors.neutral),
                        shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 20),
                                AppGaps.wSm,
                                Text('Editar'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete_outline, size: 20, color: AppColors.danger),
                                AppGaps.wSm,
                                const Text('Eliminar', style: TextStyle(color: AppColors.danger)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rolAccentColor(String rol) => AppColors.forRole(rol);

  Widget _buildRoleBadge(String rol) {
    final accent = _rolAccentColor(rol);
    final badgeColor = accent.withValues(alpha: 0.1);
    final textColor = accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: AppShapes.circular20,
      ),
      child: Text(
        rol.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: textColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
