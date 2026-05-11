import 'package:aulasmart_front_end/models/profile_data.dart';
import 'package:aulasmart_front_end/services/profile_service.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:flutter/material.dart';

class PerfilView extends StatefulWidget {
  const PerfilView({super.key});

  @override
  State<PerfilView> createState() => _PerfilViewState();
}

class _PerfilViewState extends State<PerfilView> {
  final ProfileService _profileService = ProfileService();
  late final Future<ProfileData> _futurePerfil;

  @override
  void initState() {
    super.initState();
    _futurePerfil = _profileService.obtenerPerfil();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileData>(
      future: _futurePerfil,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        final perfil = snapshot.data;
        if (perfil == null) {
          return const Center(
            child: Text(
              'No fue posible cargar el perfil.',
              style: TextStyle(
                color: AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          );
        }

        return Container(
          color: AppColors.background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProfileHeader(perfil: perfil),
                  const SizedBox(height: 22),
                  _ProfileCard(perfil: perfil),
                  const SizedBox(height: 18),
                  const _ProfileSectionTitle(
                    title: 'Cuenta',
                    subtitle: 'Gestiona tu información y accesos',
                  ),
                  const SizedBox(height: 12),
                  _ProfileOptionTile(
                    icon: Icons.edit_outlined,
                    title: 'Editar perfil',
                    subtitle: 'Actualiza tus datos personales',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),
                  _ProfileOptionTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Cambiar contraseña',
                    subtitle: 'Refuerza la seguridad de tu cuenta',
                    onTap: () {},
                  ),
                  const SizedBox(height: 18),
                  const _ProfileSectionTitle(
                    title: 'Sesión',
                    subtitle: 'Acciones relacionadas con tu acceso',
                  ),
                  const SizedBox(height: 12),
                  _ProfileOptionTile(
                    icon: Icons.logout_rounded,
                    title: 'Cerrar sesión',
                    subtitle: 'Salir de la aplicación',
                    isDanger: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.perfil});

  final ProfileData perfil;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Perfil',
                style: AppTextStyles.pageTitle,
              ),
              SizedBox(height: 6),
              Text(
                'Visualiza y administra tu información',
                style: AppTextStyles.pageSubtitle,
              ),
            ],
          ),
        ),
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            gradient: AppColors.cartaButtonGradient,
            borderRadius: BorderRadius.circular(18),
            boxShadow: const [
              BoxShadow(
                color: Color(0x235E66F2),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(Icons.person_outline_rounded, color: Colors.white, size: 28),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.perfil});

  final ProfileData perfil;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145E66F2),
            blurRadius: 28,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  gradient: AppColors.cartaButtonGradient,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: Image.network(
                    perfil.avatarUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, _, __) => Container(
                      color: Colors.white,
                      alignment: Alignment.center,
                      child: const Icon(Icons.person, color: AppColors.primaryDark, size: 34),
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: 4,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB2C36),
                    border: Border.all(color: Colors.white, width: 1.6),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            perfil.nombre,
            textAlign: TextAlign.center,
            style: AppTextStyles.sectionTitle.copyWith(fontSize: 22),
          ),
          const SizedBox(height: 6),
          Text(
            perfil.rol,
            style: AppTextStyles.sectionBody,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  value: perfil.aulasReservadas.toString(),
                  label: 'Aulas reservadas',
                  icon: Icons.calendar_month_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  value: perfil.incidencias.toString(),
                  label: 'Incidencias',
                  icon: Icons.warning_amber_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.cardTitle.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.smallLabel,
          ),
        ],
      ),
    );
  }
}

class _ProfileSectionTitle extends StatelessWidget {
  const _ProfileSectionTitle({
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: AppTextStyles.sectionBody,
        ),
      ],
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDanger = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final color = isDanger ? const Color(0xFFFB2C36) : AppColors.primaryDark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.78),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white.withValues(alpha: 0.88), width: 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.cardTitle.copyWith(color: color, fontSize: 15),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: AppTextStyles.cardSubtitle,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, color: color, size: 22),
          ],
        ),
      ),
    );     
  }
}
