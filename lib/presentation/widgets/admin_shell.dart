// lib/presentation/widgets/admin_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import 'shared/custom_app_bar.dart';
import 'shared/custom_drawer.dart';

class AdminShell extends ConsumerWidget {
  final Widget child;
  const AdminShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    String _getTitle() {
      if (location.startsWith('/admin/usuarios')) return 'Usuarios';
      if (location.startsWith('/admin/personal')) return 'Nutricionistas';
      if (location.startsWith('/admin/pacientes')) return 'Pacientes';
      if (location.startsWith('/admin/recetas')) return 'Recetas';
      if (location.startsWith('/admin/catalogo')) return 'Categorías';
      if (location.startsWith('/admin/planes')) return 'Planes';
      return 'Panel Principal';
    }

    int _selectedIndex() {
      if (location.startsWith('/admin/usuarios')) return 1;
      if (location.startsWith('/admin/personal')) return 2;
      if (location.startsWith('/admin/pacientes')) return 3;
      return 0;
    }

    return Scaffold(
      appBar: CustomAppBar(title: _getTitle()),
      drawer: const CustomDrawer(),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex(),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Resumen'),
            BottomNavigationBarItem(icon: Icon(Icons.group_outlined), activeIcon: Icon(Icons.group_rounded), label: 'Usuarios'),
            BottomNavigationBarItem(icon: Icon(Icons.medical_services_outlined), activeIcon: Icon(Icons.medical_services_rounded), label: 'Nutris'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline_rounded), activeIcon: Icon(Icons.person_rounded), label: 'Pacientes'),
          ],
          onTap: (index) {
            switch (index) {
              case 0: context.go('/admin'); break;
              case 1: context.go('/admin/usuarios'); break;
              case 2: context.go('/admin/personal'); break;
              case 3: context.go('/admin/pacientes'); break;
            }
          },
        ),
      ),
    );
  }
}
