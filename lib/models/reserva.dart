class Reserva {
  final int id;
  final int codigoAula;
  final DateTime horaInicio;
  final DateTime horaFin;
  final String estado;
  final int idSolicitante;
  final String rolSolicitante;
  final String codigoPrograma;
  final String grupo;

  Reserva({
    required this.id,
    required this.codigoAula,
    required this.horaInicio,
    required this.horaFin,
    required this.estado,
    required this.idSolicitante,
    required this.rolSolicitante,
    required this.codigoPrograma,
    required this.grupo,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: json['id'],
      codigoAula: json['codigo_aula'],
      horaInicio: DateTime.parse(json['hora_inicio']),
      horaFin: DateTime.parse(json['hora_fin']),
      estado: json['estado'],
      idSolicitante: json['id_solicitante'],
      rolSolicitante: json['rol_solicitante'],
      codigoPrograma: json['codigo_programa'],
      grupo: json['grupo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_aula': codigoAula,
      'hora_inicio': horaInicio.toIso8601String(),
      'hora_fin': horaFin.toIso8601String(),
      'estado': estado,
      'id_solicitante': idSolicitante,
      'rol_solicitante': rolSolicitante,
      'codigo_programa': codigoPrograma,
      'grupo': grupo,
    };
  }
}