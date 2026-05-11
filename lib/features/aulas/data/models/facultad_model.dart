import '../../domain/entities/facultad_entity.dart';

class FacultadModel extends FacultadEntity {
  const FacultadModel({
    required super.id,
    required super.codigoDependencia,
    required super.nombre,
  });

  factory FacultadModel.fromJson(Map<String, dynamic> json) {
    return FacultadModel(
      id: json['id'] as int,
      codigoDependencia: json['codigoDependencia'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoDependencia': codigoDependencia,
      'nombre': nombre,
    };
  }
}
