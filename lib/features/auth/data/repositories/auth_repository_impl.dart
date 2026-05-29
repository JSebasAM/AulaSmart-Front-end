import 'package:dio/dio.dart';
import 'package:aulasmart_front_end/features/auth/domain/entities/auth_entity.dart';
import 'package:aulasmart_front_end/features/auth/domain/repositories/iauth_repository.dart';
import 'package:aulasmart_front_end/features/auth/data/models/auth_model.dart';
import 'package:aulasmart_front_end/core/storage/storage_service.dart';
import 'package:aulasmart_front_end/core/error/api_exception.dart';

class AuthRepositoryImpl implements IAuthRepository {
  final Dio dio;
  final StorageService storageService;

  AuthRepositoryImpl({required this.dio, required this.storageService});

  @override
  Future<AuthEntity> login(String codigo, String password) async {
    try {
      final response = await dio.post(
        '/auth/login',
        data: {'codigo': codigo, 'password': password},
      );

      if (response.data['success'] == true && response.data['data'] != null) {
        final authModel = AuthModel.fromJson(
          response.data['data'] as Map<String, dynamic>,
        );

        await Future.wait([
          storageService.saveTokens(
            accessToken: authModel.accessToken,
            refreshToken: authModel.refreshToken,
          ),
          storageService.saveUserInfo(authModel.userInfo),
        ]);

        return authModel;
      } else {
        throw ApiException(
          message: response.data['message'] ?? 'Error desconocido',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> logout() async {
    await storageService.clearAll();
  }
}
