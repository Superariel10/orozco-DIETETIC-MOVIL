// lib/domain/repository/auth_repository.dart

import '../model/auth_models.dart';

abstract class AuthRepository {
  Future<LoggedUser> login(String username, String password);
  Future<LoggedUser> register(String username, String email, String password, String password2);
  Future<void> verifyEmail(String code);
  Future<void> logout();
  Future<void> requestPasswordReset(String email);
  Future<void> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
    required String newPassword2,
  });
}
