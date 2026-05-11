import '../../domain/entities/tipo_aula_entity.dart';

class TipoAulaModel extends TipoAulaEntity {
  const TipoAulaModel({
    required super.id,
    required super.codigoTipoAula,
    required super.nombre,
  });

  factory TipoAulaModel.fromJson(Map<String, dynamic> json) {
    return TipoAulaModel(
      id: json['id'] as int,
      codigoTipoAula: json['codigoTipoAula'] as String,
      nombre: json['nombre'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoTipoAula': codigoTipoAula,
      'nombre': nombre,
    };
  }
}
