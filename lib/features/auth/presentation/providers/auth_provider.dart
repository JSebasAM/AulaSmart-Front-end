import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/auth_repository_impl.dart';
import '../../../../services/dio_client.dart';
import '../../../../services/storage_service.dart';
import '../../../../services/api_exception.dart';
import 'auth_state.dart';
import '../../../usuarios/presentation/providers/usuarios_provider.dart';

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

final currentUserProfileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  ref.watch(authProvider);
  try {
    final storage = ref.read(storageServiceProvider);
    final cached = await storage.getUserInfo();
    final id = cached?['id'];
    if (id == null) return cached;
    final repo = ref.read(usuarioRepositoryProvider);
    final user = await repo.getById(id.toString());
    final profile = <String, dynamic>{
      'id': user.codigo,
      'codigo': user.codigo,
      'nombre_completo': '${user.nombre} ${user.apellido}'.trim(),
      'email': user.email,
      'rol': user.rol,
    };
    await storage.saveUserInfo(profile);
    return profile;
  } catch (_) {
    return ref.read(storageServiceProvider).getUserInfo();
  }
});
