// lib/presentation/screens/patient/diario_salud_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/patient_provider.dart';
import '../../../data/repository/patient_repository_impl.dart';
import '../../../theme/app_colors.dart';

class DiarioSaludScreen extends ConsumerWidget {
  const DiarioSaludScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aguaAsync = ref.watch(patientAguaProvider);
    final sintomasAsync = ref.watch(patientSintomasProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mi Diario de Salud')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Sección de Agua
          Card(
            elevation: 0,
            color: const Color(0xFFE3F2FD),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Icon(Icons.local_drink_rounded, color: Colors.blue, size: 40),
                  const SizedBox(height: 12),
                  const Text('Hidratación Diaria', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _WaterAction(label: '+ 250ml', icon: Icons.local_drink, onTap: () async {
                        await ref.read(patientRepositoryProvider).addRegistroAgua(0.25);
                        ref.invalidate(patientAguaProvider);
                      }),
                      _WaterAction(label: '+ 500ml', icon: Icons.wine_bar, onTap: () async {
                        await ref.read(patientRepositoryProvider).addRegistroAgua(0.5);
                        ref.invalidate(patientAguaProvider);
                      }),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          const Text('Mis Síntomas', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          
          sintomasAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
            data: (sintomas) {
              if (sintomas.isEmpty) return const Text('No has registrado síntomas.');
              return Column(
                children: sintomas.map((s) => Card(
                  child: ListTile(
                    leading: CircleAvatar(backgroundColor: Colors.orange.withValues(alpha: 0.1), child: Text(s.intensity.toString(), style: const TextStyle(color: Colors.orange))),
                    title: Text(s.description),
                    subtitle: Text(s.date),
                  ),
                )).toList(),
              );
            },
          ),

          const SizedBox(height: 32),
          const Text('Historial de Agua', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 12),
          
          aguaAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Text('Error: $error'),
            data: (registros) {
              if (registros.isEmpty) return const Text('No hay registros.');
              return Column(
                children: registros.map((r) => ListTile(
                  leading: const Icon(Icons.water_drop, color: Colors.blue),
                  title: Text('${r.amountLiters} Litros'),
                  subtitle: Text(r.date),
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _WaterAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _WaterAction({required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, color: Colors.blue),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
        ],
      ),
    );
  }
}
