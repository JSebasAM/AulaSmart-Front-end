import 'facultad_entity.dart';

class BloqueEntity {
  final int id;
  final String codigoEdificio;
  final String nombre;
  final List<FacultadEntity> facultades;

  const BloqueEntity({
    required this.id,
    required this.codigoEdificio,
    required this.nombre,
    required this.facultades,
  });
}
