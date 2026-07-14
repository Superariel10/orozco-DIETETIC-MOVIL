// lib/presentation/screens/admin/admin_config_screen.dart

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class AdminConfigScreen extends StatelessWidget {
  const AdminConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('CONFIGURACIÓN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const _ConfigSection(
            title: 'SISTEMA Y PAGOS',
            items: [
              _ConfigTile(icon: Icons.currency_exchange_rounded, title: 'Moneda del Sistema', subtitle: 'Dólar (USD)', color: Colors.blue),
              _ConfigTile(icon: Icons.percent_rounded, title: 'Impuestos / IVA', subtitle: '15%', color: Colors.orange),
            ],
          ),
          const SizedBox(height: 32),
          const _ConfigSection(
            title: 'NOTIFICACIONES GLOBALES',
            items: [
              _ConfigTile(icon: Icons.notifications_active_rounded, title: 'Alertas de Citas', subtitle: 'Activado para todos los usuarios', color: Colors.green),
              _ConfigTile(icon: Icons.email_rounded, title: 'Envío de Reportes', subtitle: 'Resumen semanal automático', color: Colors.purple),
            ],
          ),
          const SizedBox(height: 32),
          const _ConfigSection(
            title: 'MANTENIMIENTO',
            items: [
              _ConfigTile(icon: Icons.backup_rounded, title: 'Copia de Seguridad', subtitle: 'Última hace 2 horas', color: Colors.teal),
              _ConfigTile(icon: Icons.delete_forever_rounded, title: 'Limpiar Caché', subtitle: 'Liberar espacio en el servidor', color: Colors.red),
            ],
          ),
          const SizedBox(height: 40),
          const Center(
            child: Text('Dietética App v1.0.0', style: TextStyle(color: AppColors.textFaint, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _ConfigSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  const _ConfigSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5)),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15)],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }
}

class _ConfigTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  const _ConfigTile({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
      onTap: () {},
    );
  }
}
