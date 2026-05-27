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

  static TipoIncidencia _parseTipo(String? v) {
    switch (v?.toUpperCase()) {
      case 'HARDWARE': return TipoIncidencia.HARDWARE;
      case 'SOFTWARE': return TipoIncidencia.SOFTWARE;
      case 'INFRAESTRUCTURA': return TipoIncidencia.INFRAESTRUCTURA;
      default: return TipoIncidencia.OTRO;
    }
  }

  static EstadoIncidencia _parseEstado(String? v) {
    switch (v?.toUpperCase()) {
      case 'REVISADA': return EstadoIncidencia.REVISADA;
      case 'CERRADA': return EstadoIncidencia.CERRADA;
      default: return EstadoIncidencia.PENDIENTE;
    }
  }

  factory IncidenciaModel.fromJson(Map<String, dynamic> json) {
    final horaRaw = json['fechaReporte'] ?? json['fecha_reporte'] ?? json['fecha_reporte'];
    return IncidenciaModel(
      id: json['id'] ?? 0,
      codigoAula: json['codigoAula'] ?? json['codigo_aula'] ?? json['codigoAula'] ?? 0,
      codigoUsuario: json['codigoUsuario'] ?? json['codigo_usuario'] ?? 0,
      descripcionBreve: json['descripcionBreve'] ?? json['descripcion_breve'] ?? '',
      urlImagen: json['urlImagen'] ?? json['url_imagen'],
      cartaFormalGenerada: json['cartaFormalGenerada'] ?? json['carta_formal_generada'],
      tipoIncidencia: _parseTipo(json['tipoIncidencia'] ?? json['tipo_incidencia']),
      estado: _parseEstado(json['estado']),
      respuestaAdministracion: json['respuestaAdministracion'] ?? json['respuesta_administracion'],
      fechaRespuesta: _tryParseDt(json['fechaRespuesta'] ?? json['fecha_respuesta']),
      codigoAdministrador: json['codigoAdministrador'] ?? json['codigo_administrador'],
      fechaReporte: _tryParseDt(horaRaw) ?? DateTime.now(),
    );
  }

  static DateTime? _tryParseDt(dynamic v) {
    if (v == null) return null;
    return DateTime.tryParse(v.toString());
  }
}
