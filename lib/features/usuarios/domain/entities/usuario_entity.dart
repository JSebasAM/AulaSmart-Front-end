class UsuarioEntity {
  final String codigo;
  final String nombre;
  final String apellido;
  final String email;
  final String password;
  final String rol;

  const UsuarioEntity({
    required this.codigo,
    this.nombre = '',
    this.apellido = '',
    this.email = '',
    this.password = '',
    this.rol = '',
  });
}
