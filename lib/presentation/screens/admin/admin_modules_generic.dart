// lib/presentation/screens/admin/admin_modules_generic.dart

import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/empty_state.dart';

class AdminModulesGeneric extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget>? children;
  final VoidCallback? onAdd;

  const AdminModulesGeneric({
    super.key,
    required this.title,
    required this.icon,
    this.children,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(title.toUpperCase(), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SearchFilterBar(hintText: 'Buscar en $title...'),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: ['Recientes', 'Activos', 'Pendientes', 'Bloqueados'].map((l) => Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: FilterChip(
                    label: Text(l, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    selected: l == 'Recientes',
                    onSelected: (v) {},
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                    side: BorderSide(color: l == 'Recientes' ? AppColors.primary : AppColors.borderLight),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )).toList(),
              ),
            ),
          ),
          Expanded(
            child: children == null || children!.isEmpty
                ? Center(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: EmptyState(
                        icon: icon,
                        title: 'Sin información',
                        subtitle: 'No se encontraron registros de $title para mostrar en este momento.'
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                    itemCount: children!.length,
                    itemBuilder: (context, index) => children![index],
                  ),
          ),
        ],
      ),
      floatingActionButton: onAdd != null ? FloatingActionButton(
        onPressed: onAdd,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ) : null,
    );
  }
}
