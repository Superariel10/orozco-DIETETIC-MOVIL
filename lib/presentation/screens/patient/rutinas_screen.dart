// lib/presentation/screens/patient/rutinas_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/patient_provider.dart';
import '../../../theme/app_colors.dart';

class RutinasScreen extends ConsumerWidget {
  const RutinasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinasAsync = ref.watch(patientRutinasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Rutinas')),
      body: rutinasAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (rutinas) {
          if (rutinas.isEmpty) {
            return const Center(child: Text('No tienes rutinas asignadas aún.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: rutinas.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rutina = rutinas[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE8F5E9),
                    child: Icon(Icons.fitness_center, color: AppColors.primary),
                  ),
                  title: Text(rutina.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${rutina.durationMinutes} min • Dificultad: ${rutina.difficulty}'),
                  trailing: const Icon(Icons.play_circle_outline, color: AppColors.primary),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(rutina.name),
                        content: Text(rutina.description),
                        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
