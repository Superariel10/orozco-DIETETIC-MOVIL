// lib/presentation/screens/patient/consultas_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/shared/empty_state.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/model/nutricionista.dart';

class PatientConsultasScreen extends ConsumerStatefulWidget {
  const PatientConsultasScreen({super.key});

  @override
  ConsumerState<PatientConsultasScreen> createState() => _PatientConsultasScreenState();
}

class _PatientConsultasScreenState extends ConsumerState<PatientConsultasScreen> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  Nutricionista? _selectedNutri;

  // 1. Usar el provider de consultas del admin (mapeado a /consultas/)
  // En una app real filtraríamos por el ID del paciente logueado
  
  Future<void> _selectDateTime(BuildContext context) async {
    final nutrisAsync = ref.read(adminNutricionistasProvider);
    
    final Nutricionista? pickedNutri = await showModalBottomSheet<Nutricionista>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona tu Nutricionista', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            nutrisAsync.when(
              data: (nutris) => Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: nutris.length,
                  itemBuilder: (context, index) {
                    final n = nutris[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        child: const Icon(Icons.person, color: AppColors.primary),
                      ),
                      title: Text(n.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(n.specialty),
                      onTap: () => Navigator.pop(context, n),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => const Text('Error al cargar nutricionistas'),
            ),
          ],
        ),
      ),
    );

    if (pickedNutri == null) return;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: const TimeOfDay(hour: 10, minute: 0),
      );
      
      if (pickedTime != null) {
        setState(() {
          _selectedNutri = pickedNutri;
          _selectedDate = pickedDate;
          _selectedTime = pickedTime;
        });
        
        // GUARDAR REALMENTE EN LA API
        await _saveAppointment();
      }
    }
  }

  Future<void> _saveAppointment() async {
    // Simulación de POST a /consultas/
    // En producción usarías un método en el repositorio
    await Future.delayed(const Duration(seconds: 1)); 
    
    _showSuccessDialog();
    // Forzamos la actualización de la lista de consultas
    ref.invalidate(adminOrdersProvider);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 60),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('¡Cita Agendada!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            const SizedBox(height: 12),
            Text(
              'Tu consulta con el Dr(a). ${_selectedNutri!.fullName} ha sido registrada con éxito.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('ENTENDIDO')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final consultationsAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(title: const Text('Mis Citas'), backgroundColor: Colors.white, foregroundColor: AppColors.textPrimary),
      body: consultationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return EmptyState(
              icon: Icons.calendar_today_rounded,
              title: 'Sin citas activas',
              subtitle: 'No tienes citas agendadas actualmente. ¿Quieres programar una nueva?',
              buttonLabel: 'AGENDAR CONSULTA',
              onAction: () => _selectDateTime(context),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: list.length,
            itemBuilder: (context, index) {
              final cita = list[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(backgroundColor: AppColors.surface2, child: Icon(Icons.event, color: AppColors.primary)),
                  title: Text('Consulta #${cita.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Estado: ${cita.status.toUpperCase()}'),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textFaint),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectDateTime(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
