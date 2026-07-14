// lib/presentation/screens/admin/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/shared/kpi_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final products = ref.watch(adminProductsProvider);
    final planes = ref.watch(adminPlanesProvider);
    final alimentos = ref.watch(adminAlimentosProvider);
    final nutris = ref.watch(adminNutricionistasProvider);

    String _getValue(AsyncValue<List<dynamic>> async) {
      if (async.hasValue) return async.value!.length.toString();
      return '0';
    }

    bool _isLoading(AsyncValue<List<dynamic>> async) {
      return async.isLoading && !async.hasValue;
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        ref.invalidate(adminProductsProvider);
        ref.invalidate(adminPlanesProvider);
        ref.invalidate(adminAlimentosProvider);
        ref.invalidate(adminNutricionistasProvider);
      },
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _SectionHeader(title: 'CONTROL MAESTRO'),
          const SizedBox(height: 16),

          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: [
              KpiCard(
                title: 'Pacientes',
                value: _getValue(products),
                icon: Icons.people_alt_rounded,
                color: AppColors.primary,
                isLoading: _isLoading(products),
              ),
              KpiCard(
                title: 'Nutricionistas',
                value: _getValue(nutris),
                icon: Icons.medical_services_rounded,
                color: AppColors.accent,
                isLoading: _isLoading(nutris),
              ),
              KpiCard(
                title: 'Planes Activos',
                value: _getValue(planes),
                icon: Icons.assignment_turned_in_rounded,
                color: AppColors.success,
                isLoading: _isLoading(planes),
              ),
              KpiCard(
                title: 'Recetas',
                value: _getValue(alimentos),
                icon: Icons.restaurant_menu_rounded,
                color: AppColors.warning,
                isLoading: _isLoading(alimentos),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const _SectionHeader(title: 'FACTURACIÓN MENSUAL'),
          const SizedBox(height: 16),
          const _FacturacionCard(),

          const SizedBox(height: 32),
          const _SectionHeader(title: 'ACTIVIDAD RECIENTE'),
          const SizedBox(height: 16),
          const _ActivityTile(title: 'Nuevo Registro', subtitle: 'Paciente ha actualizado su perfil', time: 'Hoy', icon: Icons.person_add_alt_1_rounded),
          const _ActivityTile(title: 'Pago Recibido', subtitle: 'Carlos Perez - Plan Keto', time: '10:45 AM', icon: Icons.monetization_on_rounded),
          const _ActivityTile(title: 'Plan Creado', subtitle: 'Nuevo Plan asignado correctamente', time: 'Hoy', icon: Icons.auto_awesome_rounded),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5));
  }
}

class _FacturacionCard extends StatelessWidget {
  const _FacturacionCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ingresos Totales (Julio)', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          Text('\$12,540.00', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: -1)),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.trending_up_rounded, color: Colors.white70, size: 16),
              SizedBox(width: 4),
              Text('+15% respecto al mes anterior', style: TextStyle(color: Colors.white70, fontSize: 12)),
            ],
          ),
        ],
      ),
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
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        children: [
          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: AppColors.primary, size: 18)),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary)), Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11))])),
          Text(time, style: const TextStyle(color: AppColors.textFaint, fontSize: 10, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
