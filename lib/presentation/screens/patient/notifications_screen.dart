// lib/presentation/screens/patient/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: 3,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final notifications = [
            {
              'title': '¡Hora de beber agua!',
              'desc': 'No olvides mantenerte hidratado. Tu meta de hoy es 2.5L.',
              'time': '5 min',
              'icon': Icons.water_drop_rounded,
              'color': Colors.blue,
            },
            {
              'title': 'Nuevo Plan Asignado',
              'desc': 'La Dra. Maria Cosio ha actualizado tu plan nutricional.',
              'time': '2 h',
              'icon': Icons.restaurant_menu_rounded,
              'color': AppColors.primary,
            },
            {
              'title': 'Recordatorio de Cita',
              'desc': 'Mañana tienes una cita a las 10:00 AM.',
              'time': '5 h',
              'icon': Icons.event_available_rounded,
              'color': Colors.orange,
            },
          ];

          final item = notifications[index];

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight, width: 1.5),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (item['color'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
              ),
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      item['title'] as String,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item['time'] as String,
                    style: const TextStyle(fontSize: 10, color: AppColors.textFaint, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  item['desc'] as String,
                  style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
