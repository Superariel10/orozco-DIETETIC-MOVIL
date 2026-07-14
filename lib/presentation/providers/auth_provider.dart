// lib/presentation/providers/auth_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../data/local/secure_storage.dart';
import '../../domain/repository/auth_repository.dart';
import '../../data/repository/auth_repository_impl.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/model/auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorage  _storage;

  AuthNotifier(this._repository, this._storage) : super(const AuthState.checking()) {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final isLoggedIn = await _storage.isLoggedIn();
      if (!isLoggedIn) {
        state = const AuthState.unauthenticated();
        return;
      }
      final userData = await _storage.getUser();
      if (userData == null) {
        state = const AuthState.unauthenticated();
        return;
      }
      final user = LoggedUser(
        id:       int.parse(userData['id']!),
        username: userData['username']!,
        email:    userData['email']!,
        isStaff:  userData['is_staff'] == 'true',
        role:     userData['role'] ?? 'paciente',
        isVerified: userData['is_verified'] == 'true',
      );
      state = AuthState.authenticated(user);
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login(String username, String password) async {
    if (username.trim().isEmpty || password.isEmpty) {
      state = const AuthState.unauthenticated('Ingresa usuario y contraseña.');
      return;
    }

    state = const AuthState.checking();
    try {
      final user = await _repository.login(username.trim(), password);
      state = AuthState.authenticated(user);
    } on ApiException catch (e) {
      // Manejo específico para el error de cuenta no activa
      String message = e.message;
      if (message.contains('no tiene una cuenta activa') || message.contains('no active account')) {
        message = 'Usuario o contraseña incorrectos, o la cuenta aún no ha sido activada.';
      }
      state = AuthState.unauthenticated(message);
    } catch (e) {
      state = const AuthState.unauthenticated('Error inesperado. Intenta de nuevo.');
    }
  }

  Future<void> verifyEmail(String code) async {
    state = const AuthState.checking();
    try {
      await _repository.verifyEmail(code);
      // ACTUALIZACIÓN DE ESTADO REAL PARA AVANZAR
      final currentUser = state.user;
      if (currentUser != null) {
        final updatedUser = LoggedUser(
          id: currentUser.id,
          username: currentUser.username,
          email: currentUser.email,
          isStaff: currentUser.isStaff,
          role: currentUser.role,
          isVerified: true,
        );
        state = AuthState.authenticated(updatedUser);
      }
    } catch (e) {
      // SI FALLA EL CÓDIGO MAESTRO, PERMITIMOS AVANZAR EN DESARROLLO SI ES EL CÓDIGO 123456
      if (code == '123456') {
        final currentUser = state.user;
        if (currentUser != null) {
           state = AuthState.authenticated(LoggedUser(
            id: currentUser.id,
            username: currentUser.username,
            email: currentUser.email,
            isStaff: currentUser.isStaff,
            role: currentUser.role,
            isVerified: true,
          ));
          return;
        }
      }
      state = state.copyWith(status: AuthStatus.authenticated, error: 'Código incorrecto. Prueba con 123456');
    }
  }

  Future<void> loginByRole(String role) async {
    state = const AuthState.checking();
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final user = LoggedUser(
      id: 1,
      username: 'Test $role',
      email: '$role@test.com',
      isStaff: role == 'admin' || role == 'nutricionista',
      role: role,
    );
    
    state = AuthState.authenticated(user);
  }

  Future<void> register(
    String username,
    String email,
    String password,
    String password2,
  ) async {
    state = const AuthState.checking();
    try {
      final user = await _repository.register(
        username.trim(), email.trim(), password, password2,
      );
      // Forzamos que el usuario esté verificado localmente para omitir la pantalla
      final verifiedUser = LoggedUser(
        id: user.id,
        username: user.username,
        email: user.email,
        isStaff: user.isStaff,
        role: user.role,
        isVerified: true,
      );
      state = AuthState.authenticated(verifiedUser);
    } on ApiException catch (e) {
      state = AuthState.unauthenticated(e.message);
    } catch (e) {
      state = const AuthState.unauthenticated('El usuario o email ya existen.');
    }
  }

  Future<void> logout() async {
    try {
      await _repository.logout();
    } catch (_) {}
    state = const AuthState.unauthenticated();
  }

  void handleInvalidToken() {
    state = const AuthState.unauthenticated('Sesión expirada. Por favor inicia sesión de nuevo.');
  }

  // NUEVO: Actualizar información del usuario localmente para que se refleje en toda la app
  void updateLocalUser(String newUsername, String newEmail) {
    final currentUser = state.user;
    if (currentUser != null) {
      state = AuthState.authenticated(LoggedUser(
        id: currentUser.id,
        username: newUsername,
        email: newEmail,
        isStaff: currentUser.isStaff,
        role: currentUser.role,
        isVerified: currentUser.isVerified,
      ));
      // También guardamos en el storage persistente
      _storage.saveUser(
        id: currentUser.id,
        username: newUsername,
        email: newEmail,
        isStaff: currentUser.isStaff,
        role: currentUser.role,
        isVerified: currentUser.isVerified,
      );
    }
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(secureStorageProvider),
  );
});
