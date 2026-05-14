class ReservaEntity {
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

  ReservaEntity({
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

  bool get estaPendiente => estado.toLowerCase() == 'pendiente';

  factory ReservaEntity.fromJson(Map<String, dynamic> json) {
    final idVal = (json['id'] ?? json['idReserva'] ?? json['id_reserva'])?.toString() ?? '';
    final codigoAulaRaw = json['codigo_aula'] ?? json['codigoAula'];
    final codigoAulaVal = codigoAulaRaw is int
        ? codigoAulaRaw
        : int.tryParse((codigoAulaRaw ?? '').toString()) ?? 0;
    final horaInicioRaw = (json['hora_inicio'] ?? json['horaInicio'] ?? '').toString();
    final horaFinRaw = (json['hora_fin'] ?? json['horaFin'] ?? '').toString();

    final estadoVal = (json['estado'] ?? '').toString();

    final idSolicitanteRaw = json['id_solicitante'] ?? json['idSolicitante'];
    final idSolicitanteVal = idSolicitanteRaw is int
        ? idSolicitanteRaw
        : int.tryParse((idSolicitanteRaw ?? '0').toString()) ?? 0;

    final rolSolicitanteVal = (json['rol_solicitante'] ?? json['rolSolicitante'] ?? '').toString();
    final codigoProgramaVal = (json['codigo_programa'] ?? json['codigoPrograma'] ?? '').toString();

    final grupoRaw = (json['grupo'] ?? json['grupo_reserva'] ?? '').toString();
    final grupoVal = grupoRaw.trim();

    final tituloRaw = (json['titulo'] ?? json['titulo_reserva'] ?? json['tituloApi'] ?? '').toString().trim();
    final tituloVal = tituloRaw.isEmpty ? null : tituloRaw;

    final nombreRespRaw = (json['nombreUsuarioResponsable'] ?? json['nombre_usuario_responsable'] ?? json['nombre_responsable'] ?? '').toString().trim();
    final nombreRespVal = nombreRespRaw.isEmpty ? null : nombreRespRaw;

    final origenVal = (json['origen'] ?? '').toString().trim();

    return ReservaEntity(
      id: idVal,
      codigoAula: codigoAulaVal,
      horaInicio: DateTime.parse(horaInicioRaw),
      horaFin: DateTime.parse(horaFinRaw),
      estado: estadoVal,
      idSolicitante: idSolicitanteVal,
      rolSolicitante: rolSolicitanteVal,
      codigoPrograma: codigoProgramaVal,
      grupo: grupoVal,
      tituloApi: tituloVal,
      nombreUsuarioResponsable: nombreRespVal,
      origen: origenVal.isEmpty ? null : origenVal,
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
      'grupo': grupo.isEmpty ? null : grupo,
      'titulo': tituloApi,
      'nombreUsuarioResponsable': nombreUsuarioResponsable,
      'origen': origen,
    };
  }

  // Presentation helpers: return best-effort display values
  String get displayTitulo {
    if (tituloApi != null && tituloApi!.trim().isNotEmpty) return tituloApi!.trim();
    if (grupo.trim().isNotEmpty) return grupo.trim();
    return 'Reserva';
  }

  String get displaySolicitante {
    if (nombreUsuarioResponsable != null && nombreUsuarioResponsable!.trim().isNotEmpty) return nombreUsuarioResponsable!.trim();
    return 'Solicitante ${idSolicitante}';
  }

  String get displayGrupo => grupo.trim().isNotEmpty ? grupo.trim() : '-';

  String get displayAula => 'Aula $codigoAula';

  String get displayFecha =>
      '${horaInicio.day.toString().padLeft(2, '0')}/${horaInicio.month.toString().padLeft(2, '0')}/${horaInicio.year}';

  String get displayHorario =>
      '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')} - ${horaFin.hour.toString().padLeft(2, '0')}:${horaFin.minute.toString().padLeft(2, '0')}';

  String get displayHoraInicio =>
      '${horaInicio.hour.toString().padLeft(2, '0')}:${horaInicio.minute.toString().padLeft(2, '0')}';

  String get displayPrograma =>
      codigoPrograma.trim().isNotEmpty ? codigoPrograma.trim() : '-';

  String get displayOrigen =>
      (origen != null && origen!.trim().isNotEmpty) ? origen!.trim() : '-';
}
