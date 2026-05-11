import 'bloque_entity.dart';
import 'tipo_aula_entity.dart';

class AulaEntity {
  final int id;
  final int codigoAula;
  final String nombreAula;
  final int capacidad;
  final BloqueEntity bloque;
  final TipoAulaEntity tipoAula;
  final bool requiereAutorizacion;

  const AulaEntity({
    required this.id,
    required this.codigoAula,
    required this.nombreAula,
    required this.capacidad,
    required this.bloque,
    required this.tipoAula,
    required this.requiereAutorizacion,
  });
}
