import 'dart:io';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:aulasmart_front_end/widgets/carta_preview_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class NewReportModalView extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const NewReportModalView({super.key, required this.onClose});

  @override
  ConsumerState<NewReportModalView> createState() =>
      _NewReportModalViewState();
}

class _NewReportModalViewState extends ConsumerState<NewReportModalView> {
  final _descController = TextEditingController();
  String? _selectedType;
  String? _selectedLocation;
  bool _isGenerating = false;
  bool _showPreview = false;
  String? _cartaGenerada;
  File? _imagenFile;
  int? _incidenciaId;

  static const _typeOptions = [
    ('😤', 'Queja', 'QUEJA'),
    ('💡', 'Recomendacion', 'RECOMENDACION'),
    ('🙏', 'Peticion', 'RECLAMO'),
    ('🔨', 'Dano Fisico', 'DANO_FISICO'),
  ];

  static const _locations = {
    'A-101 Ingenieria': 101,
    'B-205 Ciencias': 205,
    'C-301 Admin': 301,
    'D-102 Humanidades': 102,
    'Biblioteca Central': 500,
  };

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final file = await picker.pickImage(source: source, maxWidth: 1024);
    if (file != null) {
      setState(() => _imagenFile = File(file.path));
    }
  }

  Future<void> _generarCarta() async {
    final desc = _descController.text.trim();
    if (desc.length < 10 || _selectedType == null || _selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Completa todos los campos. La descripcion debe tener al menos 10 caracteres.'),
          backgroundColor: Colors.red.shade400,
        ),
      );
      return;
    }

    setState(() => _isGenerating = true);

    try {
      final codigoAula = _locations[_selectedLocation] ?? 0;
      final tipo =
          _typeOptions.firstWhere((t) => t.$1 == _selectedType).$3;

      final incidencia = await crearIncidencia(ref, {
        'codigo_aula': codigoAula,
        'descripcion_breve': desc,
        'tipo_incidencia': tipo,
      });

      _incidenciaId = incidencia.id;
      _cartaGenerada = incidencia.cartaFormalGenerada;

      if (_imagenFile != null && _incidenciaId != null) {
        await subirImagenIncidencia(ref, _incidenciaId.toString(), _imagenFile!.path);
      }

      if (mounted) {
        ref.invalidate(incidenciasPendientesProvider);
        ref.invalidate(todasLasIncidenciasProvider);
        setState(() {
          _isGenerating = false;
          _showPreview = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Incidencia reportada. La IA genero la carta formal.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _volverAEditar() => setState(() => _showPreview = false);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_showPreview && _cartaGenerada != null) {
      return _buildPreview(theme);
    }

    return _buildForm(theme);
  }

  Widget _buildForm(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 48, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Reportar Incidencia',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text('Describe el problema y la IA generara una carta formal.',
              style: AppTextStyles.pageSubtitle),
          const SizedBox(height: 24),
          Text('Tipo de incidencia',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _typeOptions.map((t) {
              final selected = _selectedType == t.$1;
              return ChoiceChip(
                label: Text('${t.$1} ${t.$2}'),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _selectedType = t.$1),
                selectedColor: AppColors.primary.withValues(alpha: 0.15),
                labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          Text('Ubicacion', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            value: _selectedLocation,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            hint: const Text('Selecciona un aula o edificio'),
            items: _locations.keys
                .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                .toList(),
            onChanged: (v) => setState(() => _selectedLocation = v),
          ),
          const SizedBox(height: 20),
          Text('Descripcion breve',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          TextFormField(
            controller: _descController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: 'Describe el problema que encontraste...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 16),
          Text('Evidencia (opcional)',
              style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
          const SizedBox(height: 10),
          Row(
            children: [
              _ImageButton(
                icon: Icons.camera_alt,
                label: 'Camara',
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 12),
              _ImageButton(
                icon: Icons.photo_library,
                label: 'Galeria',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
          if (_imagenFile != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(_imagenFile!,
                  height: 120, width: double.infinity, fit: BoxFit.cover),
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _isGenerating ? null : _generarCarta,
              icon: _isGenerating
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.auto_awesome),
              label: Text(_isGenerating
                  ? 'Generando carta...'
                  : 'Generar Carta Formal con IA'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.cartaPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildPreview(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Carta Formal Generada',
                  style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
              IconButton(
                onPressed: widget.onClose,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Revisa y envia tu reporte.',
              style: AppTextStyles.pageSubtitle),
          const SizedBox(height: 16),
          CartaPreviewPreview(
            tipo: _selectedType ?? '',
            ubicacion: _selectedLocation ?? '',
            titulo: _selectedType ?? '',
            descripcion: _descController.text,
            cartaFormal: _cartaGenerada ?? '',
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _volverAEditar,
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Editar'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Incidencia enviada a administracion.'),
                          backgroundColor: Colors.green),
                    );
                    widget.onClose();
                  },
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text('Enviar'),
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImageButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ImageButton(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}

class CartaPreviewPreview extends StatelessWidget {
  final String tipo;
  final String ubicacion;
  final String titulo;
  final String descripcion;
  final String cartaFormal;

  const CartaPreviewPreview({
    super.key,
    required this.tipo,
    required this.ubicacion,
    required this.titulo,
    required this.descripcion,
    required this.cartaFormal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cartaBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppColors.cartaPrimary.withValues(alpha: 0.15)),
      ),
      child: SingleChildScrollView(
        child: SelectableText(
          cartaFormal,
          style: const TextStyle(
            fontSize: 14,
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
