// lib/presentation/screens/nutri/agenda_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/kpi_card.dart';

class NutriAgendaScreen extends ConsumerWidget {
  const NutriAgendaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminOrdersProvider),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _Header(title: 'MI RESUMEN DIARIO'),
          const SizedBox(height: 16),

          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: KpiCard(
                    title: 'Citas Hoy',
                    value: '8',
                    icon: Icons.calendar_today_rounded,
                    color: AppColors.nutriDetail,
                    onTap: () {},
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: KpiCard(
                    title: 'Pendientes',
                    value: '3',
                    icon: Icons.pending_actions_rounded,
                    color: AppColors.adminAlert,
                    onTap: () {},
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
          const _Header(title: 'PRÓXIMAS CONSULTAS'),
          const SizedBox(height: 16),

          ordersAsync.when(
            data: (orders) {
              if (orders.isEmpty) return const _EmptyState();
              return Column(
                children: orders.map((cita) => _AppointmentCard(
                  time: '09:00 AM',
                  patient: 'Paciente #${cita.id}',
                  status: cita.status,
                )).toList(),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator(color: AppColors.nutriDetail)),
            error: (e, __) {
              final errorMsg = e.toString();
              if (errorMsg.contains('autenticación')) {
                return const _AuthErrorState();
              }
              return Center(child: Text('Error: $e'));
            },
          ),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5));
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
      child: const Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 50, color: AppColors.textFaint),
          const SizedBox(height: 16),
          const Text('Agenda despejada por hoy', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _AuthErrorState extends StatelessWidget {
  const _AuthErrorState();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.error.withOpacity(0.2)),
      ),
      child: const Column(
        children: [
          Icon(Icons.lock_person_rounded, color: AppColors.error, size: 40),
          SizedBox(height: 12),
          Text(
            'Modo de Prueba Activo',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.error)
          ),
          SizedBox(height: 4),
          Text(
            'Para ver datos reales del servidor, por favor inicia sesión con una cuenta de Nutricionista real creada en el registro.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final String time;
  final String patient;
  final String status;

  const _AppointmentCard({required this.time, required this.patient, required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppColors.nutriDetail.withOpacity(0.1), borderRadius: BorderRadius.circular(16)),
            child: const Icon(Icons.access_time_filled_rounded, color: AppColors.nutriDetail, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(patient, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(status.toUpperCase(), style: const TextStyle(color: AppColors.textFaint, fontSize: 10, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textFaint),
        ],
      ),
    );
  }
}
