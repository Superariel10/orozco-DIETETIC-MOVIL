// lib/presentation/screens/admin/admin_planes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../data/repository/admin_repository_impl.dart';
import '../../../domain/model/plan_nutricional.dart';
import '../../../theme/app_colors.dart';

class AdminPlanesScreen extends ConsumerWidget {
  const AdminPlanesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planesAsync = ref.watch(adminPlanesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planes Nutricionales'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
            onPressed: () => _showPlanForm(context, ref),
          ),
        ],
      ),
      body: planesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('Error: $error', textAlign: TextAlign.center),
        )),
        data: (planes) {
          if (planes.isEmpty) return const Center(child: Text('No hay planes registrados.'));
          
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: planes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final plan = planes[index];
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF3E0),
                    child: Icon(Icons.restaurant_menu, color: Colors.orange),
                  ),
                  title: Text(plan.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${plan.goal} • ${plan.targetCalories} kcal\n${plan.durationWeeks} semanas'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: AppColors.info),
                        onPressed: () => _showPlanForm(context, ref, plan),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.error),
                        onPressed: () => _confirmDelete(context, ref, plan),
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

  void _showPlanForm(BuildContext context, WidgetRef ref, [PlanNutricional? plan]) {
    showDialog(
      context: context,
      builder: (context) => PlanFormDialog(plan: plan),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PlanNutricional plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Plan'),
        content: Text('¿Deseas eliminar el plan "${plan.name}"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await ref.read(adminPlanesProvider.notifier).deletePlan(plan.id);
              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class PlanFormDialog extends ConsumerStatefulWidget {
  final PlanNutricional? plan;
  const PlanFormDialog({super.key, this.plan});

  @override
  ConsumerState<PlanFormDialog> createState() => _PlanFormDialogState();
}

class _PlanFormDialogState extends ConsumerState<PlanFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _goalCtrl;
  late TextEditingController _calCtrl;
  late TextEditingController _durCtrl;
  late TextEditingController _costCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.plan?.name ?? '');
    _descCtrl = TextEditingController(text: widget.plan?.description ?? '');
    _goalCtrl = TextEditingController(text: widget.plan?.goal ?? '');
    _calCtrl = TextEditingController(text: widget.plan?.targetCalories.toString() ?? '');
    _durCtrl = TextEditingController(text: widget.plan?.durationWeeks.toString() ?? '');
    _costCtrl = TextEditingController(text: widget.plan?.estimatedCost.toString() ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.plan == null ? 'Nuevo Plan' : 'Editar Plan'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Nombre'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _goalCtrl, decoration: const InputDecoration(labelText: 'Meta'), validator: (v) => v!.isEmpty ? 'Requerido' : null),
              TextFormField(controller: _calCtrl, decoration: const InputDecoration(labelText: 'Calorías Obj.'), keyboardType: TextInputType.number),
              TextFormField(controller: _durCtrl, decoration: const InputDecoration(labelText: 'Semanas'), keyboardType: TextInputType.number),
              TextFormField(controller: _costCtrl, decoration: const InputDecoration(labelText: 'Costo Est.'), keyboardType: TextInputType.number),
              TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Descripción'), maxLines: 2),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              final data = {
                'name': _nameCtrl.text,
                'goal': _goalCtrl.text,
                'target_calories': int.tryParse(_calCtrl.text) ?? 0,
                'duration_weeks': int.tryParse(_durCtrl.text) ?? 0,
                'estimated_cost': double.tryParse(_costCtrl.text) ?? 0.0,
                'description': _descCtrl.text,
                'is_active': true,
              };
              if (widget.plan == null) {
                await ref.read(adminPlanesProvider.notifier).createPlan(data);
              } else {
                await ref.read(adminPlanesProvider.notifier).updatePlan(widget.plan!.id, data);
              }
              if (context.mounted) Navigator.pop(context);
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
