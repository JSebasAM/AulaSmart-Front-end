import 'package:aulasmart_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/themes/app_styles.dart';
import 'package:aulasmart_front_end/services/storage_service.dart';
import 'package:aulasmart_front_end/services/session_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PerfilView extends ConsumerWidget {
  const PerfilView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: userAsync.when(
        data: (user) => _buildContent(context, ref, user),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => _buildError(err),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, Map<String, dynamic>? user) {
    final nombreCompleto = user?['nombre_completo'] as String? ?? 'Usuario';
    final email = user?['email'] as String? ?? '';
    final rolRaw = user?['rol'] as String? ?? '';
    final rol = _formatRol(rolRaw);
    final nombre = nombreCompleto.split(' ').first;
    final apellidos = nombreCompleto.split(' ').skip(1).join(' ');

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverAppBar(
          toolbarHeight: 100,
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
                    shaderCallback: (bounds) => AppColors.primaryGradient.createShader(bounds),
                    child: Text(
                      'Perfil',
                      style: AppTextStyles.pageTitle.copyWith(color: Colors.white, letterSpacing: -0.02),
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
                    'Gestiona tu perfil',
                    style: AppTextStyles.pageSubtitle.copyWith(height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ProfileHeaderCard(nombreCompleto: nombreCompleto, rol: rol, rolRaw: rolRaw),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _SectionTitle(title: 'Información Personal', subtitle: 'Tus datos registrados en el sistema'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: _InfoCard(nombre: nombre, apellidos: apellidos, email: email, rolRaw: rolRaw),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _SectionTitle(title: 'Preferencias', subtitle: 'Personaliza tu experiencia'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: const _PreferencesCard(),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: _SectionTitle(title: 'Cuenta', subtitle: 'Gestiona tu seguridad y acceso'),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            child: _AccountActionsCard(),
          ),
        ),
        if (kDebugMode)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: _DebugTools(),
            ),
          ),
      ],
    );
  }

  Widget _buildError(Object err) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.danger),
            AppGaps.hLg,
            const Text('No se pudo cargar la información del perfil'),
            AppGaps.hSm,
            Text(err.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _formatRol(String rol) {
    if (rol.isEmpty) return '';
    final lower = rol.toLowerCase();
    return lower[0].toUpperCase() + lower.substring(1);
  }

  static Color _rolAccentColor(String rol) => AppColors.forRole(rol);
}

// ─── PROFILE HEADER ──────────────────────────────────────────────────────────

class _ProfileHeaderCard extends StatelessWidget {
  final String nombreCompleto;
  final String rol;
  final String rolRaw;

  const _ProfileHeaderCard({required this.nombreCompleto, required this.rol, required this.rolRaw});

  String _getInitials() {
    final parts = nombreCompleto.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts[1][0]}'.toUpperCase();
    }
    return parts.first[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = PerfilView._rolAccentColor(rolRaw);

    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppShapes.circular28,
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
      //Orbes
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    roleColor.withValues(alpha: 0.30),
                    roleColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -80,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    roleColor.withValues(alpha: 0.35),
                    roleColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -15,
            left: -15,
            child: Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    roleColor.withValues(alpha: 0.35),
                    roleColor.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
              
            
          
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
            child: Column(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: roleColor.withValues(alpha: 0.70), width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: roleColor.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                        spreadRadius: -2,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      color: roleColor.withValues(alpha: 0.08),
                      child: Center(
                        child: Text(
                          _getInitials(),
                          style: TextStyle(
                            color: roleColor,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                AppGaps.hLg,
                Text(
                  nombreCompleto,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                if (rol.isNotEmpty) ...[
                  AppGaps.hSm,
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.1),
                      borderRadius: AppShapes.circular20,
                    ),
                    child: Text(
                      rol,
                      style: TextStyle(
                        color: roleColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
                AppGaps.hSm,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.business_rounded, size: 14, color: AppColors.textSecondary),
                    AppGaps.wSm,
                    Text(
                      'AulaSmart • Universidad UCEVA',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INFO CARD ───────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final String nombre;
  final String apellidos;
  final String email;
  final String rolRaw;

  const _InfoCard({required this.nombre, required this.apellidos, required this.email, required this.rolRaw});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: PerfilView._rolAccentColor(rolRaw).withValues(alpha: 0.5))),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 16, right: 16, bottom: 16),
            child: Column(
              children: [
                _InfoRow(icon: Icons.person_outline, label: 'Nombre', value: nombre, accentColor: PerfilView._rolAccentColor(rolRaw)),
                if (apellidos.isNotEmpty) ...[
                  AppGaps.hMd,
                  _InfoRow(icon: Icons.people_outline, label: 'Apellidos', value: apellidos, accentColor: PerfilView._rolAccentColor(rolRaw)),
                ],
                AppGaps.hMd,
                _InfoRow(icon: Icons.email_outlined, label: 'Correo', value: email, accentColor: PerfilView._rolAccentColor(rolRaw)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color accentColor;

  const _InfoRow({required this.icon, required this.label, required this.value, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: AppShapes.circular12,
            ),
            child: Icon(icon, color: accentColor, size: 20),
          ),
        AppGaps.wMd,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.smallLabel),
              AppGaps.hXs2,
              Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── PREFERENCES ─────────────────────────────────────────────────────────────

class _PreferencesCard extends StatelessWidget {
  const _PreferencesCard();

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: AppColors.neutral)),
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 4, right: 4, bottom: 4),
            child: Column(
              children: [
                _PreferenceTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Recibe alertas de reservas',
                  trailing: const _DisabledSwitch(value: true),
                ),
                _PreferenceDivider(),
                _PreferenceTile(
                  icon: Icons.dark_mode_outlined,
                  title: 'Modo oscuro',
                  subtitle: 'Activa el tema oscuro',
                  trailing: const _DisabledSwitch(value: false),
                ),
                _PreferenceDivider(),
                _PreferenceTile(
                  icon: Icons.language_outlined,
                  title: 'Idioma',
                  subtitle: 'Español',
                  trailing: const _DisabledChevron(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _PreferenceTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.disabled.withValues(alpha: 0.15),
              borderRadius: AppShapes.circular12,
            ),
            child: Icon(icon, color: AppColors.disabled, size: 20),
          ),
          AppGaps.wMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14, color: AppColors.disabled)),
                AppGaps.hXs2,
                Text(subtitle, style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.disabled)),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _DisabledSwitch extends StatelessWidget {
  final bool value;

  const _DisabledSwitch({required this.value});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Switch.adaptive(
        value: value,
        onChanged: null,
        activeTrackColor: AppColors.disabled.withValues(alpha: 0.4),
        inactiveTrackColor: AppColors.disabled.withValues(alpha: 0.15),
      ),
    );
  }
}

class _DisabledChevron extends StatelessWidget {
  const _DisabledChevron();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Español', style: AppTextStyles.cardSubtitle.copyWith(color: AppColors.disabled, fontWeight: FontWeight.w600)),
        AppGaps.wXs,
        Icon(Icons.chevron_right_rounded, color: AppColors.disabled, size: 20),
      ],
    );
  }
}

class _PreferenceDivider extends StatelessWidget {
  const _PreferenceDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Divider(height: 1, color: AppColors.border.withValues(alpha: 0.5)),
    );
  }
}

// ─── ACCOUNT ACTIONS ─────────────────────────────────────────────────────────

class _AccountActionsCard extends ConsumerWidget {
  const _AccountActionsCard();

  Future<void> _onLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: AppShapes.circular24),
        title: const Icon(Icons.logout_rounded, size: 48, color: AppColors.danger),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cerrar sesión', style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
            AppGaps.hSm,
            Text('¿Estás seguro de que quieres cerrar sesión?', style: AppTextStyles.sectionBody, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await ref.read(authProvider.notifier).logout();
      } catch (_) {}
      if (context.mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
          Positioned(left: 0, top: 0, bottom: 0, child: Container(width: 4, color: AppColors.danger)),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 4, top: 4, bottom: 4),
            child: _ActionTile(
              icon: Icons.logout_rounded,
              title: 'Cerrar sesión',
              subtitle: 'Salir de la aplicación',
              isDanger: true,
              onTap: () => _onLogout(context, ref),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? AppColors.danger : AppColors.primaryDark;

    return InkWell(
      onTap: onTap,
      borderRadius: AppShapes.circular20,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: AppShapes.circular12,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            AppGaps.wMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 14)),
                  AppGaps.hXs2,
                  Text(subtitle, style: AppTextStyles.cardSubtitle),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color.withValues(alpha: 0.5), size: 22),
          ],
        ),
      ),
    );
  }
}

// ─── SECTION TITLE ───────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionTitle),
        AppGaps.hXs,
        Text(subtitle, style: AppTextStyles.sectionBody),
      ],
    );
  }
}

// ─── DEBUG ───────────────────────────────────────────────────────────────────

class _DebugTools extends ConsumerWidget {
  const _DebugTools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            borderRadius: AppShapes.circular8,
          ),
          child: const Text('DEBUG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.warning, letterSpacing: 2)),
        ),
        AppGaps.hMd,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final storage = StorageService();
              await storage.clearAccessToken();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Access token eliminado')),
                );
              }
            },
            icon: const Icon(Icons.key_off_rounded, size: 18),
            label: const Text('Eliminar access token'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.warning,
              side: const BorderSide(color: AppColors.warning),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
            ),
          ),
        ),
        AppGaps.hSm,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final storage = StorageService();
              await storage.saveAccessToken('invalid.token.here');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Access token corrupto — hasValidToken retornará false')),
                );
              }
            },
            icon: const Icon(Icons.error_outline, size: 18),
            label: const Text('Corromper access token'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
            ),
          ),
        ),
        AppGaps.hSm,
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              ref.read(sessionExpiredProvider.notifier).state = true;
            },
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Simular sesión expirada'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.danger,
              side: const BorderSide(color: AppColors.danger),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: AppShapes.circular12),
            ),
          ),
        ),
      ],
    );
  }
}
