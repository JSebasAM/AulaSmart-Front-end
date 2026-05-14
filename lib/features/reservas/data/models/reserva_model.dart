import '../../domain/entities/reserva_entity.dart';

class ReservaModel extends ReservaEntity {
  ReservaModel({
    required super.id,
    required super.codigoAula,
    required super.horaInicio,
    required super.horaFin,
    required super.estado,
    required super.idSolicitante,
    required super.rolSolicitante,
    required super.codigoPrograma,
    required super.grupo,
    super.tituloApi,
    super.nombreUsuarioResponsable,
    super.origen,
  });

  factory ReservaModel.fromJson(Map<String, dynamic> json) {
    String idVal = (json['id'] ?? json['idReserva'] ?? json['id_reserva'])?.toString() ?? '';
    int codigoAulaVal = (json['codigo_aula'] ?? json['codigoAula']) is int
        ? (json['codigo_aula'] ?? json['codigoAula']) as int
        : int.tryParse((json['codigo_aula'] ?? json['codigoAula'] ?? '').toString()) ?? 0;
    String horaInicioRaw = (json['hora_inicio'] ?? json['horaInicio'] ?? '').toString();
    String horaFinRaw = (json['hora_fin'] ?? json['horaFin'] ?? '').toString();
    return ReservaModel(
      id: idVal,
      codigoAula: codigoAulaVal,
      horaInicio: DateTime.parse(horaInicioRaw),
      horaFin: DateTime.parse(horaFinRaw),
      estado: (json['estado'] ?? '').toString(),
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

  @override
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
      'titulo': tituloApi ?? '',
      'nombreUsuarioResponsable': nombreUsuarioResponsable,
      'origen': origen,
    };
  }
}
