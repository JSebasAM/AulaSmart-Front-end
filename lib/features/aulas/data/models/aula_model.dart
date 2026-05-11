import '../../domain/entities/aula_entity.dart';
import 'bloque_model.dart';
import 'tipo_aula_model.dart';

class AulaModel extends AulaEntity {
  const AulaModel({
    required super.id,
    required super.codigoAula,
    required super.nombreAula,
    required super.capacidad,
    required super.bloque,
    required super.tipoAula,
    required super.requiereAutorizacion,
  });

  factory AulaModel.fromJson(Map<String, dynamic> json) {
    return AulaModel(
      id: json['id'] as int,
      codigoAula: json['codigoAula'] as int,
      nombreAula: json['nombreAula'] as String,
      capacidad: json['capacidad'] as int,
      bloque: BloqueModel.fromJson(json['bloque'] as Map<String, dynamic>),
      tipoAula: TipoAulaModel.fromJson(json['tipoAula'] as Map<String, dynamic>),
      requiereAutorizacion: json['requiereAutorizacion'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoAula': codigoAula,
      'nombreAula': nombreAula,
      'capacidad': capacidad,
      'bloque': (bloque as BloqueModel).toJson(),
      'tipoAula': (tipoAula as TipoAulaModel).toJson(),
      'requiereAutorizacion': requiereAutorizacion,
    };
  }
}
