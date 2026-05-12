import 'package:aulasmart_front_end/services/api_exception.dart';
import 'package:aulasmart_front_end/services/base_service.dart';
import 'package:aulasmart_front_end/services/dio_client.dart';
import 'package:aulasmart_front_end/services/storage_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: ApiUrls.usuarios,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json'},
  ));
  return AuthService(dio, ref.read(storageServiceProvider));
});

class AuthService extends BaseService {
  final StorageService _storageService;

  AuthService(Dio dio, this._storageService) : super(dio);

  Future<Map<String, dynamic>> login(String codigo, String password) async {
    final data = {
      'codigo': codigo,
      'password': password,
    };

    final response = await post<Map<String, dynamic>>(
      '/auth/login',
      data: data,
      parser: (data) => data as Map<String, dynamic>,
    );

    if (response['success'] == true && response['data'] != null) {
      final authData = response['data'] as Map<String, dynamic>;
      final accessToken = authData['access_token'] as String;
      final refreshToken = authData['refresh_token'] as String;
      final userInfo = authData['user_info'] as Map<String, dynamic>;

      await _storageService.saveTokens(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
      
      await _storageService.saveUserInfo(userInfo);
      return userInfo;
    } else {
      throw ApiException(
        message: response['message'] ?? 'Error desconocido',
        statusCode: response['status'] as int?,
      );
    }
  }

  Future<void> logout() async {
    await _storageService.clearAll();
  }
}