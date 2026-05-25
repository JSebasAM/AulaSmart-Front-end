import '../../domain/entities/incidencia_entity.dart';

class IncidenciaModel extends IncidenciaEntity {
  IncidenciaModel({
    required super.id,
    required super.codigoAula,
    required super.codigoUsuario,
    required super.descripcionBreve,
    super.urlImagen,
    super.cartaFormalGenerada,
    required super.tipoIncidencia,
    required super.estado,
    super.respuestaAdministracion,
    super.fechaRespuesta,
    super.codigoAdministrador,
    required super.fechaReporte,
  });

  factory IncidenciaModel.fromJson(Map<String, dynamic> json) {
    final horaRaw = json['fechaReporte'] ?? json['fecha_reporte'];
    return IncidenciaModel(
      id: json['id'] ?? 0,
      codigoAula: json['codigoAula'] ?? json['codigo_aula'] ?? 0,
      codigoUsuario: json['codigoUsuario'] ?? json['codigo_usuario'] ?? 0,
      descripcionBreve: json['descripcionBreve'] ??
          json['descripcion_breve'] ??
          '',
      urlImagen: json['urlImagen'] ?? json['url_imagen'],
      cartaFormalGenerada: json['cartaFormalGenerada'] ??
          json['carta_formal_generada'],
      tipoIncidencia: json['tipoIncidencia'] ??
          json['tipo_incidencia'] ??
          '',
      estado: json['estado'] ?? 'PENDIENTE',
      respuestaAdministracion: json['respuestaAdministracion'] ??
          json['respuesta_administracion'],
      fechaRespuesta: json['fecha_respuesta'] != null
          ? DateTime.tryParse(json['fecha_respuesta'].toString())
          : json['fechaRespuesta'] != null
              ? DateTime.tryParse(json['fechaRespuesta'].toString())
              : null,
      codigoAdministrador: json['codigoAdministrador'] ??
          json['codigo_administrador'],
      fechaReporte: horaRaw != null
          ? DateTime.parse(horaRaw.toString())
          : DateTime.now(),
    );
  }
}
