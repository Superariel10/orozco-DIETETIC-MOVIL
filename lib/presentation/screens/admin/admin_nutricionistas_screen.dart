// lib/presentation/screens/admin/admin_nutricionistas_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/model/nutricionista.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/empty_state.dart';

class AdminNutricionistasScreen extends ConsumerWidget {
  const AdminNutricionistasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nutriAsync = ref.watch(adminNutricionistasProvider);

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(adminNutricionistasProvider);
        },
        child: nutriAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildBody(_getMockNutris(), context, ref),
          data: (nutris) {
            final displayList = nutris.isEmpty ? _getMockNutris() : nutris;
            return _buildBody(displayList, context, ref);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddNutriDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(List<Nutricionista> displayList, BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: SearchFilterBar(
            hintText: 'Buscar nutricionista...',
            onSearch: (v) {},
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: displayList.length,
            separatorBuilder: (_, __) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final nutri = displayList[index];
              return _NutriCard(
                nutri: nutri,
                onEdit: () => _showEditNutriDialog(context, ref, nutri),
                onDelete: () => _showDeleteConfirm(context, ref, nutri),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showDeleteConfirm(BuildContext context, WidgetRef ref, Nutricionista nutri) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Nutricionista'),
        content: Text('¿Deseas eliminar a ${nutri.fullName}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await ref.read(adminNutricionistasProvider.notifier).deleteNutricionista(nutri.id);
              if (context.mounted) Navigator.pop(context);
            }, 
            child: const Text('Eliminar', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _showEditNutriDialog(BuildContext context, WidgetRef ref, Nutricionista nutri) {
    final nameCtrl = TextEditingController(text: nutri.firstName);
    final lastCtrl = TextEditingController(text: nutri.lastName);
    final specCtrl = TextEditingController(text: nutri.specialty);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Nutricionista'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nombre')),
            const SizedBox(height: 12),
            TextField(controller: lastCtrl, decoration: const InputDecoration(labelText: 'Apellido')),
            const SizedBox(height: 12),
            TextField(controller: specCtrl, decoration: const InputDecoration(labelText: 'Especialidad')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          TextButton(
            onPressed: () async {
              await ref.read(adminNutricionistasProvider.notifier).updateNutricionista(nutri.id, {
                'first_name': nameCtrl.text,
                'last_name': lastCtrl.text,
                'specialty': specCtrl.text,
              });
              if (context.mounted) Navigator.pop(context);
            }, 
            child: const Text('Guardar', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold))
          ),
        ],
      ),
    );
  }

  void _showAddNutriDialog(BuildContext context, WidgetRef ref) {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController(); // Nuevo controlador para contraseña
    final nameCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final specCtrl = TextEditingController();
    final idCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        bool obscurePassword = true;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nuevo Nutricionista',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 24),
                    _buildDialogField(userCtrl, 'Usuario (Login)'),
                    const SizedBox(height: 12),
                    // Campo de Contraseña
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface2.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TextField(
                        controller: passCtrl,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          labelStyle: const TextStyle(color: AppColors.textFaint),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppColors.textFaint,
                            ),
                            onPressed: () => setState(() => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDialogField(nameCtrl, 'Nombre'),
                    const SizedBox(height: 12),
                    _buildDialogField(lastCtrl, 'Apellido'),
                    const SizedBox(height: 12),
                    _buildDialogField(specCtrl, 'Especialidad'),
                    const SizedBox(height: 12),
                    _buildDialogField(idCtrl, 'ID Profesional'),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar', style: TextStyle(color: Colors.green)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () async {
                            if (nameCtrl.text.isEmpty || idCtrl.text.isEmpty || passCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Por favor completa los campos obligatorios y la contraseña')),
                              );
                              return;
                            }
                            
                            await ref.read(adminNutricionistasProvider.notifier).createNutricionista({
                              'username': userCtrl.text,
                              'password': passCtrl.text, // Enviamos la contraseña al backend
                              'first_name': nameCtrl.text,
                              'last_name': lastCtrl.text,
                              'specialty': specCtrl.text,
                              'professional_id': idCtrl.text,
                              'consultation_fee': '50.00',
                            });
                            if (context.mounted) Navigator.pop(context);
                          },
                          child: const Text('Registrar', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }
        );
      },
    );
  }

  Widget _buildDialogField(TextEditingController ctrl, String label) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface2.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.textFaint),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  List<Nutricionista> _getMockNutris() {
    return [
      const Nutricionista(
        id: 1, userId: 2, firstName: 'Maria', lastName: 'Cosio', 
        professionalId: 'PROF-123', specialty: 'Nutrición Adecuada', 
        consultationFee: 45.0, consultationsCompleted: 150, isActive: true
      ),
      const Nutricionista(
        id: 2, userId: 4, firstName: 'Sofia Elena', lastName: 'Mendoza', 
        professionalId: 'PROF-456', specialty: 'Nutrición Clínica', 
        consultationFee: 55.0, consultationsCompleted: 210, isActive: true
      ),
    ];
  }
}

class _NutriCard extends StatelessWidget {
  final Nutricionista nutri;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _NutriCard({required this.nutri, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.primary.withOpacity(0.1),
            child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nutri.fullName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary)),
                const SizedBox(height: 4),
                Text(nutri.specialty, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.surface2, borderRadius: BorderRadius.circular(6)),
                  child: Text('ID: ${nutri.professionalId}', style: const TextStyle(fontSize: 10, color: AppColors.textFaint, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(icon: const Icon(Icons.edit_rounded, color: AppColors.primary, size: 20), onPressed: onEdit),
              IconButton(icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20), onPressed: onDelete),
            ],
          ),
        ],
      ),
    );
  }
}
