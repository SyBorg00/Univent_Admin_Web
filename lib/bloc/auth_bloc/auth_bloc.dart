import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthBloc extends Bloc<AuthEvent, AuthStates> {
  final SupabaseClient supabase = Supabase.instance.client;

  AuthBloc() : super(AuthInitial()) {
    on<GoogleSignInRequested>(_onGoogleSignIn);
    on<EmailSignInRequested>(_onEmailSignIn);
    on<CheckAuthSession>(_checkAuthSession);
  }

  //for google sign-in method
  Future<void> _onGoogleSignIn(
    GoogleSignInRequested event,
    Emitter<AuthStates> emit,
  ) async {
    emit(AuthLoading());
    try {
      if (kIsWeb) {
        supabase.auth.signInWithOAuth(OAuthProvider.google);
      } else {
        await supabase.auth.signInWithOAuth(OAuthProvider.google);
      }
      await Future.delayed(Duration(seconds: 2));
      await _checkUserRole(emit);
    } catch (e) {
      emit(AuthFailure("Failed to Login. Try Again Later"));
    }
  }

  //for regular sign-in method
  Future<void> _onEmailSignIn(
    EmailSignInRequested event,
    Emitter<AuthStates> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signInWithPassword(
        email: event.email,
        password: event.password,
      );
      if (response.session == null) {
        emit(AuthFailure("Invalid login"));
      }
      await _checkUserRole(emit);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

  //check if users have the admin role, else they get denied permission
  Future<void> _checkUserRole(Emitter<AuthStates> emit) async {
    final user = supabase.auth.currentUser;
    if (user != null) {
      final email = user.email;
      final response =
          await supabase
              .from('accounts')
              .select('role')
              .eq('email', email!)
              .limit(1)
              .maybeSingle();
      final role = response?['role'];
      if (role == "admin" || role == "owner") {
        emit(AuthSuccess());
      } else {
        await supabase.auth.signOut();
        emit(AuthFailure("Access denied"));
      }
    } else {
      emit(AuthInitial());
    }
  }

  //for automatic logging in (you know, not needing to manually sign up again upon loading)
  Future<void> _checkAuthSession(
    CheckAuthSession event,
    Emitter<AuthStates> emit,
  ) async {
    final session = supabase.auth.currentSession;
    final user = session?.user;
    final email = user?.email;

    if (user != null && email != null) {
      final response =
          await supabase
              .from('accounts')
              .select('role')
              .eq('email', email)
              .limit(1)
              .maybeSingle();
      final role = response?['role'];
      if (role == "admin" || role == "owner") {
        emit(AuthSuccess());
      } else {
        await supabase.auth.signOut();
        emit(AuthFailure("Access denied"));
      }
    } else {
      emit(AuthInitial());
    }
  }
}
