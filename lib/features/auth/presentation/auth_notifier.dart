import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/usecases/get_current_user_usecase.dart';
import '../domain/usecases/login_usecase.dart';
import '../domain/usecases/logout_usecase.dart';
import '../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _getCurrentUserUseCase = getCurrentUserUseCase,
       super(const AuthInitial());

  Future<void> checkAuthStatus() async {
    state = const AuthLoading();

    final result = await _getCurrentUserUseCase();

    result.fold(
      (failure) {
        debugPrint('[AuthNotifier] Failure recibido, usuario no autenticado: ${failure.message}');
        state = const AuthUnauthenticated();
      },
      (user) {
        debugPrint('[AuthNotifier] Usuario recibido, usuario autenticado: ${user.email}');
        state = AuthAuthenticated(user);
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = const AuthLoading();

    final result = await _loginUseCase(email: email, password: password);

    result.fold(
      (failure) {
        debugPrint('[AuthNotifier] Login fallido: ${failure.message}');
        state = AuthError(failure.message);
      },
      (user) {
        debugPrint('[AuthNotifier] Login exitoso: ${user.email}');
        state = AuthAuthenticated(user);
      },
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    state = const AuthLoading();

    final result = await _registerUseCase(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
    );

    result.fold(
      (failure) {
        debugPrint('[AuthNotifier] Register fallido: ${failure.message}');
        state = AuthError(failure.message);
      },
      (user) {
        debugPrint('[AuthNotifier] Register exitoso: ${user.email}');
        state = AuthAuthenticated(user);
      },
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    state = const AuthUnauthenticated();
  }
}
