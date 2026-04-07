import 'package:aulasmart_front_end/themes/app_colors.dart';
import 'package:flutter/material.dart';

class NewReportModalView extends StatefulWidget {
  final VoidCallback onClose;

  const NewReportModalView({
    super.key,
    required this.onClose,
  });

  @override
  State<NewReportModalView> createState() => _NewReportModalViewState();
}

class _NewReportModalViewState extends State<NewReportModalView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String? _selectedType;
  String? _selectedLocation;

  static const List<_ReportTypeOption> _typeOptions = [
    _ReportTypeOption('😤', 'Queja'),
    _ReportTypeOption('💡', 'Recomendación'),
    _ReportTypeOption('🙏', 'Petición'),
    _ReportTypeOption('🔨', 'Daño Físico'),
    _ReportTypeOption('🧹', 'Limpieza'),
    _ReportTypeOption('📋', 'Otro'),
  ];

  static const List<String> _locations = [
    'A-101 Ingeniería',
    'B-205 Ciencias',
    'C-301 Admin',
    'D-102 Humanidades',
    'Biblioteca Central',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final horizontalPadding = size.width < 380 ? 16.0 : 24.0;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 16),
              decoration: const BoxDecoration(
                gradient: AppColors.activeIconGradient,
                borderRadius: BorderRadius.vertical(top: Radius.circular(0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Reportar Incidencia',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Reporte general del campus',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.88),
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  InkWell(
                    onTap: widget.onClose,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.pageCard,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(horizontalPadding, 24, horizontalPadding, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionLabel(text: 'Título del Reporte *'),
                      const SizedBox(height: 8),
                      _FieldShell(
                        height: 55.2,
                        child: TextField(
                          controller: _titleController,
                          maxLines: 1,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
                            hintText: 'Ej: Proyector no funciona correctamente',
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(text: 'Tipo de Reporte *'),
                      const SizedBox(height: 10),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _typeOptions.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 12,
                          childAspectRatio: 186.4 / 87.2,
                        ),
                        itemBuilder: (context, index) {
                          final option = _typeOptions[index];
                          final isSelected = _selectedType == option.label;

                          return InkWell(
                            onTap: () => setState(() => _selectedType = option.label),
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.pageCard,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryDark : const Color(0xFFB9C4FF),
                                  width: isSelected ? 1.4 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(option.emoji, style: const TextStyle(fontSize: 24)),
                                  const SizedBox(height: 12),
                                  Text(
                                    option.label,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      height: 1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(text: 'Ubicación *'),
                      const SizedBox(height: 8),
                      _FieldShell(
                        height: 55.2,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLocation,
                            isExpanded: true,
                            icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                            hint: const Text(
                              'Selecciona una ubicación...',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 15,
                              ),
                            ),
                            items: _locations
                                .map(
                                  (location) => DropdownMenuItem<String>(
                                    value: location,
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (value) => setState(() => _selectedLocation = value),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(text: 'Descripción Breve *'),
                      const SizedBox(height: 8),
                      _FieldShell(
                        height: 115.2,
                        child: TextField(
                          controller: _descriptionController,
                          maxLines: 4,
                          textAlignVertical: TextAlignVertical.top,
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                            hintText:
                                'Describe detalladamente la situación. Esta información será utilizada para generar una carta formal...',
                            hintMaxLines: 4,
                            hintStyle: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 15,
                              height: 1.25,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mínimo 30 caracteres para generar la carta formal',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _SectionLabel(text: 'Adjuntar Imagen (Opcional)'),
                      const SizedBox(height: 8),
                      _UploadPlaceholder(height: 159.2),
                      const SizedBox(height: 24),
                      _ActionButton(
                        onTap: () {},
                        label: 'Generar Carta Formal con IA',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }
}

class _FieldShell extends StatelessWidget {
  final double height;
  final Widget child;

  const _FieldShell({
    required this.height,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.pageCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFB9C4FF), width: 1.2),
      ),
      child: child,
    );
  }
}

class _UploadPlaceholder extends StatelessWidget {
  final double height;

  const _UploadPlaceholder({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.pageCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFB9C4FF),
          width: 1.2,
          style: BorderStyle.solid,
        ),
      ),
      child: const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_a_photo_outlined, size: 40, color: AppColors.textSecondary),
              SizedBox(height: 14),
              Text(
                'Toca para adjuntar evidencia fotográfica',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'JPG, PNG o WEBP (máx. 5MB)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final VoidCallback onTap;
  final String label;

  const _ActionButton({
    required this.onTap,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        height: 59.2,
        decoration: BoxDecoration(
          gradient: AppColors.activeIconGradient,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFA8B4FF)),
        ),
        child: Center(
          child: Text(
            '✨  $label',
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              height: 1.15,
            ),
          ),
        ),
      ),
    );
  }
}

class _ReportTypeOption {
  final String emoji;
  final String label;

  const _ReportTypeOption(this.emoji, this.label);
}
