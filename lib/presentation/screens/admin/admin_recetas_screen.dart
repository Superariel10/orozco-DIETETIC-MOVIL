// lib/presentation/screens/admin/admin_recetas_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../../domain/model/alimento.dart';

class AdminRecetasScreen extends ConsumerWidget {
  const AdminRecetasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final canEdit = authState.user?.isAdmin == true || authState.user?.isNutricionista == true;
    final alimentosAsync = ref.watch(adminAlimentosProvider);

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('RECETAS Y ALIMENTOS', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: SearchFilterBar(hintText: 'Buscar recetas...', onSearch: (v) {}),
          ),
          Expanded(
            child: alimentosAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => _buildDemoList(context, ref, canEdit),
              data: (alimentos) {
                if (alimentos.isEmpty) return _buildDemoList(context, ref, canEdit);
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
                  itemCount: alimentos.length,
                  itemBuilder: (context, index) {
                    final a = alimentos[index];
                    return _RecetaTile(
                      alimento: a,
                      canDelete: canEdit,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: canEdit ? FloatingActionButton.extended(
        onPressed: () => _showRecipeForm(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_task_rounded, color: Colors.white),
        label: const Text('NUEVA RECETA', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ) : null,
    );
  }

  Widget _buildDemoList(BuildContext context, WidgetRef ref, bool canDelete) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      children: [
        _RecetaTile(
          demoData: {
            'name': 'Huevos Revueltos con Aguacate',
            'calories': '320 kcal',
            'category': 'Desayuno',
            'description': 'Huevos revueltos esponjosos acompañados de láminas de aguacate fresco y una tostada integral.',
            'ingredients': ['2 Huevos', '1/2 Aguacate', '1 Tostada Integral']
          },
          canDelete: false,
        ),
        _RecetaTile(
          demoData: {
            'name': 'Pechuga de Pollo con Verduras',
            'calories': '450 kcal',
            'category': 'Proteínas',
            'description': 'Pechuga a la plancha con brócoli, zanahoria y arroz integral.',
            'ingredients': ['150g Pollo', 'Verduras al vapor', '50g Arroz integral']
          },
          canDelete: false,
        ),
        _RecetaTile(
          demoData: {
            'name': 'Pescado con Ensalada César',
            'calories': '380 kcal',
            'category': 'Cena',
            'description': 'Filete de pescado blanco a la plancha con ensalada césar fit.',
            'ingredients': ['Filete Pescado', 'Lechuga', 'Aderezo Light']
          },
          canDelete: false,
        ),
      ],
    );
  }

  void _showRecipeForm(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const RecipeFormSheet(),
    );
  }
}

class RecipeFormSheet extends ConsumerStatefulWidget {
  const RecipeFormSheet({super.key});
  @override
  ConsumerState<RecipeFormSheet> createState() => _RecipeFormSheetState();
}

class _RecipeFormSheetState extends ConsumerState<RecipeFormSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) {
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
            const Text('Crear Nueva Receta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            _Input(controller: _nameCtrl, label: 'Nombre', icon: Icons.restaurant_rounded),
            const SizedBox(height: 16),
            _Input(controller: _descCtrl, label: 'Instrucciones / Descripción', icon: Icons.description_rounded, maxLines: 3),
            const SizedBox(height: 16),
            _Input(controller: _calCtrl, label: 'Calorías aproximadas', icon: Icons.local_fire_department, isNumber: true),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  if (_nameCtrl.text.isEmpty) return;
                  setState(() => _isSaving = true);
                  try {
                    await ref.read(adminAlimentosProvider.notifier).createAlimento({
                      'name': _nameCtrl.text,
                      'calories': double.tryParse(_calCtrl.text) ?? 0.0,
                      'portion_grams': 100,
                      'protein': 0.0, 'carbs': 0.0, 'fat': 0.0,
                      'category': 1,
                      'meal_type': 'snack',
                    });
                    ref.invalidate(adminAlimentosProvider);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Receta guardada exitosamente'), backgroundColor: AppColors.primary));
                    }
                  } catch (e) {
                    if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR RECETA', style: TextStyle(fontWeight: FontWeight.bold)),
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
  final bool isNumber;
  final int maxLines;
  const _Input({required this.controller, required this.label, required this.icon, this.isNumber = false, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: AppColors.primary),
        filled: true, fillColor: AppColors.surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

class _RecetaTile extends ConsumerWidget {
  final Alimento? alimento;
  final Map<String, dynamic>? demoData;
  final bool canDelete;

  const _RecetaTile({this.alimento, this.demoData, required this.canDelete});

  String _getImageUrl(String name) {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('huevo')) return 'https://storage.googleapis.com/static-assets-0/ai-context/86277085-f016-41e9-91ca-7117e3be969c/input_file_0.png';
    if (lowerName.contains('pollo')) return 'https://storage.googleapis.com/static-assets-0/ai-context/86277085-f016-41e9-91ca-7117e3be969c/input_file_1.png';
    if (lowerName.contains('batido') || lowerName.contains('granola') || lowerName.contains('yogur')) return 'https://storage.googleapis.com/static-assets-0/ai-context/86277085-f016-41e9-91ca-7117e3be969c/input_file_2.png';
    if (lowerName.contains('pescado')) return 'https://storage.googleapis.com/static-assets-0/ai-context/86277085-f016-41e9-91ca-7117e3be969c/input_file_3.png';

    // Imagen por defecto si no coincide
    return 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=300&auto=format&fit=crop';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = alimento?.name ?? demoData?['name'] ?? 'Sin nombre';
    final cal = alimento != null ? '${alimento!.calories.toInt()} kcal' : (demoData?['calories'] ?? '0 kcal');
    final cat = alimento != null ? 'Catálogo' : (demoData?['category'] ?? 'Receta');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppColors.borderLight),
      ),
      child: InkWell(
        onTap: () => _showDetails(context),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  _getImageUrl(name),
                  width: 70, height: 70, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 70, height: 70, color: AppColors.primary.withOpacity(0.05),
                    child: const Icon(Icons.restaurant_menu_rounded, color: AppColors.primary, size: 30),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                    const SizedBox(height: 4),
                    Text('$cat • $cal', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 22),
                  onPressed: () => _confirmDelete(context, ref),
                )
              else
                const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar Registro', style: TextStyle(fontWeight: FontWeight.w900)),
        content: const Text('¿Deseas eliminar este registro permanentemente?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              try {
                if (alimento != null) {
                  await ref.read(adminAlimentosProvider.notifier).deleteAlimento(alimento!.id);
                  ref.invalidate(adminAlimentosProvider);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado correctamente'), backgroundColor: AppColors.error));
                  }
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final name = alimento?.name ?? demoData?['name'] ?? 'Receta';
    final cal = alimento != null ? '${alimento!.calories.toInt()} kcal' : (demoData?['calories'] ?? '0 kcal');
    final desc = alimento != null ? 'Alimento registrado en el catálogo maestro.' : (demoData?['description'] ?? 'Sin descripción.');
    final ingredients = alimento != null
        ? ['Proteína: ${alimento!.protein}g', 'Carbos: ${alimento!.carbs}g', 'Grasas: ${alimento!.fat}g']
        : List<String>.from(demoData?['ingredients'] ?? []);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        child: Column(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  child: Image.network(_getImageUrl(name), width: double.infinity, height: 220, fit: BoxFit.cover),
                ),
                Positioned(top: 20, right: 20, child: CircleAvatar(backgroundColor: Colors.white, child: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)))),
              ],
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5))),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                        child: Text(cal, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.w900, fontSize: 13)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text('DESCRIPCIÓN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5)),
                  const SizedBox(height: 8),
                  Text(desc, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5)),
                  const SizedBox(height: 32),
                  const Text('INFORMACIÓN NUTRICIONAL', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  ...ingredients.map((ing) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(ing, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      ],
                    ),
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
