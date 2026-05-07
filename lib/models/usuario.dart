class User {
  final String codigo;
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String rol;

  const User({
    required this.codigo,
    this.nombre = '',
    this.apellido = '',
    this.email = '',
    this.password = '',
    this.rol = '',
  });

  // Método para convertir un JSON a un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    final codigoRaw = json['codigo'];
    final int codigoValue;
    if (codigoRaw is int) {
      codigoValue = codigoRaw;
    } else if (codigoRaw is String) {
      codigoValue = int.tryParse(codigoRaw) ?? 0;
    } else {
      codigoValue = 0;
    }

    return User(
      codigo: codigoValue,
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      rol: json['rol'] ?? '',
    );
  }

  // Método para convertir un objeto User a JSON
  Map<String, dynamic> toJson() {
    return {
      'codigo': codigo,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'password': password,
      'rol': rol,
    };
  }
}
