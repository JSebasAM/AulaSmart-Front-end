enum UserRole {
  administrador,
  administrativo,
  docente,
  estudiante,
  monitor;

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'administrador':
        return UserRole.administrador;
      case 'administrativo':
        return UserRole.administrativo;
      case 'docente':
        return UserRole.docente;
      case 'monitor':
        return UserRole.monitor;
      default:
        return UserRole.estudiante;
    }
  }

  bool get canAccessAdmin => this == administrador || this == administrativo;
}

class Rbac {
  static bool isAdmin(String role) {
    return UserRole.fromString(role).canAccessAdmin;
  }
}
