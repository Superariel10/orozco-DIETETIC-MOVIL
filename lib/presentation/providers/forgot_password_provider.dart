// lib/presentation/providers/forgot_password_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/auth_repository.dart';
import '../../data/repository/auth_repository_impl.dart';

sealed class ForgotPasswordState {
  const ForgotPasswordState();
}

class ForgotPasswordIdle    extends ForgotPasswordState { const ForgotPasswordIdle(); }
class ForgotPasswordLoading extends ForgotPasswordState { const ForgotPasswordLoading(); }
class ForgotPasswordSuccess extends ForgotPasswordState { const ForgotPasswordSuccess(); }

class ForgotPasswordError extends ForgotPasswordState {
  final String message;
  const ForgotPasswordError(this.message);
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final AuthRepository _repository;

  ForgotPasswordNotifier(this._repository) : super(const ForgotPasswordIdle());

  Future<void> requestReset(String email) async {
    if (state is ForgotPasswordLoading) return;
    state = const ForgotPasswordLoading();
    try {
      await _repository.requestPasswordReset(email.trim());
      state = const ForgotPasswordSuccess();
    } catch (e) {
      state = ForgotPasswordError(
        e.toString().replaceAll('Exception: ', ''),
      );
    }
  }

  void clearError() {
    if (state is ForgotPasswordError) state = const ForgotPasswordIdle();
  }
}

final forgotPasswordProvider = StateNotifierProvider.autoDispose<
    ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  return ForgotPasswordNotifier(ref.watch(authRepositoryProvider));
});
