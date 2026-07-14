// lib/presentation/widgets/shared/custom_drawer.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/config/app_config.dart';

class CustomDrawer extends ConsumerWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final profileAsync = ref.watch(profileProvider);
    final location = GoRouterState.of(context).matchedLocation;
    final role = user?.role ?? 'paciente';

    return Drawer(
      backgroundColor: Colors.white,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        children: [
          // Header Modernizado con Foto de Perfil Real
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                  child: profileAsync.when(
                    data: (p) {
                      String? url = p.avatarUrl;
                      if (url != null && !url.startsWith('http')) {
                        final base = Uri.parse(AppConfig.baseUrl);
                        url = '${base.scheme}://${base.host}$url';
                      }
                      return CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        backgroundImage: (url != null && url.isNotEmpty)
                          ? NetworkImage('$url?t=${DateTime.now().millisecondsSinceEpoch}')
                          : null,
                        child: (url == null || url.isEmpty)
                          ? Text(user?.username[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.primary))
                          : null,
                      );
                    },
                    loading: () => const CircleAvatar(radius: 40, child: CircularProgressIndicator()),
                    error: (_, __) => CircleAvatar(radius: 40, child: Text(user?.username[0].toUpperCase() ?? 'U')),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.username ?? 'Usuario',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: Colors.white, letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    role.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1),
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
              children: [
                if (role == 'admin') ..._buildAdminMenu(location),
                if (role == 'nutricionista') ..._buildNutriMenu(location),
                if (role == 'paciente') ..._buildPatientMenu(location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAdminMenu(String location) => [
    const _DrawerGroup(title: 'DASHBOARD'),
    _DrawerTile(icon: Icons.dashboard_rounded, label: 'Panel Principal', route: '/admin', isSelected: location == '/admin'),
    const SizedBox(height: 24),
    const _DrawerGroup(title: 'GESTIÓN'),
    _DrawerTile(icon: Icons.group_rounded, label: 'Usuarios', route: '/admin/usuarios', isSelected: location.startsWith('/admin/usuarios')),
    _DrawerTile(icon: Icons.medical_services_rounded, label: 'Nutricionistas', route: '/admin/personal', isSelected: location.startsWith('/admin/personal')),
    _DrawerTile(icon: Icons.person_rounded, label: 'Pacientes', route: '/admin/pacientes', isSelected: location.startsWith('/admin/pacientes')),
    const SizedBox(height: 24),
    const _DrawerGroup(title: 'ALIMENTACIÓN'),
    _DrawerTile(icon: Icons.restaurant_menu_rounded, label: 'Recetas', route: '/admin/recetas', isSelected: location.startsWith('/admin/recetas')),
    _DrawerTile(icon: Icons.category_rounded, label: 'Categorías', route: '/admin/catalogo', isSelected: location.startsWith('/admin/catalogo')),
    _DrawerTile(icon: Icons.assignment_rounded, label: 'Planes Nutricionales', route: '/admin/planes', isSelected: location.startsWith('/admin/planes')),
    const SizedBox(height: 24),
    const _DrawerGroup(title: 'SISTEMA'),
    _DrawerTile(icon: Icons.receipt_long_rounded, label: 'Facturación', route: '/admin/facturacion', isSelected: location.startsWith('/admin/facturacion')),
    _DrawerTile(icon: Icons.bar_chart_rounded, label: 'Reportes', route: '/admin/reportes', isSelected: location.startsWith('/admin/reportes')),
    _DrawerTile(icon: Icons.settings_rounded, label: 'Configuración', route: '/admin/config', isSelected: location.startsWith('/admin/config')),
  ];

  List<Widget> _buildNutriMenu(String location) => [
    const _DrawerGroup(title: 'CLÍNICA'),
    _DrawerTile(icon: Icons.home_rounded, label: 'Inicio', route: '/nutri', isSelected: location == '/nutri'),
    _DrawerTile(icon: Icons.people_rounded, label: 'Mis Pacientes', route: '/nutri/pacientes', isSelected: location.startsWith('/nutri/pacientes')),
    _DrawerTile(icon: Icons.event_note_rounded, label: 'Consultas', route: '/nutri/consultas', isSelected: location.startsWith('/nutri/consultas')),
    _DrawerTile(icon: Icons.assignment_rounded, label: 'Planes', route: '/nutri/planes', isSelected: location.startsWith('/nutri/planes')),
    const SizedBox(height: 24),
    const _DrawerGroup(title: 'HERRAMIENTAS'),
    _DrawerTile(icon: Icons.calendar_month_rounded, label: 'Agenda', route: '/nutri/agenda', isSelected: location.startsWith('/nutri/agenda')),
    _DrawerTile(icon: Icons.analytics_rounded, label: 'Seguimiento', route: '/nutri/seguimiento', isSelected: location.startsWith('/nutri/seguimiento')),
    _DrawerTile(icon: Icons.chat_rounded, label: 'Chat', route: '/nutri/chat', isSelected: location.startsWith('/nutri/chat')),
    _DrawerTile(icon: Icons.account_circle_rounded, label: 'Perfil', route: '/nutri/profile', isSelected: location.startsWith('/nutri/profile')),
  ];

  List<Widget> _buildPatientMenu(String location) => [
    const _DrawerGroup(title: 'MI SALUD'),
    _DrawerTile(icon: Icons.home_rounded, label: 'Inicio', route: '/patient', isSelected: location == '/patient'),
    _DrawerTile(icon: Icons.restaurant_menu_rounded, label: 'Mi Plan', route: '/patient/plan', isSelected: location.startsWith('/patient/plan')),
    _DrawerTile(icon: Icons.analytics_rounded, label: 'Seguimiento', route: '/patient/progreso', isSelected: location.startsWith('/patient/progreso')),
    const SizedBox(height: 24),
    const _DrawerGroup(title: 'CONSULTAS'),
    _DrawerTile(icon: Icons.chat_rounded, label: 'Chat Nutri', route: '/patient/chat', isSelected: location.startsWith('/patient/chat')),
    _DrawerTile(icon: Icons.event_rounded, label: 'Mis Citas', route: '/patient/consultas', isSelected: location.startsWith('/patient/consultas')),
    _DrawerTile(icon: Icons.account_circle_rounded, label: 'Perfil', route: '/patient/profile', isSelected: location.startsWith('/patient/profile')),
  ];
}

class _DrawerGroup extends StatelessWidget {
  final String title;
  const _DrawerGroup({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textFaint, letterSpacing: 1.5),
      ),
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
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isSelected ? AppColors.primary : Colors.transparent,
      ),
      child: ListTile(
        visualDensity: const VisualDensity(vertical: -1),
        leading: Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 24),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            fontSize: 15,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          context.go(route);
        },
      ),
    );
  }
}
