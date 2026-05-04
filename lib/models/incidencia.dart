class Incidencia {
  final int id;
  final int codigoAula;
  final int codigoUsuario;
  final String descripcionBreve;
  final String? urlImagen;
  final String? cartaFormalGenerada;
  final String tipoIncidencia;
  final DateTime fechaReporte;

  Incidencia({
    required this.id,
    required this.codigoAula,
    required this.codigoUsuario,
    required this.descripcionBreve,
    this.urlImagen,
    this.cartaFormalGenerada,
    required this.tipoIncidencia,
    required this.fechaReporte,
  });

  factory Incidencia.fromJson(Map<String, dynamic> json) {
    return Incidencia(
      id: json['id'],
      codigoAula: json['codigo_aula'],
      codigoUsuario: json['codigo_usuario'],
      descripcionBreve: json['descripcion_breve'],
      urlImagen: json['url_imagen'],
      cartaFormalGenerada: json['carta_formal_generada'],
      tipoIncidencia: json['tipo_incidencia'], // viene como String desde Spring
      fechaReporte: DateTime.parse(json['fecha_reporte']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_aula': codigoAula,
      'codigo_usuario': codigoUsuario,
      'descripcion_breve': descripcionBreve,
      'url_imagen': urlImagen,
      'carta_formal_generada': cartaFormalGenerada,
      'tipo_incidencia': tipoIncidencia,
      'fecha_reporte': fechaReporte.toIso8601String(),
    };
  }
}