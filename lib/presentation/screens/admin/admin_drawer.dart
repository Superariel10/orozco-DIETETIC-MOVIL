// lib/presentation/screens/admin/admin_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class AdminDrawer extends ConsumerWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final location = GoRouterState.of(context).matchedLocation;

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header Modernizado con Avatar Grande
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.admin_panel_settings_rounded, size: 50, color: AppColors.primary),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.username ?? 'Administrador',
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: const Text('ACCESO MAESTRO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
              children: [
                _SectionTitle(title: 'DASHBOARD'),
                _DrawerTile(icon: Icons.dashboard_rounded, label: 'Dashboard', route: '/admin', isSelected: location == '/admin'),

                const SizedBox(height: 24),
                _SectionTitle(title: 'GESTIÓN'),
                _DrawerTile(icon: Icons.group_rounded, label: 'Usuarios', route: '/admin/usuarios', isSelected: location.startsWith('/admin/usuarios')),
                _DrawerTile(icon: Icons.medical_services_rounded, label: 'Nutricionistas', route: '/admin/personal', isSelected: location.startsWith('/admin/personal')),
                _DrawerTile(icon: Icons.person_rounded, label: 'Pacientes', route: '/admin/pacientes', isSelected: location.startsWith('/admin/pacientes')),

                const SizedBox(height: 24),
                _SectionTitle(title: 'ALIMENTACIÓN'),
                _DrawerTile(icon: Icons.restaurant_menu_rounded, label: 'Recetas', route: '/admin/recetas', isSelected: location.startsWith('/admin/recetas')),
                _DrawerTile(icon: Icons.category_rounded, label: 'Categorías', route: '/admin/catalogo', isSelected: location.startsWith('/admin/catalogo')),
                _DrawerTile(icon: Icons.assignment_rounded, label: 'Planes Nutricionales', route: '/admin/planes', isSelected: location.startsWith('/admin/planes')),

                const SizedBox(height: 24),
                _SectionTitle(title: 'SISTEMA'),
                _DrawerTile(icon: Icons.receipt_long_rounded, label: 'Facturación', route: '/admin/facturacion', isSelected: location.startsWith('/admin/facturacion')),
                _DrawerTile(icon: Icons.bar_chart_rounded, label: 'Reportes', route: '/admin/reportes', isSelected: location.startsWith('/admin/reportes')),
                _DrawerTile(icon: Icons.settings_rounded, label: 'Configuración', route: '/admin/config', isSelected: location.startsWith('/admin/config')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textFaint, letterSpacing: 1.5)),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isSelected;
  const _DrawerTile({required this.icon, required this.label, required this.route, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -2),
        leading: Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 22),
        title: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500)),
        onTap: () => context.go(route),
      ),
    );
  }
}
