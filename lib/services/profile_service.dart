import 'package:aulasmart_front_end/models/profile_data.dart';

class ProfileService {
  Future<ProfileData> obtenerPerfil() async {
    return ProfileData(
      nombre: 'Admin Sistema',
      rol: 'Administrativo',
      avatarUrl: '',
      aulasReservadas: 0,
      incidencias: 0,
    );
  }
}
