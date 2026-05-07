abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  final Map<String, dynamic> userInfo;
  AuthSuccess(this.userInfo);
}

class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}
