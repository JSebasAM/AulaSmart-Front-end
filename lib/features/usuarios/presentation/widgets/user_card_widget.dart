import 'package:flutter/material.dart';
import '../../domain/entities/usuario_entity.dart';
import '../../../../themes/app_colors.dart';

class UserCardWidget extends StatelessWidget {
  final UsuarioEntity user;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onChangePassword;

  const UserCardWidget({
    super.key,
    required this.user,
    required this.onEdit,
    required this.onDelete,
    required this.onChangePassword,
  });

  @override
  Widget build(BuildContext context) {
    final String initials = (user.nombre.isNotEmpty ? user.nombre[0] : '') +
        (user.apellido.isNotEmpty ? user.apellido[0] : '');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppColors.activeIconGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initials.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.nombre} ${user.apellido}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildRoleBadge(user.rol),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') onEdit();
                      if (value == 'password') onChangePassword();
                      if (value == 'delete') onDelete();
                    },
                    icon: const Icon(Icons.more_vert, color: AppColors.neutral),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Editar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'password',
                        child: Row(
                          children: [
                            Icon(Icons.lock_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Cambiar contraseña'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline,
                                size: 20, color: AppColors.danger),
                            const SizedBox(width: 8),
                            Text(
                              'Eliminar',
                              style: TextStyle(color: AppColors.danger),
                            ),
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
      ),
    );
  }

  Widget _buildRoleBadge(String rol) {
    Color badgeColor;
    Color textColor;

    switch (rol.toLowerCase()) {
      case 'administrador':
        badgeColor = AppColors.danger.withOpacity(0.1);
        textColor = AppColors.danger;
        break;
      case 'docente':
        badgeColor = AppColors.info.withOpacity(0.1);
        textColor = AppColors.info;
        break;
      case 'estudiante':
        badgeColor = AppColors.success.withOpacity(0.1);
        textColor = AppColors.success;
        break;
       case 'monitor':
        badgeColor = AppColors.neutral.withOpacity(0.1);
        textColor = AppColors.neutral;
        break;
       case 'administrativo':
        badgeColor = AppColors.warning.withOpacity(0.1);
        textColor = AppColors.warning;
        break;
      default:
        badgeColor = AppColors.neutral.withOpacity(0.1);
        textColor = AppColors.neutral;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(20),
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
