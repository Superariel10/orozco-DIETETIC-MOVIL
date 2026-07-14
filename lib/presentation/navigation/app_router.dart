// lib/presentation/navigation/app_router.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/model/auth_state.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/profile_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/reset_password_confirm_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/verification_screen.dart';
import '../screens/catalog/home_screen.dart';
import '../screens/patient/notifications_screen.dart';
import '../screens/patient/progreso_screen.dart';
import '../screens/patient/plan_semanal_screen.dart';
import '../screens/patient/patient_planes_screen.dart';
import '../screens/patient/cart_screen.dart';
import '../screens/patient/chat_logros_screen.dart';
import '../screens/patient/consultas_screen.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/admin_nutricionistas_screen.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_users_screen.dart';
import '../screens/admin/admin_modules_generic.dart';
import '../screens/admin/admin_recetas_screen.dart';
import '../screens/admin/admin_planes_nutricionales_screen.dart';
import '../screens/nutri/agenda_screen.dart';
import '../widgets/admin_shell.dart';
import 'patient_shell.dart';
import 'nutri_shell.dart';

import '../screens/admin/admin_facturacion_screen.dart';
import '../screens/admin/admin_config_screen.dart';
import '../screens/admin/admin_reportes_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: _AuthStateListenable(ref),
    redirect: (context, state) {
      final auth     = ref.read(authProvider);
      final location = state.matchedLocation;

      if (auth.isChecking) return null;
      if (location == '/splash') return null;

      final isAuthRoute = location == '/login'
          || location == '/register'
          || location == '/forgot-password'
          || location == '/reset-password-confirm';

      if (!auth.isAuthenticated && !isAuthRoute) return '/login';
      
      if (auth.isAuthenticated && isAuthRoute) {
        if (auth.user?.isAdmin == true) return '/admin';
        if (auth.user?.isNutricionista == true) return '/nutri';
        return '/patient';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/', redirect: (_, __) => '/splash'),
      GoRoute(path: '/splash',   builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login',    builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/forgot-password',        builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: '/reset-password-confirm', builder: (_, __) => const ResetPasswordConfirmScreen()),

      // ── VISTA PACIENTE ────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => PatientShell(child: child),
        routes: [
          GoRoute(path: '/patient',           builder: (_, __) => const HomeScreen()), 
          GoRoute(path: '/patient/plan',      builder: (_, __) => const PlanSemananalScreen()), 
          GoRoute(path: '/patient/recetas',   builder: (_, __) => const AdminRecetasScreen()),
          GoRoute(path: '/patient/catalogo',  builder: (_, __) => const AdminCategoriesScreen()),
          GoRoute(path: '/patient/planes',    builder: (_, __) => const PatientPlanesScreen()),
          GoRoute(path: '/patient/cart',      builder: (_, __) => const CartScreen()),
          GoRoute(path: '/patient/progreso',  builder: (_, __) => const ProgresoScreen()), 
          GoRoute(path: '/patient/chat',      builder: (_, __) => const ChatLogrosScreen()), 
          GoRoute(path: '/patient/consultas', builder: (_, __) => const PatientConsultasScreen()),
          GoRoute(path: '/patient/profile',   builder: (_, __) => const ProfileScreen()), 
        ],
      ),

      // ── VISTA NUTRICIONISTA ───────────────────────────────
      ShellRoute(
        builder: (_, __, child) => NutriShell(child: child),
        routes: [
          GoRoute(path: '/nutri',             builder: (_, __) => const NutriAgendaScreen()), 
          GoRoute(path: '/nutri/pacientes',   builder: (_, __) => const AdminUsersScreen()), 
          GoRoute(path: '/nutri/consultas',   builder: (_, __) => const NutriAgendaScreen()), 
          GoRoute(path: '/nutri/planes',      builder: (_, __) => const AdminPlanesNutricionalesScreen()), 
          GoRoute(path: '/nutri/agenda',      builder: (_, __) => const NutriAgendaScreen()), 
          GoRoute(
            path: '/nutri/seguimiento', 
            builder: (context, state) {
              final extras = state.extra as Map<String, dynamic>?;
              return ProgresoScreen(
                userId: extras?['userId'] as int?,
                patientName: extras?['patientName'] as String?,
              );
            }
          ),
          GoRoute(path: '/nutri/chat',        builder: (_, __) => const ChatLogrosScreen()), 
          GoRoute(path: '/nutri/profile',     builder: (_, __) => const ProfileScreen()), 
        ],
      ),

      // ── VISTA ADMINISTRADOR ───────────────────────────────
      ShellRoute(
        builder: (_, __, child) => AdminShell(child: child),
        routes: [
          GoRoute(path: '/admin',             builder: (_, __) => const DashboardScreen()), 
          GoRoute(path: '/admin/usuarios',    builder: (_, __) => const AdminUsersScreen()), 
          GoRoute(path: '/admin/personal',    builder: (_, __) => const AdminNutricionistasScreen()), 
          GoRoute(path: '/admin/pacientes',   builder: (_, __) => const AdminUsersScreen()),
          GoRoute(path: '/admin/recetas',     builder: (_, __) => const AdminRecetasScreen()),
          GoRoute(path: '/admin/catalogo',    builder: (_, __) => const AdminCategoriesScreen()), 
          GoRoute(path: '/admin/rutinas',     builder: (_, __) => const AdminModulesGeneric(title: 'Rutinas', icon: Icons.fitness_center_rounded)), 
          GoRoute(path: '/admin/facturacion', builder: (_, __) => const AdminFacturacionScreen()),
          GoRoute(path: '/admin/reportes',    builder: (_, __) => const AdminReportesScreen()),
          GoRoute(path: '/admin/config',      builder: (_, __) => const AdminConfigScreen()),
          GoRoute(path: '/admin/planes',      builder: (_, __) => const AdminPlanesNutricionalesScreen()),
        ],
      ),
      
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
});

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(Ref ref) {
    ref.listen<AuthState>(authProvider, (_, __) => notifyListeners());
  }
}
