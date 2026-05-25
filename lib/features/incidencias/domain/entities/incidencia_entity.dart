class IncidenciaEntity {
  final int id;
  final int codigoAula;
  final int codigoUsuario;
  final String descripcionBreve;
  final String? urlImagen;
  final String? cartaFormalGenerada;
  final String tipoIncidencia;
  final String estado;
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

  bool get estaPendiente => estado.toLowerCase() == 'pendiente';

  String get displayTipo {
    switch (tipoIncidencia.toLowerCase()) {
      case 'queja':
        return 'Queja';
      case 'reclamo':
        return 'Reclamo';
      case 'recomendacion':
        return 'Recomendacion';
      case 'dano_fisico':
        return 'Dano Fisico';
      default:
        return tipoIncidencia;
    }
  }

  String get displayEstado {
    switch (estado.toLowerCase()) {
      case 'pendiente':
        return 'Pendiente';
      case 'revisada':
        return 'Revisada';
      case 'cerrada':
        return 'Cerrada';
      default:
        return estado;
    }
  }
}
