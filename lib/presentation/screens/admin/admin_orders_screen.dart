// lib/presentation/screens/admin/admin_orders_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../data/repository/admin_repository_impl.dart';
import '../../../domain/model/order.dart';
import '../../../theme/app_colors.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Consultas Dietéticas')),
      body: ordersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No hay consultas programadas.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Consulta #${order.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          _StatusBadge(status: order.status),
                        ],
                      ),
                      const Divider(),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.textFaint),
                          const SizedBox(width: 8),
                          Text(order.scheduledTime, style: const TextStyle(fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.notes_rounded, size: 16, color: AppColors.textFaint),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              order.sessionNotes.isNotEmpty ? order.sessionNotes : 'Sin notas registradas',
                              style: const TextStyle(fontSize: 13, fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('Cambiar Estado:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: AppColors.surface2,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: ['programada', 'en_curso', 'completada', 'retrasada', 'cancelada'].contains(order.status) ? order.status : 'programada',
                                  isExpanded: true,
                                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                  items: const [
                                    DropdownMenuItem(value: 'programada', child: Text('Programada')),
                                    DropdownMenuItem(value: 'en_curso', child: Text('En Curso')),
                                    DropdownMenuItem(value: 'completada', child: Text('Completada')),
                                    DropdownMenuItem(value: 'retrasada', child: Text('Retrasada')),
                                    DropdownMenuItem(value: 'cancelada', child: Text('Cancelada')),
                                  ],
                                  onChanged: (newStatus) async {
                                    if (newStatus != null) {
                                      await ref.read(adminOrdersProvider.notifier).updateStatus(order.id, newStatus);
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toLowerCase()) {
      case 'completada': color = AppColors.success; break;
      case 'cancelada':  color = AppColors.error; break;
      case 'en_curso':   color = AppColors.info; break;
      case 'retrasada':  color = AppColors.warning; break;
      default:          color = AppColors.secondary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
