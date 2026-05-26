enum TipoIncidencia { HARDWARE, SOFTWARE, INFRAESTRUCTURA, OTRO }

enum EstadoIncidencia { PENDIENTE, REVISADA, CERRADA }

class IncidenciaEntity {
  final int id;
  final int codigoAula;
  final int codigoUsuario;
  final String descripcionBreve;
  final String? urlImagen;
  final String? cartaFormalGenerada;
  final TipoIncidencia tipoIncidencia;
  final EstadoIncidencia estado;
  final String? respuestaAdministracion;
  final DateTime? fechaRespuesta;
  final int? codigoAdministrador;
  final DateTime fechaReporte;

  IncidenciaEntity({
    required this.id,
    required this.codigoAula,
    required this.codigoUsuario,
    required this.descripcionBreve,
    this.urlImagen,
    this.cartaFormalGenerada,
    required this.tipoIncidencia,
    required this.estado,
    this.respuestaAdministracion,
    this.fechaRespuesta,
    this.codigoAdministrador,
    required this.fechaReporte,
  });

  bool get estaPendiente => estado == EstadoIncidencia.PENDIENTE;
  bool get esRevisada => estado == EstadoIncidencia.REVISADA;
  bool get estaCerrada => estado == EstadoIncidencia.CERRADA;

  String get displayTipo {
    switch (tipoIncidencia) {
      case TipoIncidencia.HARDWARE: return 'Hardware';
      case TipoIncidencia.SOFTWARE: return 'Software';
      case TipoIncidencia.INFRAESTRUCTURA: return 'Infraestructura';
      case TipoIncidencia.OTRO: return 'Otro';
    }
  }

  String get displayEstado {
    switch (estado) {
      case EstadoIncidencia.PENDIENTE: return 'Pendiente';
      case EstadoIncidencia.REVISADA: return 'Revisada';
      case EstadoIncidencia.CERRADA: return 'Cerrada';
    }
  }

  bool get esUrgente =>
      estaPendiente &&
      DateTime.now().difference(fechaReporte).inDays > 7;
}
