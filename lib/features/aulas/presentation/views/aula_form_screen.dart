import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/aula_entity.dart';
import '../providers/aulas_provider.dart';
import '../widgets/aula_form_widget.dart';

class AulaFormScreen extends ConsumerWidget {
  final AulaEntity? aula;
  final VoidCallback onSaved;

  const AulaFormScreen({
    super.key,
    this.aula,
    required this.onSaved,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEditing = aula != null;
    final initialData = aula != null
        ? {
            'id': aula!.id,
            'codigoAula': aula!.codigoAula,
            'nombreAula': aula!.nombreAula,
            'capacidad': aula!.capacidad,
            'tipoAulaId': aula!.tipoAula.id,
            'bloqueId': aula!.bloque.id,
          }
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Editar Aula' : 'Nueva Aula'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: AulaFormWidget(
              initialData: initialData,
              submitButtonLabel: isEditing ? 'Guardar Cambios' : 'Registrar Aula',
              onFormSubmit: (payload) async {
                try {
                  if (isEditing) {
                    await ref.read(aulasProvider.notifier).editar(payload);
                  } else {
                    await ref.read(aulasProvider.notifier).create(payload);
                  }
                  onSaved();
                  if (context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEditing
                            ? 'Aula actualizada con éxito'
                            : 'Aula creada con éxito'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.redAccent,
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
