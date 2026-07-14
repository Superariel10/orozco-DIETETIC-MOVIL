// lib/presentation/screens/admin/admin_categories_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/model/alimento.dart';
import '../../../domain/model/category.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/empty_state.dart';

class AdminCategoriesScreen extends ConsumerWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(adminCategoriesProvider);
    final alimentosAsync = ref.watch(adminAlimentosProvider);
    final isAdmin = ref.watch(authProvider).user?.isAdmin ?? false;

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('CATÁLOGO MAESTRO', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: SearchFilterBar(hintText: 'Buscar alimento o categoría...', onSearch: (v) {}),
              ),
              Expanded(
                child: categoriesAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, stack) => const EmptyState(icon: Icons.restaurant_rounded, title: 'Catálogo Maestro', subtitle: 'Registra tu primer alimento.'),
                  data: (categories) {
                    if (categories.isEmpty) {
                      return const EmptyState(icon: Icons.category_rounded, title: 'Sin Categorías', subtitle: 'Agrega categorías para organizar el catálogo.');
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 120), // Aumentamos padding inferior para no tapar con botones
                      itemCount: categories.length,
                      itemBuilder: (context, index) {
                        final cat = categories[index];
                        final catAlimentos = alimentosAsync.maybeWhen(
                          data: (list) => list.where((a) => a.categoryId == cat.id).toList(),
                          orElse: () => <Alimento>[],
                        );

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                          ),
                          child: Theme(
                            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                            child: ExpansionTile(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              leading: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                                child: const Icon(Icons.category_rounded, color: AppColors.primary, size: 20),
                              ),
                              title: Text(cat.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                              subtitle: Text('${catAlimentos.length} elementos', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
                              children: [
                                ...catAlimentos.map((a) => Container(
                                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(16)),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(a.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                                            Text('${a.calories.toInt()} kcal | P: ${a.protein}g | C: ${a.carbs}g', style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                      if (isAdmin) IconButton(icon: const Icon(Icons.delete_outline_rounded, size: 20, color: AppColors.error), onPressed: () => _confirmDelete(context, ref, a)),
                                    ],
                                  ),
                                )),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),

          // BOTONES FLOTANTES PERSONALIZADOS (PARA NO TAPAR EL SCROLL)
          if (isAdmin)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Row(
                children: [
                  Expanded(
                    child: _FloatingBtn(
                      label: 'CATEGORÍA',
                      icon: Icons.playlist_add_rounded,
                      color: AppColors.accent,
                      onTap: () => _showCategoryDialog(context, ref),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _FloatingBtn(
                      label: 'ALIMENTO',
                      icon: Icons.add_rounded,
                      color: AppColors.primary,
                      onTap: () => _showAlimentoForm(context, ref),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _showCategoryDialog(BuildContext context, WidgetRef ref) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Nueva Categoría', style: TextStyle(fontWeight: FontWeight.w900)),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: 'Nombre',
            filled: true, fillColor: AppColors.surface2,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.isEmpty) return;
              await ref.read(adminCategoriesProvider.notifier).createCategory({'name': ctrl.text});
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Alimento a) {
     showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar Alimento', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('¿Deseas eliminar "${a.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(adminAlimentosProvider.notifier).deleteAlimento(a.id);
              if (context.mounted) Navigator.pop(context);
            }, 
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _showAlimentoForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const AlimentoFormSheet());
  }
}

class _FloatingBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _FloatingBtn({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class AlimentoFormSheet extends ConsumerStatefulWidget {
  const AlimentoFormSheet({super.key});
  @override
  ConsumerState<AlimentoFormSheet> createState() => _AlimentoFormSheetState();
}

class _AlimentoFormSheetState extends ConsumerState<AlimentoFormSheet> {
  final _nameCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _protCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  int? _selectedCatId;
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
    final cats = ref.watch(adminCategoriesProvider).value ?? [];

    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text('Nuevo Alimento Maestro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            _Input(controller: _nameCtrl, label: 'Nombre', icon: Icons.restaurant_rounded),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Input(controller: _calCtrl, label: 'Calorías', icon: Icons.local_fire_department, isNum: true)),
                const SizedBox(width: 12),
                Expanded(child: _Input(controller: _protCtrl, label: 'Proteínas', icon: Icons.fitness_center, isNum: true)),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Input(controller: _carbCtrl, label: 'Carbos', icon: Icons.eco, isNum: true)),
                const SizedBox(width: 12),
                Expanded(child: _Input(controller: _fatCtrl, label: 'Grasas', icon: Icons.opacity, isNum: true)),
              ],
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<int>(
              decoration: InputDecoration(
                labelText: 'Seleccionar Categoría',
                filled: true, fillColor: AppColors.surface2,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              items: cats.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
              onChanged: (v) => setState(() => _selectedCatId = v),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  if (_nameCtrl.text.isEmpty || _selectedCatId == null) return;
                  setState(() => _isSaving = true);
                  try {
                    await ref.read(adminAlimentosProvider.notifier).createAlimento({
                      'name': _nameCtrl.text,
                      'calories': double.tryParse(_calCtrl.text) ?? 0.0,
                      'protein': double.tryParse(_protCtrl.text) ?? 0.0,
                      'carbs': double.tryParse(_carbCtrl.text) ?? 0.0,
                      'fat': double.tryParse(_fatCtrl.text) ?? 0.0,
                      'category': _selectedCatId,
                      'meal_type': 'snack', // Valor por defecto compatible
                    });
                    // REFRESCAR DATOS
                    ref.invalidate(adminAlimentosProvider);
                    if (context.mounted) Navigator.pop(context);
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR EN CATÁLOGO', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNum;
  const _Input({required this.controller, required this.label, required this.icon, this.isNum = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true, fillColor: AppColors.surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
