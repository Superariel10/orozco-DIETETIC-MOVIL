// lib/presentation/screens/auth/register_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _userCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitted = true);
    if (!_formKey.currentState!.validate()) return;
    
    await ref.read(authProvider.notifier).register(
          _userCtrl.text,
          _emailCtrl.text,
          _passCtrl.text,
          _pass2Ctrl.text,
        );
    
    final state = ref.read(authProvider);
    
    if (state.error != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.error!,
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  )
                ),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            margin: const EdgeInsets.all(20),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    if (state.isAuthenticated) {
      if (mounted) context.go('/patient');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isChecking;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // Fondo Gradiente igual al Login
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.person_add_rounded, color: Colors.white, size: 60),
                          const SizedBox(height: 16),
                          const Text(
                            'Crear Cuenta',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -1,
                            ),
                          ),
                          Text(
                            'Únete a nuestra comunidad de salud',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 40),

                          AuthTextField(
                            controller: _userCtrl,
                            label: 'Usuario',
                            icon: Icons.person_outline_rounded,
                            filledColor: Colors.white.withValues(alpha: 0.08),
                            textColor: Colors.white,
                            validator: _submitted ? validateUsername : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _emailCtrl,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            filledColor: Colors.white.withValues(alpha: 0.08),
                            textColor: Colors.white,
                            validator: _submitted ? validateEmail : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _passCtrl,
                            label: 'Contraseña',
                            icon: Icons.lock_outline_rounded,
                            isPassword: true,
                            filledColor: Colors.white.withValues(alpha: 0.08),
                            textColor: Colors.white,
                            validator: _submitted ? (v) => (v?.length ?? 0) < 8 ? 'Mínimo 8 caracteres' : null : null,
                          ),
                          const SizedBox(height: 16),
                          AuthTextField(
                            controller: _pass2Ctrl,
                            label: 'Confirmar Contraseña',
                            icon: Icons.lock_reset_rounded,
                            isPassword: true,
                            textInputAction: TextInputAction.done,
                            filledColor: Colors.white.withValues(alpha: 0.08),
                            textColor: Colors.white,
                            validator: _submitted ? (v) => v != _passCtrl.text ? 'Las contraseñas no coinciden' : null : null,
                          ),

                          const SizedBox(height: 32),

                          AuthButton(
                            label: 'REGISTRARSE',
                            isLoading: isLoading,
                            onPressed: _submit,
                          ),

                          const SizedBox(height: 24),
                          TextButton(
                            onPressed: () => context.pop(),
                            child: RichText(
                              text: TextSpan(
                                style: const TextStyle(color: Colors.white70, fontSize: 14),
                                children: [
                                  const TextSpan(text: '¿Ya tienes cuenta? '),
                                  TextSpan(
                                    text: 'Inicia Sesión',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w900,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
