class Reserva {
  final String id;
  final String titulo;
  final String estado;
  final String aula;
  final String fecha;
  final String horario;
  final int asistentes;
  final String descripcion;

  const Reserva({
    required this.id,
    required this.titulo,
    required this.estado,
    required this.aula,
    required this.fecha,
    required this.horario,
    required this.asistentes,
    required this.descripcion,
  });

  bool get estaPendiente => estado.toLowerCase() == 'pendiente';

  factory Reserva.fromJson(Map<String, dynamic> json) {
    return Reserva(
      id: (json['id'] ?? '').toString(),
      titulo: (json['titulo'] ?? '').toString(),
      estado: (json['estado'] ?? '').toString(),
      aula: (json['aula'] ?? '').toString(),
      fecha: (json['fecha'] ?? '').toString(),
      horario: (json['horario'] ?? '').toString(),
      asistentes: int.tryParse((json['asistentes'] ?? 0).toString()) ?? 0,
      descripcion: (json['descripcion'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'titulo': titulo,
      'estado': estado,
      'aula': aula,
      'fecha': fecha,
      'horario': horario,
      'asistentes': asistentes,
      'descripcion': descripcion,
    };
  }
}
