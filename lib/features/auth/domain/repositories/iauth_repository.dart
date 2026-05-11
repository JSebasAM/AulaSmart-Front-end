import '../entities/auth_entity.dart';

abstract class IAuthRepository {
  Future<AuthEntity> login(String codigo, String password);
  Future<void> logout();
}
