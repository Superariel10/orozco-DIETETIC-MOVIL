// lib/presentation/screens/admin/admin_generic_list_screen.dart

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/empty_state.dart';

class AdminGenericListScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<Map<String, String>> items;
  final VoidCallback? onAdd;

  const AdminGenericListScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.items = const [],
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado claro y profesional
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                
                // Buscador superior (TextField)
                SearchFilterBar(
                  hintText: 'Buscar en $title...',
                  onSearch: (v) {},
                ),
                
                // Barra de Filtros rápidos (Chips)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['Todos', 'Recientes', 'Activos', 'Pendientes'].map((filter) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ActionChip(
                        label: Text(filter, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        backgroundColor: filter == 'Todos' ? AppColors.primary.withOpacity(0.1) : Colors.white,
                        side: BorderSide(color: filter == 'Todos' ? AppColors.primary : AppColors.borderLight),
                        onPressed: () {},
                      ),
                    )).toList(),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: items.isEmpty
                ? EmptyState(
                    icon: icon,
                    title: 'Sin datos registrados',
                    subtitle: 'Aún no hay elementos en la sección de $title. Pulsa el botón inferior para agregar uno.',
                    buttonLabel: 'REGISTRAR AHORA',
                    onAction: onAdd,
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _ModuleCard(title: item['title'] ?? '', subtitle: item['subtitle'] ?? '', icon: icon);
                    },
                  ),
          ),
        ],
      ),
      
      // Botón Flotante (FAB) para agregar registros
      floatingActionButton: onAdd != null
          ? FloatingActionButton.extended(
              onPressed: onAdd,
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: const Text('AÑADIR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  const _ModuleCard({required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
        ],
      ),
    );
  }
}
