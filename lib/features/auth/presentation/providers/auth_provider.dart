import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../../../services/dio_client.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/api_exception.dart';
import 'auth_state.dart';

part 'auth_provider.g.dart';

@riverpod
AuthRepositoryImpl authRepository(Ref ref) {
  final dioGlobal = ref.watch(dioProvider);
  final dio = Dio(dioGlobal.options.copyWith(
    baseUrl: ApiUrls.auth,
  ));
  dio.interceptors.addAll(dioGlobal.interceptors);
  final storageService = ref.watch(storageServiceProvider);
  return AuthRepositoryImpl(dio: dio, storageService: storageService);
}

@riverpod
class Auth extends _$Auth {
  @override
  AuthState build() => AuthInitial();

  Future<void> login(String codigo, String password) async {
    state = AuthLoading();
    try {
      final repository = ref.read(authRepositoryProvider);
      final authEntity = await repository.login(codigo, password);
      state = AuthSuccess(authEntity.userInfo);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Error inesperado: $e');
    }
  }

  Future<void> logout() async {
    final repository = ref.read(authRepositoryProvider);
    await repository.logout();
  }
}

final currentUserProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  return ref.read(storageServiceProvider).getUserInfo();
});
