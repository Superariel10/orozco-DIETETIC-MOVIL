// lib/presentation/screens/admin/admin_reportes_screen.dart

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AdminReportesScreen extends StatelessWidget {
  const AdminReportesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('REPORTES Y MÉTRICAS', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _ReportCard(
            title: 'Pacientes Nuevos',
            value: '+12',
            subtitle: 'Crecimiento este mes',
            icon: Icons.person_add_rounded,
            color: Colors.blue,
            percentage: 0.75,
          ),
          const SizedBox(height: 16),
          const _ReportCard(
            title: 'Planes Vendidos',
            value: '45',
            subtitle: 'Rendimiento comercial',
            icon: Icons.shopping_bag_rounded,
            color: Colors.green,
            percentage: 0.88,
          ),
          const SizedBox(height: 16),
          const _ReportCard(
            title: 'Ingresos Mensuales',
            value: '\$1,240.00',
            subtitle: 'Meta: \$2,000.00',
            icon: Icons.monetization_on_rounded,
            color: Colors.orange,
            percentage: 0.62,
          ),
          const SizedBox(height: 32),
          const Text('RENDIMIENTO DEL STAFF',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5)),
          const SizedBox(height: 16),
          _StaffTile(name: 'Dra. Maria Cosio', role: 'Nutricionista', patients: 12, rating: 4.8),
          _StaffTile(name: 'Dr. Roberto Gil', role: 'Especialista', patients: 8, rating: 4.5),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final String title, value, subtitle;
  final IconData icon;
  final Color color;
  final double percentage;

  const _ReportCard({required this.title, required this.value, required this.subtitle, required this.icon, required this.color, required this.percentage});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle), child: Icon(icon, color: color, size: 24)),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                    Text(subtitle, style: const TextStyle(color: AppColors.textFaint, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 22)),
            ],
          ),
          const SizedBox(height: 24),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(value: percentage, minHeight: 8, backgroundColor: AppColors.surface2, valueColor: AlwaysStoppedAnimation(color)),
          ),
        ],
      ),
    );
  }
}

class _StaffTile extends StatelessWidget {
  final String name, role;
  final int patients;
  final double rating;
  const _StaffTile({required this.name, required this.role, required this.patients, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: AppColors.surface2, child: Icon(Icons.person, color: AppColors.primary)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text('$patients pacientes activos', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            ]),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Row(children: [const Icon(Icons.star_rounded, color: Colors.amber, size: 14), const SizedBox(width: 4), Text(rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber))]),
          ),
        ],
      ),
    );
  }
}
