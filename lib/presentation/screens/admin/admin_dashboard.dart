// lib/presentation/screens/admin/admin_dashboard.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/shared/kpi_card.dart';

class AdminDashboard extends ConsumerWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminOrdersProvider);
          ref.invalidate(adminProductsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const _Header(title: 'CONTROL MAESTRO'),
            const SizedBox(height: 16),
            
            // 1. Grid de tarjetas con sombras para: Total Pacientes (24), Total Nutricionistas (6), Total Planes (12), Total Recetas (15).
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.1,
              children: const [
                KpiCard(title: 'Pacientes', value: '24', icon: Icons.people_alt_rounded, color: AppColors.primary),
                KpiCard(title: 'Nutris', value: '6', icon: Icons.medical_services_rounded, color: AppColors.accent),
                KpiCard(title: 'Planes', value: '12', icon: Icons.assignment_turned_in_rounded, color: AppColors.success),
                KpiCard(title: 'Recetas', value: '15', icon: Icons.restaurant_menu_rounded, color: AppColors.warning),
              ],
            ),

            const SizedBox(height: 32),
            const _Header(title: 'ESTADÍSTICAS FINANCIERAS'),
            const SizedBox(height: 16),
            const _BillingSection(),

            const SizedBox(height: 32),
            const _Header(title: 'CRECIMIENTO DEL SISTEMA'),
            const SizedBox(height: 16),
            const _GrowthChartSection(),

            const SizedBox(height: 32),
            const _Header(title: 'ACTIVIDAD RECIENTE'),
            const SizedBox(height: 16),
            const _ActivityFeed(),
            
            const SizedBox(height: 100),
          ],
        ),
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

class _BillingSection extends StatelessWidget {
  const _BillingSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Facturación Mensual', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(Icons.account_balance_wallet_rounded, color: Colors.white70, size: 20),
            ],
          ),
          SizedBox(height: 12),
          Text('\$12,540.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
          SizedBox(height: 8),
          Text('Consultas del día: 8 agendadas', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GrowthChartSection extends StatelessWidget {
  const _GrowthChartSection();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Usuarios Nuevos', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              Text('+22%', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [0.4, 0.7, 0.5, 0.9, 0.6, 0.8].map((v) => Container(
              width: 18,
              height: 120 * v,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.8),
                borderRadius: BorderRadius.circular(4),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun'].map((l) => Text(l, style: const TextStyle(fontSize: 10, color: AppColors.textSecondary))).toList(),
          ),
        ],
      ),
    );
  }
}

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ActivityTile(title: 'Juan Pérez', subtitle: 'Registrado como nuevo paciente', time: '10:30 AM', icon: Icons.person_add_rounded),
        _ActivityTile(title: 'Dra. Maria Cosio', subtitle: 'Consulta completada con prueba12', time: '09:45 AM', icon: Icons.check_circle_rounded),
        _ActivityTile(title: 'Plan Keto Premium', subtitle: 'Asignado a 4 nuevos pacientes', time: 'Ayer', icon: Icons.auto_awesome_rounded),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  final String title, subtitle, time;
  final IconData icon;
  const _ActivityTile({required this.title, required this.subtitle, required this.time, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11)),
            ]),
          ),
          Text(time, style: const TextStyle(color: AppColors.textFaint, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
