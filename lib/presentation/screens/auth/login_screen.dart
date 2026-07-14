// lib/presentation/screens/auth/login_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/auth_button.dart';
import '../../widgets/auth_text_field.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fondo Gradiente Moderno (Verde a Azul Salud)
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),
          
          // 2. Contenido con Glassmorphism real
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 70),
                        const SizedBox(height: 20),
                        const Text(
                          'Dietetic App',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.5,
                          ),
                        ),
                        Text(
                          'Bienvenido a tu salud inteligente',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 48),

                        // Campos con tipografía blanca y estilizada
                        AuthTextField(
                          controller: _userController,
                          label: 'Nombre de Usuario',
                          icon: Icons.person_rounded,
                          filledColor: Colors.white.withValues(alpha: 0.08),
                          textColor: Colors.white,
                        ),
                        const SizedBox(height: 20),
                        AuthTextField(
                          controller: _passController,
                          label: 'Contraseña de Acceso',
                          icon: Icons.lock_rounded,
                          isPassword: true,
                          filledColor: Colors.white.withValues(alpha: 0.08),
                          textColor: Colors.white,
                        ),
                        
                        const SizedBox(height: 40),

                        AuthButton(
                          label: 'INICIAR SESIÓN',
                          isLoading: authState.isChecking,
                          onPressed: () {
                            ref.read(authProvider.notifier).login(
                              _userController.text,
                              _passController.text,
                            );
                          },
                        ),
                        
                        if (authState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: Text(
                              authState.error!,
                              style: const TextStyle(color: Color(0xFFFF6B6B), fontWeight: FontWeight.bold, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 32),
                        const Text(
                          'O entrar como (Prueba):',
                          style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _RoleButton(label: 'Admin', role: 'admin', ref: ref)),
                            const SizedBox(width: 10),
                            Expanded(child: _RoleButton(label: 'Nutri', role: 'nutricionista', ref: ref)),
                            const SizedBox(width: 10),
                            Expanded(child: _RoleButton(label: 'Paciente', role: 'paciente', ref: ref)),
                          ],
                        ),

                        const SizedBox(height: 32),
                        TextButton(
                          onPressed: () => context.push('/register'),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: const TextStyle(color: Colors.white70, fontSize: 14),
                              children: [
                                const TextSpan(text: '¿Eres nuevo? '),
                                TextSpan(
                                  text: 'Crea una cuenta aquí',
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
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String label;
  final String role;
  final WidgetRef ref;

  const _RoleButton({required this.label, required this.role, required this.ref});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.white.withOpacity(0.3)),
        minimumSize: const Size(0, 44),
        padding: EdgeInsets.zero,
        backgroundColor: Colors.white.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () => ref.read(authProvider.notifier).loginByRole(role),
      child: FittedBox(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
            fontWeight: FontWeight.bold
          )
        ),
      ),
    );
  }
}
