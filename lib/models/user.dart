class User {
  final String codigo;
  final String password;

  const User({
    required this.codigo,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'codigo': codigo,
      'password': password,
    };
  }
}
