import '../../domain/entities/bloque_entity.dart';
import 'facultad_model.dart';

class BloqueModel extends BloqueEntity {
  const BloqueModel({
    required super.id,
    required super.codigoEdificio,
    required super.nombre,
    required super.facultades,
  });

  factory BloqueModel.fromJson(Map<String, dynamic> json) {
    return BloqueModel(
      id: json['id'] as int,
      codigoEdificio: json['codigoEdificio'] as String,
      nombre: json['nombre'] as String,
      facultades: (json['facultades'] as List<dynamic>?)
              ?.map((e) => FacultadModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoEdificio': codigoEdificio,
      'nombre': nombre,
      'facultades': facultades.map((e) => (e as FacultadModel).toJson()).toList(),
    };
  }
}
