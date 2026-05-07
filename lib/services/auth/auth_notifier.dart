import 'package:aulasmart_front_end/services/auth/auth_service.dart';
import 'package:aulasmart_front_end/services/auth/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aulasmart_front_end/services/api_exception.dart';

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return AuthInitial();
  }

  Future<void> login(String codigo, String password) async {
    state = AuthLoading();
    try {
      final authService = ref.read(authServiceProvider);
      final userInfo = await authService.login(codigo, password);
      state = AuthSuccess(userInfo);
    } on ApiException catch (e) {
      state = AuthError(e.message);
    } catch (e) {
      state = AuthError('Error inesperado: $e');
    }
  }
}
