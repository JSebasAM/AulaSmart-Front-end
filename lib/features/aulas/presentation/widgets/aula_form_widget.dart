import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../widgets/auth_text_field.dart';
import '../../../../widgets/primary_button.dart';
import '../../../../themes/app_colors.dart';
import '../providers/aulas_provider.dart';

class AulaFormWidget extends ConsumerStatefulWidget {
  final void Function(Map<String, dynamic>) onFormSubmit;
  final String submitButtonLabel;
  final Map<String, dynamic>? initialData;

  const AulaFormWidget({
    super.key,
    required this.onFormSubmit,
    this.submitButtonLabel = 'Registrar',
    this.initialData,
  });

  @override
  ConsumerState<AulaFormWidget> createState() => _AulaFormWidgetState();
}

class _AulaFormWidgetState extends ConsumerState<AulaFormWidget> {
  late TextEditingController codigoController;
  late TextEditingController nombreController;
  late TextEditingController capacidadController;
  int? selectedTipoAulaId;
  int? selectedBloqueId;

  @override
  void initState() {
    super.initState();
    codigoController = TextEditingController(
      text: widget.initialData?['codigoAula']?.toString() ?? '',
    );
    nombreController = TextEditingController(
      text: widget.initialData?['nombreAula'] ?? '',
    );
    capacidadController = TextEditingController(
      text: widget.initialData?['capacidad']?.toString() ?? '',
    );
    selectedTipoAulaId = widget.initialData?['tipoAulaId'] as int?;
    selectedBloqueId = widget.initialData?['bloqueId'] as int?;
  }

  @override
  void dispose() {
    codigoController.dispose();
    nombreController.dispose();
    capacidadController.dispose();
    super.dispose();
  }

  void _submitForm() {
    final codigo = int.tryParse(codigoController.text);
    final capacidad = int.tryParse(capacidadController.text);

    if (codigo == null || nombreController.text.isEmpty || capacidad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos correctamente'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (selectedTipoAulaId == null || selectedBloqueId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un tipo de aula y un bloque'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    final formData = <String, dynamic>{
      'codigoAula': codigo,
      'nombreAula': nombreController.text,
      'capacidad': capacidad,
      'tipoAula': {'id': selectedTipoAulaId},
      'bloque': {'id': selectedBloqueId},
    };

    if (widget.initialData?['id'] != null) {
      formData['id'] = widget.initialData!['id'];
    }

    widget.onFormSubmit(formData);
  }

  @override
  Widget build(BuildContext context) {
    final tiposAsync = ref.watch(tiposAulaProvider);
    final bloquesAsync = ref.watch(bloquesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            label: 'Código de aula (SIGA)',
            hintText: 'Ej. 12345',
            controller: codigoController,
            icon: Icons.tag_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Nombre del aula',
            hintText: 'Ej. Aula 101',
            controller: nombreController,
            icon: Icons.meeting_room_rounded,
          ),
          const SizedBox(height: 16),
          AuthTextField(
            label: 'Capacidad',
            hintText: 'Ej. 40',
            controller: capacidadController,
            icon: Icons.people_alt_rounded,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: 'Tipo de aula',
            value: selectedTipoAulaId?.toString(),
            asyncData: tiposAsync,
            displayName: (e) => e.nombre,
            id: (e) => e.id.toString(),
            onChanged: (v) => setState(() => selectedTipoAulaId = v != null ? int.parse(v) : null),
          ),
          const SizedBox(height: 20),
          _buildDropdown(
            label: 'Bloque',
            value: selectedBloqueId?.toString(),
            asyncData: bloquesAsync,
            displayName: (e) => e.nombre,
            id: (e) => e.id.toString(),
            onChanged: (v) => setState(() => selectedBloqueId = v != null ? int.parse(v) : null),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 55,
            child: PrimaryButton(
              label: widget.submitButtonLabel,
              onPressed: _submitForm,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required String? value,
    required AsyncValue<List<T>> asyncData,
    required String Function(T) displayName,
    required String Function(T) id,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.neutral.withOpacity(0.2)),
          ),
          child: asyncData.when(
            data: (items) => DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: value,
                isExpanded: true,
                hint: Text('Seleccionar $label'),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.textSecondary),
                style: const TextStyle(color: AppColors.textPrimary, fontSize: 16),
                items: items.map((e) {
                  return DropdownMenuItem(
                    value: id(e),
                    child: Text(displayName(e)),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: LinearProgressIndicator(),
            ),
            error: (_, __) => const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Error al cargar', style: TextStyle(color: AppColors.danger)),
            ),
          ),
        ),
      ],
    );
  }
}
