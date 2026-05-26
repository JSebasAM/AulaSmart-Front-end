import 'dart:io';
import 'package:dio/dio.dart';
import 'package:aulasmart_front_end/features/aulas/presentation/providers/aulas_provider.dart';
import 'package:aulasmart_front_end/features/aulas/domain/entities/aula_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/domain/entities/incidencia_entity.dart';
import 'package:aulasmart_front_end/features/incidencias/presentation/providers/incidencia_provider.dart';
import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:aulasmart_front_end/themes/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class NewReportModalView extends ConsumerStatefulWidget {
  final VoidCallback onClose;
  const NewReportModalView({super.key, required this.onClose});

  @override
  ConsumerState<NewReportModalView> createState() => _NewReportModalViewState();
}

class _NewReportModalViewState extends ConsumerState<NewReportModalView> {
  final _descCtrl = TextEditingController();
  String? _selectedType;
  int? _selectedAulaId;
  AulaEntity? _selectedAula;
  bool _isGenerating = false;
  bool _showPreview = false;
  String? _cartaGenerada;
  File? _imagenFile;
  IncidenciaEntity? _incidenciaCreada;

  static const _typeOptions = [
    ('🖥️', 'Hardware', 'HARDWARE'),
    ('💻', 'Software', 'SOFTWARE'),
    ('🏗️', 'Infraestructura', 'INFRAESTRUCTURA'),
    ('📋', 'Otro', 'OTRO'),
  ];

  @override
  void dispose() {
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final f = await ImagePicker().pickImage(source: source, maxWidth: 1024);
    if (f != null) setState(() => _imagenFile = File(f.path));
  }

  Future<void> _generarCarta() async {
    if (_descCtrl.text.trim().length < 10 || _selectedType == null || _selectedAulaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: const Text('Completa todos los campos (min 10 caracteres).'), backgroundColor: Colors.red.shade400),
      );
      return;
    }
    setState(() => _isGenerating = true);
    try {
      _incidenciaCreada = await crearIncidencia(ref, {
        'codigoAula': _selectedAula!.id,
        'descripcionBreve': _descCtrl.text.trim(),
        'tipoIncidencia': _selectedType,
      });
      _cartaGenerada = _incidenciaCreada!.cartaFormalGenerada;
      ref.invalidate(incidenciasPendientesProvider);
      ref.invalidate(todasLasIncidenciasProvider);
      if (mounted) setState(() { _isGenerating = false; _showPreview = true; });
    } on DioException catch (e) {
      if (mounted) {
        String msg = 'Error: ${e.message}';
        if (e.response?.data is Map) {
          final data = e.response!.data as Map;
          msg = 'Servidor: ${data['mensaje'] ?? data['error'] ?? data['message'] ?? data.toString()}';
        }
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 6),
        ));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error inesperado: $e'),
          backgroundColor: Colors.red,
        ));
      }
    }
  }

  Future<void> _confirmarEnvio() async {
    if (_imagenFile != null && _incidenciaCreada != null) {
      try {
        await subirImagen(ref, _incidenciaCreada!.id.toString(), _imagenFile!.path);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incidencia e imagen guardadas exitosamente.'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Incidencia creada, pero fallo la subida de imagen: $e'), backgroundColor: Colors.orange),
          );
        }
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incidencia enviada a administracion.'), backgroundColor: Colors.green),
        );
      }
    }
    widget.onClose();
  }

  void _pickAula() {
    final aulasAsync = ref.read(aulasProvider);
    final aulas = aulasAsync.value ?? [];
    final searchCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSheetState) {
          final query = searchCtrl.text.toLowerCase();
          final filtered = query.isEmpty ? aulas : aulas.where((a) =>
              a.nombreAula.toLowerCase().contains(query) ||
              a.codigoAula.toString().contains(query) ||
              a.bloque.nombre.toLowerCase().contains(query)).toList();

          return DraggableScrollableSheet(
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.9,
            expand: false,
            builder: (_, scrollCtrl) => Column(children: [
              Container(margin: const EdgeInsets.only(top: 12), width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: searchCtrl,
                  onChanged: (_) => setSheetState(() {}),
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: 'Buscar aula por nombre, código o bloque...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () { searchCtrl.clear(); setSheetState(() {}); }) : null,
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  ),
                ),
              ),
              const Divider(),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text('No se encontraron aulas', style: TextStyle(color: Colors.grey)))
                    : ListView.separated(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
                        itemBuilder: (_, i) {
                          final a = filtered[i];
                          final isSelected = _selectedAulaId == a.id;
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                              child: Icon(Icons.meeting_room_outlined, color: isSelected ? Colors.white : Colors.grey.shade600, size: 20),
                            ),
                            title: Text(a.nombreAula, style: TextStyle(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500)),
                            subtitle: Text('${a.bloque.nombre} \u2022 ${a.tipoAula.nombre} \u2022 Cap: ${a.capacidad}'),
                            trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
onTap: () {
    setState(() { _selectedAula = a; _selectedAulaId = a.id; });
    Navigator.pop(ctx);
},
                          );
                        },
                      ),
              ),
            ]),
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showPreview && _cartaGenerada != null) return _buildPreview();
    return _buildForm();
  }

  Widget _buildPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Carta Formal Generada', style: AppTextStyles.sectionTitle.copyWith(fontSize: 20)),
          IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
        ]),
        const SizedBox(height: 16),
        Container(
          width: double.infinity, padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.cartaBackground, borderRadius: BorderRadius.circular(16)),
          child: SelectableText(_cartaGenerada!, style: const TextStyle(fontSize: 14, height: 1.6)),
        ),
        const SizedBox(height: 24),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => setState(() => _showPreview = false), icon: const Icon(Icons.edit, size: 18), label: const Text('Editar'), style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 12),
          Expanded(child: FilledButton.icon(onPressed: _confirmarEnvio, icon: const Icon(Icons.check_circle, size: 18), label: const Text('Confirmar envio'), style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
      ]),
    );
  }

  Widget _buildForm() {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 48, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        Text('Reportar Incidencia', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Describe el problema y la IA generara una carta formal.', style: AppTextStyles.pageSubtitle),
        const SizedBox(height: 24),
        Text('Tipo de incidencia', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        Wrap(spacing: 8, runSpacing: 8, children: _typeOptions.map((t) {
          final sel = _selectedType == t.$3;
          return ChoiceChip(label: Text('${t.$1} ${t.$2}'), selected: sel, onSelected: (_) => setState(() => _selectedType = t.$3), selectedColor: AppColors.primary.withValues(alpha: 0.15), labelStyle: TextStyle(fontWeight: sel ? FontWeight.w700 : FontWeight.w500));
        }).toList()),
        const SizedBox(height: 20),
        Text('Aula', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        InkWell(
          onTap: _pickAula,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: _selectedAula != null ? AppColors.primary : Colors.grey.shade300, width: _selectedAula != null ? 2 : 1),
              borderRadius: BorderRadius.circular(12),
              color: _selectedAula != null ? AppColors.primary.withValues(alpha: 0.04) : null,
            ),
            child: Row(children: [
              Icon(Icons.meeting_room_outlined, color: _selectedAula != null ? AppColors.primary : Colors.grey.shade400, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: _selectedAula != null
                    ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(_selectedAula!.nombreAula, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: AppColors.primaryDark)),
                        const SizedBox(height: 2),
                        Text('${_selectedAula!.bloque.nombre} \u2022 ${_selectedAula!.tipoAula.nombre} \u2022 Cap: ${_selectedAula!.capacidad}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      ])
                    : const Text('Toca para buscar un aula...', style: TextStyle(color: Colors.grey)),
              ),
              const Icon(Icons.search, color: Colors.grey),
            ]),
          ),
        ),
        const SizedBox(height: 20),
        Text('Descripcion breve', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        TextFormField(controller: _descCtrl, maxLines: 5, maxLength: 500, decoration: InputDecoration(hintText: 'Describe el problema...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
        const SizedBox(height: 12),
        Text('Evidencia (opcional)', style: AppTextStyles.sectionTitle.copyWith(fontSize: 15)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.camera), icon: const Icon(Icons.camera_alt, size: 18), label: const Text('Camara'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
          const SizedBox(width: 12),
          Expanded(child: OutlinedButton.icon(onPressed: () => _pickImage(ImageSource.gallery), icon: const Icon(Icons.photo_library, size: 18), label: const Text('Galeria'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))))),
        ]),
        if (_imagenFile != null) ...[const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imagenFile!, height: 120, width: double.infinity, fit: BoxFit.cover))],
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 52, child: FilledButton.icon(
          onPressed: _isGenerating ? null : _generarCarta,
          icon: _isGenerating ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_awesome),
          label: Text(_isGenerating ? 'Generando carta...' : 'Generar Carta Formal con IA'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.cartaPrimary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        )),
        const SizedBox(height: 12),
      ]),
    );
  }
}
