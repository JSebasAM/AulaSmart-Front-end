import 'package:aulasmart_front_end/models/aula.dart';
import 'package:aulasmart_front_end/services/aula_service.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  static const List<String> _categorias = <String>[
    'Todos',
    'Aulas',
    'Laboratorios',
    'Auditorios',
    'Salas',
  ];

  final AulaService _aulaService = AulaService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Aula>> _futureAulas;
  String _categoriaActiva = _categorias.first;
  String _filtro = '';

  @override
  void initState() {
    super.initState();
    _futureAulas = _aulaService.listarAulas();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Aula> _aplicarFiltros(List<Aula> aulas) {
    return aulas.where((aula) {
      final coincideCategoria = _categoriaActiva == 'Todos' || aula.categoria.toLowerCase() == _categoriaActiva.toLowerCase();
      final coincideTexto = _filtro.isEmpty ||
          aula.nombre.toLowerCase().contains(_filtro.toLowerCase()) ||
          aula.edificio.toLowerCase().contains(_filtro.toLowerCase());

      return coincideCategoria && coincideTexto;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Aula>>(
      future: _futureAulas,
      builder: (context, snapshot) {
        final aulas = snapshot.data ?? const <Aula>[];
        final aulasFiltradas = _aplicarFiltros(aulas);

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchBar(),
              const SizedBox(height: 28),
              _buildCategorias(),
              const SizedBox(height: 24),
              _buildTablaHeader(aulasFiltradas.length),
              const SizedBox(height: 12),
              if (snapshot.connectionState == ConnectionState.waiting)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else if (aulasFiltradas.isEmpty)
                _buildEstadoVacio()
              else
                Column(
                  children: aulasFiltradas
                      .map(
                        (aula) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _AulaCard(aula: aula),
                        ),
                      )
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Buenos días,',
                style: TextStyle(
                  color: Color(0xFF99A6F2),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Juan 👋',
                style: TextStyle(
                  color: Color(0xFF4B4FA6),
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0x268B5CF6),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '👨‍🏫 Docente',
                  style: TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 48,
              height: 48,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                gradient: AppColors.cartaButtonGradient,
                borderRadius: BorderRadius.circular(999),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.network(
                  'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=200',
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) => const ColoredBox(color: Colors.white),
                ),
              ),
            ),
            Positioned(
              right: -1,
              top: -1,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: const Color(0xFFFB2C36),
                  border: Border.all(color: Colors.white, width: 1.4),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.80), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145E66F2),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFF99A6F2), size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _filtro = value.trim()),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Buscar aula...',
                hintStyle: TextStyle(
                  color: Color(0xFF99A6F2),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                isDense: true,
              ),
            ),
          ),
          _CircleActionButton(icon: Icons.tune_rounded),
          const SizedBox(width: 4),
          _CircleActionButton(icon: Icons.grid_view_rounded),
        ],
      ),
    );
  }

  Widget _buildCategorias() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Categorías',
          style: TextStyle(
            color: Color(0xFF4B4FA6),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _categorias.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, index) {
              final categoria = _categorias[index];
              final activa = categoria == _categoriaActiva;
              return GestureDetector(
                onTap: () => setState(() => _categoriaActiva = categoria),
                child: Container(
                  width: 74,
                  decoration: BoxDecoration(
                    gradient: activa ? AppColors.cartaButtonGradient : null,
                    color: activa ? null : Colors.white.withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: activa ? Colors.transparent : Colors.white.withValues(alpha: 0.5),
                      width: 0.8,
                    ),
                    boxShadow: activa
                        ? const [
                            BoxShadow(
                              color: Color(0x4D5E66F2),
                              blurRadius: 15,
                              offset: Offset(0, 8),
                            ),
                          ]
                        : const [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: activa ? Colors.white.withValues(alpha: 0.22) : const Color(0x0D5E66F2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Icon(
                          _iconoCategoria(categoria),
                          color: activa ? Colors.white : const Color(0xFF5E66F2),
                          size: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        categoria,
                        style: TextStyle(
                          color: activa ? Colors.white : const Color(0xFF4B4FA6),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTablaHeader(int cantidad) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Aulas Disponibles',
          style: TextStyle(
            color: Color(0xFF4B4FA6),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0x1A5E66F2),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            '$cantidad aulas',
            style: const TextStyle(
              color: Color(0xFF5E66F2),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEstadoVacio() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'No hay aulas para los filtros actuales.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF7080E4),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  IconData _iconoCategoria(String categoria) {
    switch (categoria) {
      case 'Aulas':
        return Icons.meeting_room_outlined;
      case 'Laboratorios':
        return Icons.science_outlined;
      case 'Auditorios':
        return Icons.mic_external_on_outlined;
      case 'Salas':
        return Icons.groups_2_outlined;
      default:
        return Icons.dashboard_outlined;
    }
  }
}

class _CircleActionButton extends StatelessWidget {
  const _CircleActionButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: AppColors.cartaButtonGradient,
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 14),
    );
  }
}

class _AulaCard extends StatelessWidget {
  const _AulaCard({required this.aula});

  final Aula aula;

  @override
  Widget build(BuildContext context) {
    final badgeColor = aula.estaLibre ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Container(
      height: 138,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.65), width: 0.8),
        boxShadow: const [
          BoxShadow(
            color: Color(0x145E66F2),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  aula.imagenUrl,
                  width: 78,
                  height: 112,
                  fit: BoxFit.cover,
                  errorBuilder: (context, _, __) {
                    return Container(
                      width: 78,
                      height: 112,
                      color: const Color(0x225E66F2),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF5E66F2), size: 18),
                    );
                  },
                ),
              ),
              Positioned(
                left: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: aula.estaLibre ? const Color(0xFF34D399) : const Color(0xFFF87171),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        aula.nombre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF4B4FA6),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        aula.estado,
                        style: TextStyle(
                          color: badgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  aula.ubicacion,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF99A6F2),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x0D5E66F2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.group_outlined, color: Color(0xFF5E66F2), size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${aula.capacidad}',
                            style: const TextStyle(
                              color: Color(0xFF5E66F2),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.videocam_outlined,
                      color: aula.tieneVideo ? const Color(0xFF5E66F2) : const Color(0x6699A6F2),
                      size: 14,
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.wifi,
                      color: aula.tieneWifi ? const Color(0xFF5E66F2) : const Color(0x6699A6F2),
                      size: 14,
                    ),
                    const Spacer(),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xFFE0E7FF), width: 0.8),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Icon(Icons.chevron_right_rounded, color: Color(0xFF5E66F2), size: 16),
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
