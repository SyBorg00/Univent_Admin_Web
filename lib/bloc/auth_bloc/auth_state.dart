abstract class AuthStates {}

class AuthInitial extends AuthStates {}

class AuthLoading extends AuthStates {}

class AuthSuccess extends AuthStates {}

class AuthFailure extends AuthStates {
  final String error;
  AuthFailure(this.error);
}
