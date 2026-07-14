// lib/presentation/navigation/patient_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/custom_drawer.dart';

class PatientShell extends ConsumerWidget {
  final Widget child;
  const PatientShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    String _getTitle() {
      if (location == '/patient/planes') return 'Planes Nutricionales';
      if (location.startsWith('/patient/plan')) return 'Mi Plan';
      if (location.startsWith('/patient/recetas')) return 'Recetas';
      if (location.startsWith('/patient/progreso')) return 'Seguimiento';
      if (location.startsWith('/patient/chat')) return 'Chat';
      if (location.startsWith('/patient/consultas')) return 'Mis Citas';
      return 'Bienvenido';
    }

    int _selectedIndex() {
      if (location == '/patient/planes') return 0; // Se marca Inicio si viene de ahí
      if (location.startsWith('/patient/plan')) return 1;
      if (location.startsWith('/patient/recetas')) return 2;
      if (location.startsWith('/patient/progreso')) return 3;
      if (location.startsWith('/patient/chat')) return 4;
      return 0;
    }

    return Scaffold(
      appBar: CustomAppBar(title: _getTitle()),
      drawer: const CustomDrawer(),
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -5),
            )
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex(),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey.shade400,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.home_rounded, size: 26),
              ),
              label: 'Inicio',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.restaurant_menu_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.restaurant_menu_rounded, size: 26),
              ),
              label: 'Mi Plan',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.menu_book_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.menu_book_rounded, size: 26),
              ),
              label: 'Recetas',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.analytics_outlined, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.analytics_rounded, size: 26),
              ),
              label: 'Progreso',
            ),
            BottomNavigationBarItem(
              icon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_outline_rounded, size: 24),
              ),
              activeIcon: Padding(
                padding: EdgeInsets.only(bottom: 4),
                child: Icon(Icons.chat_bubble_rounded, size: 26),
              ),
              label: 'Chat',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0: context.go('/patient'); break;
              case 1: context.go('/patient/plan'); break;
              case 2: context.go('/patient/recetas'); break;
              case 3: context.go('/patient/progreso'); break;
              case 4: context.go('/patient/chat'); break;
            }
          },
        ),
      ),
    );
  }
}
