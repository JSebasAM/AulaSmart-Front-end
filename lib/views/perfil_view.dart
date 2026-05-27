import 'package:aulasmart_front_end/features/auth/presentation/providers/auth_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
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
    final userAsync = ref.watch(currentUserProvider);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: userAsync.when(
          data: (user) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildContent(user),
                if (kDebugMode) const _DebugTools(),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.primary)),
          error: (err, _) => _buildError(err),
        ),
      ),
    );
  }

  Widget _buildContent(Map<String, dynamic>? user) {
    final nombreCompleto = user?['nombre_completo'] as String? ?? 'Usuario';
    final email = user?['email'] as String? ?? '';
    final rolRaw = user?['rol'] as String? ?? '';
    final rol = _formatRol(rolRaw);
    final nombre = nombreCompleto.split(' ').first;
    final apellidos = nombreCompleto.split(' ').skip(1).join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeaderSection(nombreCompleto: nombreCompleto, rol: rol),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Información Personal', subtitle: 'Tus datos registrados en el sistema'),
        const SizedBox(height: 12),
        _InfoCard(nombre: nombre, apellidos: apellidos, email: email),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Preferencias', subtitle: 'Personaliza tu experiencia'),
        const SizedBox(height: 12),
        const _PreferencesCard(),
        const SizedBox(height: 24),
        const _SectionTitle(title: 'Cuenta', subtitle: 'Gestiona tu seguridad y acceso'),
        const SizedBox(height: 12),
        const _AccountActionsCard(),
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
            const SizedBox(height: 16),
            const Text('No se pudo cargar la información del perfil'),
            const SizedBox(height: 8),
            Text(err.toString(), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }

  String _formatRol(String rol) {
    if (rol.isEmpty) return '';
    return rol[0] + rol.substring(1).toLowerCase();
  }
}

// ─── HEADER ──────────────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final String nombreCompleto;
  final String rol;

  const _HeaderSection({required this.nombreCompleto, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 28),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x335E66F2),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: Container(
                color: Colors.white.withValues(alpha: 0.2),
                child: const Icon(Icons.person_rounded, size: 44, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            nombreCompleto,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          if (rol.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                rol,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.business_rounded, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'AulaSmart • Universidad UCEVA',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
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

  const _InfoCard({required this.nombre, required this.apellidos, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x105E66F2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _InfoRow(icon: Icons.person_outline, label: 'Nombre', value: nombre),
          if (apellidos.isNotEmpty) const SizedBox(height: 14),
          if (apellidos.isNotEmpty)
            _InfoRow(icon: Icons.people_outline, label: 'Apellidos', value: apellidos),
          const SizedBox(height: 14),
          _InfoRow(icon: Icons.email_outlined, label: 'Correo', value: email),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.smallLabel),
            const SizedBox(height: 2),
            Text(value, style: AppTextStyles.cardTitle.copyWith(fontSize: 14)),
          ],
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x105E66F2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: const Column(
        children: [
          _PreferenceTile(
            icon: Icons.notifications_outlined,
            title: 'Notificaciones',
            subtitle: 'Recibe alertas de reservas',
            trailing: _DisabledSwitch(value: true),
          ),
          _PreferenceDivider(),
          _PreferenceTile(
            icon: Icons.dark_mode_outlined,
            title: 'Modo oscuro',
            subtitle: 'Activa el tema oscuro',
            trailing: _DisabledSwitch(value: false),
          ),
          _PreferenceDivider(),
          _PreferenceTile(
            icon: Icons.language_outlined,
            title: 'Idioma',
            subtitle: 'Español',
            trailing: _DisabledChevron(),
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
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.disabled, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.cardTitle.copyWith(fontSize: 14, color: AppColors.disabled)),
                const SizedBox(height: 2),
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
        const SizedBox(width: 4),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Icon(Icons.logout_rounded, size: 48, color: AppColors.danger),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Cerrar sesión',
                style: AppTextStyles.sectionTitle, textAlign: TextAlign.center),
            SizedBox(height: 8),
            Text('¿Estás seguro de que quieres cerrar sesión?',
                style: AppTextStyles.sectionBody, textAlign: TextAlign.center),
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
            child: const Text('Cerrar sesión',
                style: TextStyle(color: Colors.white)),
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
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x105E66F2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _ActionTile(
            icon: Icons.logout_rounded,
            title: 'Cerrar sesión',
            subtitle: 'Salir de la aplicación',
            isDanger: true,
            onTap: () => _onLogout(context, ref),
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
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 14)),
                  const SizedBox(height: 2),
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

// ─── DEBUG ───────────────────────────────────────────────────────────────────

class _DebugTools extends ConsumerWidget {
  const _DebugTools();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('DEBUG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.warning, letterSpacing: 2)),
          ),
          const SizedBox(height: 12),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 10),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
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
        const SizedBox(height: 4),
        Text(subtitle, style: AppTextStyles.sectionBody),
      ],
    );
  }
}
