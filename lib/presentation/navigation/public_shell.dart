// lib/presentation/navigation/public_shell.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';

class PublicShell extends ConsumerWidget {
  final Widget child;
  const PublicShell({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;

    int _selectedIndex() {
      if (location.startsWith('/rutinas')) return 1;
      if (location.startsWith('/progreso')) return 2;
      if (location.startsWith('/diario')) return 3;
      if (location.startsWith('/profile')) return 4;
      return 0;
    }

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex(),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined), activeIcon: Icon(Icons.fitness_center), label: 'Rutinas'),
          BottomNavigationBarItem(icon: Icon(Icons.photo_library_outlined), activeIcon: Icon(Icons.photo_library), label: 'Progreso'),
          BottomNavigationBarItem(icon: Icon(Icons.book_outlined), activeIcon: Icon(Icons.book), label: 'Diario'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
        onTap: (index) {
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/rutinas'); break;
            case 2: context.go('/progreso'); break;
            case 3: context.go('/diario'); break;
            case 4: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}
