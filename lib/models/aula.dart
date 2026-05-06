
class Aula {
  final int id;
  final int codigoAula;
  final String nombreAula;
  final String codigoEdificio;
  final String nombreEdificio;
  final int capacidad;
  final String codigoDependencia;
  final String nombreDependencia;
  final String codigoTipoAula;
  final String nombreTipoAula;
  final bool requiereAutorizacion;

  Aula({
    required this.id,
    required this.codigoAula,
    required this.nombreAula,
    required this.codigoEdificio,
    required this.nombreEdificio,
    required this.capacidad,
    required this.codigoDependencia,
    required this.nombreDependencia,
    required this.codigoTipoAula,
    required this.nombreTipoAula,
    required this.requiereAutorizacion,
  });

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: json['id'],
      codigoAula: json['codigoAula'],
      nombreAula: json['nombreAula'],
      codigoEdificio: json['codigoEdificio'],
      nombreEdificio: json['nombreEdificio'],
      capacidad: json['capacidad'],
      codigoDependencia: json['codigoDependencia'],
      nombreDependencia: json['nombreDependencia'],
      codigoTipoAula: json['codigoTipoAula'],
      nombreTipoAula: json['nombreTipoAula'],
      requiereAutorizacion: json['requiereAutorizacion'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigoAula': codigoAula,
      'nombreAula': nombreAula,
      'codigoEdificio': codigoEdificio,
      'nombreEdificio': nombreEdificio,
      'capacidad': capacidad,
      'codigoDependencia': codigoDependencia,
      'nombreDependencia': nombreDependencia,
      'codigoTipoAula': codigoTipoAula,
      'nombreTipoAula': nombreTipoAula,
      'requiereAutorizacion': requiereAutorizacion ? 1 : 0,
    };
  }
}