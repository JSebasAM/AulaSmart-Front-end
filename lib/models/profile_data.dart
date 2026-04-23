class ProfileData {
  final String id;
  final String nombre;
  final String rol;
  final String avatarUrl;
  final int aulas;
  final int aulasReservadas;
  final int incidencias;

  const ProfileData({
    required this.id,
    required this.nombre,
    required this.rol,
    required this.avatarUrl,
    required this.aulas,
    required this.aulasReservadas,
    required this.incidencias,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    return ProfileData(
      id: (json['id'] ?? '').toString(),
      nombre: (json['nombre'] ?? '').toString(),
      rol: (json['rol'] ?? '').toString(),
      avatarUrl: (json['avatarUrl'] ?? '').toString(),
      aulas: int.tryParse((json['aulas'] ?? 0).toString()) ?? 0,
      aulasReservadas: int.tryParse((json['aulasReservadas'] ?? 0).toString()) ?? 0,
      incidencias: int.tryParse((json['incidencias'] ?? 0).toString()) ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'nombre': nombre,
      'rol': rol,
      'avatarUrl': avatarUrl,
      'aulas': aulas,
      'aulasReservadas': aulasReservadas,
      'incidencias': incidencias,
    };
  }
}
