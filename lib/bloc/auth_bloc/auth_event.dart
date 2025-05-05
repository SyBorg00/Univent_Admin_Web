abstract class AuthEvent {}

class GoogleSignInRequested extends AuthEvent {}

class CheckAuthSession extends AuthEvent {}

class EmailSignInRequested extends AuthEvent {
  final String email;
  final String password;
  EmailSignInRequested(this.email, this.password);
}
