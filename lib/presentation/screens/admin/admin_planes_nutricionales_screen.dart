// lib/presentation/screens/admin/admin_planes_nutricionales_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/model/plan_nutricional.dart';
import '../../../theme/app_colors.dart';

class AdminPlanesNutricionalesScreen extends ConsumerWidget {
  const AdminPlanesNutricionalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planesAsync = ref.watch(adminPlanesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('GESTIÓN DE PLANES', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(adminPlanesProvider),
        color: AppColors.primary,
        child: planesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
          data: (planes) {
            if (planes.isEmpty) {
              return const Center(child: Text('No hay planes registrados.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(24),
              itemCount: planes.length,
              itemBuilder: (context, index) {
                final plan = planes[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                            child: const Icon(Icons.assignment_rounded, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(plan.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.textPrimary)),
                                Text(plan.goal.toUpperCase(), style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 10)),
                              ],
                            ),
                          ),
                          _SmallActionBtn(icon: Icons.edit_rounded, color: AppColors.primary, onTap: () => _showPlanForm(context, ref, plan)),
                          const SizedBox(width: 8),
                          _SmallActionBtn(icon: Icons.delete_rounded, color: AppColors.error, onTap: () => _confirmDelete(context, ref, plan)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Badge(icon: Icons.timer_outlined, label: '${plan.durationWeeks} Sem'),
                          const SizedBox(width: 8),
                          _Badge(icon: Icons.local_fire_department_rounded, label: '${plan.targetCalories} kcal'),
                          const Spacer(),
                          const Text('GRATIS', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.success, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlanForm(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  void _showPlanForm(BuildContext context, WidgetRef ref, [PlanNutricional? plan]) {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => PlanNutricionalFormSheet(plan: plan));
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PlanNutricional plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar Plan', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('¿Deseas eliminar "${plan.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              await ref.read(adminPlanesProvider.notifier).deletePlan(plan.id);
              if (context.mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _SmallActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _SmallActionBtn({required this.icon, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
        child: Icon(icon, color: color, size: 16),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  const _Badge({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class PlanNutricionalFormSheet extends ConsumerStatefulWidget {
  final PlanNutricional? plan;
  const PlanNutricionalFormSheet({super.key, this.plan});
  @override
  ConsumerState<PlanNutricionalFormSheet> createState() => _PlanNutricionalFormSheetState();
}

class _PlanNutricionalFormSheetState extends ConsumerState<PlanNutricionalFormSheet> {
  final _nameCtrl = TextEditingController();
  final _goalCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _weeksCtrl = TextEditingController(text: '4');
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.plan != null) {
      _nameCtrl.text = widget.plan!.name;
      _goalCtrl.text = widget.plan!.goal;
      _calCtrl.text = widget.plan!.targetCalories.toString();
      _weeksCtrl.text = widget.plan!.durationWeeks.toString();
    }
  }

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
            Text(widget.plan == null ? 'Nuevo Plan' : 'Editar Plan', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 24),
            _Field(controller: _nameCtrl, label: 'Nombre', icon: Icons.title),
            const SizedBox(height: 16),
            _Field(controller: _goalCtrl, label: 'Objetivo', icon: Icons.track_changes),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _Field(controller: _calCtrl, label: 'Kcal', icon: Icons.local_fire_department, isNum: true)),
                const SizedBox(width: 12),
                Expanded(child: _Field(controller: _weeksCtrl, label: 'Semanas', icon: Icons.timer, isNum: true)),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isSaving ? null : () async {
                  if (_nameCtrl.text.isEmpty) return;
                  setState(() => _isSaving = true);
                  final data = {
                    'name': _nameCtrl.text,
                    'goal': _goalCtrl.text,
                    'target_calories': int.tryParse(_calCtrl.text) ?? 2000,
                    'duration_weeks': int.tryParse(_weeksCtrl.text) ?? 4,
                    'estimated_cost': 0.0,
                  };
                  try {
                    if (widget.plan == null) {
                      await ref.read(adminPlanesProvider.notifier).createPlan(data);
                    } else {
                      await ref.read(adminPlanesProvider.notifier).updatePlan(widget.plan!.id, data);
                    }
                    if (context.mounted) Navigator.pop(context);
                  } finally {
                    if (mounted) setState(() => _isSaving = false);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : const Text('GUARDAR PLAN', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool isNum;
  const _Field({required this.controller, required this.label, required this.icon, this.isNum = false});
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true, fillColor: AppColors.surface2,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}
