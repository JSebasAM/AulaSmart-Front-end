import 'dart:ffi';

class User {
  final Long codigo;
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String rol;

  const User({
    required this.codigo,
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
    required this.rol,
  });

  // Método para convertir un JSON a un objeto User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      codigo: json['codigo'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      email: json['email'],
      password: json['password'],
      rol: json['rol'],
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
