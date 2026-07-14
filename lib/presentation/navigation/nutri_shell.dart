// lib/presentation/navigation/nutri_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../widgets/shared/custom_app_bar.dart';
import '../widgets/shared/custom_drawer.dart';

class NutriShell extends ConsumerWidget {
  final Widget child;
  const NutriShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    String _getTitle() {
      if (location.startsWith('/nutri/pacientes')) return 'Pacientes';
      if (location.startsWith('/nutri/consultas')) return 'Consultas';
      if (location.startsWith('/nutri/planes')) return 'Planes';
      if (location.startsWith('/nutri/agenda')) return 'Agenda';
      if (location.startsWith('/nutri/chat')) return 'Chat';
      return 'Nutri Dashboard';
    }

    int _selectedIndex() {
      if (location.startsWith('/nutri/pacientes')) return 1;
      if (location.startsWith('/nutri/consultas')) return 2;
      return 0;
    }

    return Scaffold(
      appBar: CustomAppBar(title: _getTitle()),
      drawer: const CustomDrawer(),
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex(),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: Colors.grey,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Inicio'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline_rounded), activeIcon: Icon(Icons.people_rounded), label: 'Pacientes'),
            BottomNavigationBarItem(icon: Icon(Icons.event_note_outlined), activeIcon: Icon(Icons.event_note_rounded), label: 'Consultas'),
          ],
          onTap: (index) {
            switch (index) {
              case 0: context.go('/nutri'); break;
              case 1: context.go('/nutri/pacientes'); break;
              case 2: context.go('/nutri/consultas'); break;
            }
          },
        ),
      ),
    );
  }
}
