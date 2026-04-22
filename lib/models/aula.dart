class Aula {
  final String id;
  final String nombre;
  final String edificio;
  final int piso;
  final String categoria;
  final int capacidad;
  final String estado;
  final String imagenUrl;
  final bool tieneVideo;
  final bool tieneWifi;

  const Aula({
    required this.id,
    required this.nombre,
    required this.edificio,
    required this.piso,
    required this.categoria,
    required this.capacidad,
    required this.estado,
    required this.imagenUrl,
    required this.tieneVideo,
    required this.tieneWifi,
  });

  bool get estaLibre => estado.toLowerCase() == 'libre';

  String get ubicacion => '$edificio • Piso $piso';

  factory Aula.fromJson(Map<String, dynamic> json) {
    return Aula(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      edificio: (json['edificio'] ?? '').toString(),
      piso: int.tryParse((json['piso'] ?? 0).toString()) ?? 0,
      categoria: (json['categoria'] ?? '').toString(),
      capacidad: int.tryParse((json['capacidad'] ?? 0).toString()) ?? 0,
      estado: (json['estado'] ?? '').toString(),
      imagenUrl: (json['imagenUrl'] ?? '').toString(),
      tieneVideo: json['tieneVideo'] == true,
      tieneWifi: json['tieneWifi'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'edificio': edificio,
      'piso': piso,
      'categoria': categoria,
      'capacidad': capacidad,
      'estado': estado,
      'imagenUrl': imagenUrl,
      'tieneVideo': tieneVideo,
      'tieneWifi': tieneWifi,
    };
  }
}
