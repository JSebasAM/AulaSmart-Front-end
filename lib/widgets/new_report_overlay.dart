import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class NewReportOverlay extends StatefulWidget {
  final VoidCallback onClose;

  const NewReportOverlay({
    super.key,
    required this.onClose,
  });

  @override
  State<NewReportOverlay> createState() => _NewReportOverlayState();
}

class _NewReportOverlayState extends State<NewReportOverlay> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedType;
  String? _selectedLocation;

  final List<String> _locations = const [
    'A-101 Ingenieria',
    'B-205 Ciencias',
    'C-301 Admin',
    'D-102 Humanidades',
  ];

  final List<_TypeOption> _types = const [
    _TypeOption('🥱', 'Queja'),
    _TypeOption('💡', 'Recomendacion'),
    _TypeOption('🙏', 'Peticion'),
    _TypeOption('🔨', 'Daño Fisico'),
    _TypeOption('🧹', 'Limpieza'),
    _TypeOption('📋', 'Otro'),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            decoration: const BoxDecoration(
              gradient: AppColors.activeIconGradient,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reportar Incidencia',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Reporte general del campus',
                        style: TextStyle(
                          color: Color(0xFFE5EAFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: widget.onClose,
                  borderRadius: BorderRadius.circular(17),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.pageCard,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Titulo del Reporte *'),
                    const SizedBox(height: 8),
                    _inputField(
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Ej: Proyector no funciona correctamente',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Tipo de Reporte *'),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _types.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.52,
                      ),
                      itemBuilder: (context, index) {
                        final item = _types[index];
                        final isSelected = _selectedType == item.label;
                        return InkWell(
                          onTap: () => setState(() => _selectedType = item.label),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.pageCard,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryDark : const Color(0xFFB5C0FF),
                                width: isSelected ? 1.4 : 1,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(item.emoji, style: const TextStyle(fontSize: 24)),
                                const SizedBox(height: 4),
                                Text(
                                  item.label,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _label('Ubicación *'),
                    const SizedBox(height: 8),
                    _inputField(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedLocation,
                          isExpanded: true,
                          hint: const Text(
                            'Selecciona una ubicación...',
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                          items: _locations
                              .map(
                                (location) => DropdownMenuItem<String>(
                                  value: location,
                                  child: Text(location),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() => _selectedLocation = value),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Descripción Breve *'),
                    const SizedBox(height: 8),
                    _inputField(
                      child: TextField(
                        controller: _descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText:
                              'Describe detalladamente la situación. Esta información será utilizada para generar una carta formal...',
                          hintStyle: TextStyle(color: AppColors.textSecondary),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Mínimo 30 caracteres para generar la carta formal',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _label('Adjuntar Imagen (Opcional)'),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 22),
                      decoration: BoxDecoration(
                        color: AppColors.pageCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFA9B5FF), width: 1, style: BorderStyle.solid),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.add_a_photo_outlined, size: 34, color: AppColors.textSecondary),
                          SizedBox(height: 8),
                          Text(
                            'Toca para adjuntar evidencia\nfotográfica',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'JPG, PNG o WEBP (máx. 5MB)',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: AppColors.activeIconGradient,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFF9FAFFF)),
                      ),
                      child: const Center(
                        child: Text(
                          '✨  Generar Carta Formal con IA',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _inputField({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.pageCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFA9B5FF)),
      ),
      child: child,
    );
  }
}

class _TypeOption {
  final String emoji;
  final String label;

  const _TypeOption(this.emoji, this.label);
}
