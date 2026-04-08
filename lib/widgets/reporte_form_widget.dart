import 'package:flutter/material.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';

class ReporteFormWidget extends StatelessWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final String? selectedType;
  final String? selectedLocation;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<String?> onLocationChanged;
  final VoidCallback? onGenerarCarta;
  final bool isLoading;

  const ReporteFormWidget({
    required this.titleController,
    required this.descriptionController,
    required this.selectedType,
    required this.selectedLocation,
    required this.onTypeChanged,
    required this.onLocationChanged,
    this.onGenerarCarta,
    this.isLoading = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título del Reporte
            _buildInputField(
              label: 'Título del Reporte *',
              controller: titleController,
              hint: 'Ingresa un título para tu reporte',
            ),
            const SizedBox(height: 24),

            // Tipo de Reporte
            _buildLabel('Tipo de Reporte *'),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // Ubicación
            _buildLabel('Ubicación *'),
            const SizedBox(height: 12),
            _buildLocationDropdown(),
            const SizedBox(height: 24),

            // Descripción
            _buildLabel('Descripción Breve *'),
            const SizedBox(height: 12),
            _buildTextArea(),
            const SizedBox(height: 8),
            Text(
              'Mínimo 30 caracteres para generar la carta formal',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),

            // Botón Generar Carta
            SizedBox(
              width: double.infinity,
              height: 56,
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.cartaButtonGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cartaPrimary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isLoading ? null : onGenerarCarta,
                    borderRadius: BorderRadius.circular(16),
                    child: Center(
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Generar carta formal con IA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 12),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.cartaSecondary.withValues(alpha: 0.3),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: AppColors.cartaSecondary.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: AppColors.cartaPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.cartaPrimaryDark,
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = [
      ('Queja', '😤'),
      ('Recomendación', '💡'),
      ('Petición', '🙏'),
      ('Daño Físico', '🔨'),
      ('Limpieza', '🧹'),
      ('Otro', '📋'),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: types.map((type) {
        final isSelected = selectedType == type.$1;
        return SizedBox(
          width: 170,
          child: GestureDetector(
            onTap: () => onTypeChanged(type.$1),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.cartaSecondary.withValues(alpha: 0.2)
                    : Colors.white,
                border: Border.all(
                  color: isSelected
                      ? AppColors.cartaPrimary
                      : AppColors.cartaSecondary.withValues(alpha: 0.3),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    type.$2,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.$1,
                    style: TextStyle(
                      fontSize: 14,
                      color: isSelected
                          ? AppColors.cartaPrimary
                          : AppColors.cartaPrimaryDark,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLocationDropdown() {
    final locations = [
      'Aula 101',
      'Aula 102',
      'Aula 103',
      'Biblioteca',
      'Cafetería',
      'Patio',
      'Laboratorio',
      'Oficina',
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.cartaSecondary.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        underline: const SizedBox(),
        value: selectedLocation,
        hint: const Padding(
          padding: EdgeInsets.only(left: 16),
          child: Text('Selecciona una ubicación'),
        ),
        onChanged: onLocationChanged,
        items: locations
            .map(
              (location) => DropdownMenuItem(
                value: location,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(location),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTextArea() {
    return TextField(
      controller: descriptionController,
      maxLines: 5,
      decoration: InputDecoration(
        hintText:
            'Describe detalladamente la situación. Esta información será utilizada para generar una carta formal...',
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.cartaSecondary.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.cartaSecondary.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.cartaPrimary,
          ),
        ),
      ),
    );
  }
}
