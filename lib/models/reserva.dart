class Reserva {
  final String id;
  final int codigoAula;
  final DateTime horaInicio;
  final DateTime horaFin;
  final String estado;
  final int idSolicitante;
  final String rolSolicitante;
  final String codigoPrograma;
  final String grupo;
  final String? tituloApi;
  final String? nombreUsuarioResponsable;
  final String? origen;

  bool get estaPendiente => estado.toLowerCase() == 'pendiente';
  String get titulo => 'Reserva Aula $codigoAula';
  String get aula => 'Aula $codigoAula';
  String get fecha => '${horaInicio.day}/${horaInicio.month}/${horaInicio.year}';
  String get horario => '${horaInicio.hour}:${horaInicio.minute.toString().padLeft(2, "0")} - ${horaFin.hour}:${horaFin.minute.toString().padLeft(2, "0")}';
  int get asistentes => 30; // Valor por defecto
  String get descripcion => 'Reserva para el grupo $grupo'; // Valor por defecto

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
    this.tituloApi,
    this.nombreUsuarioResponsable,
    this.origen,
  });

  factory Reserva.fromJson(Map<String, dynamic> json) {
    // Support different API key styles (snake_case or camelCase)
    String idVal = (json['id'] ?? json['idReserva'] ?? json['id_reserva'])?.toString() ?? '';
    int codigoAulaVal = (json['codigo_aula'] ?? json['codigoAula'] ?? json['codigo_aula']) is int
        ? (json['codigo_aula'] ?? json['codigoAula']) as int
        : int.tryParse((json['codigo_aula'] ?? json['codigoAula'] ?? '').toString()) ?? 0;
    String horaInicioRaw = (json['hora_inicio'] ?? json['horaInicio'] ?? '').toString();
    String horaFinRaw = (json['hora_fin'] ?? json['horaFin'] ?? '').toString();
    return Reserva(
      id: idVal,
      codigoAula: codigoAulaVal,
      horaInicio: DateTime.parse(horaInicioRaw),
      horaFin: DateTime.parse(horaFinRaw),
      estado: (json['estado'] ?? json['estado'] ?? '').toString(),
      idSolicitante: (json['id_solicitante'] ?? json['idSolicitante'] ?? 0) is int
          ? (json['id_solicitante'] ?? json['idSolicitante']) as int
          : int.tryParse((json['id_solicitante'] ?? json['idSolicitante'] ?? '0').toString()) ?? 0,
      rolSolicitante: (json['rol_solicitante'] ?? json['rolSolicitante'] ?? '').toString(),
      codigoPrograma: (json['codigo_programa'] ?? json['codigoPrograma'] ?? '').toString(),
      grupo: (json['grupo'] ?? '').toString(),
      tituloApi: (json['titulo'] ?? json['titulo_reserva'] ?? '').toString(),
      nombreUsuarioResponsable: (json['nombreUsuarioResponsable'] ?? json['nombre_usuario_responsable'] ?? json['nombre_responsable'])?.toString(),
      origen: (json['origen'] ?? '').toString(),
    );
  }

  factory Reserva.fromEntity(dynamic entity) {
    // Accept ReservaEntity or ReservaModel-like objects with same fields
    return Reserva(
      id: entity.id.toString(),
      codigoAula: entity.codigoAula ?? 0,
      horaInicio: entity.horaInicio is DateTime ? entity.horaInicio : DateTime.parse(entity.horaInicio.toString()),
      horaFin: entity.horaFin is DateTime ? entity.horaFin : DateTime.parse(entity.horaFin.toString()),
      estado: entity.estado ?? '',
      idSolicitante: entity.idSolicitante ?? 0,
      rolSolicitante: entity.rolSolicitante ?? '',
      codigoPrograma: entity.codigoPrograma ?? '',
      grupo: entity.grupo ?? '',
      tituloApi: entity.tituloApi,
      nombreUsuarioResponsable: entity.nombreUsuarioResponsable,
      origen: entity.origen,
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