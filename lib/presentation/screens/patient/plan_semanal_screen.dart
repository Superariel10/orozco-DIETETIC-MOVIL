// lib/presentation/screens/patient/plan_semanal_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/patient_provider.dart';
import '../../../data/repository/patient_repository_impl.dart';

class PlanSemananalScreen extends ConsumerWidget {
  const PlanSemananalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        appBar: AppBar(
          title: const Text('Mi Plan Nutricional', style: TextStyle(fontWeight: FontWeight.w900)),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0.5,
          actions: [
            IconButton(
              icon: const Icon(Icons.list_alt_rounded, color: AppColors.primary),
              tooltip: 'Ver todos los planes',
              onPressed: () => context.push('/patient/planes'),
            ),
            const SizedBox(width: 8),
          ],
          bottom: const TabBar(
            isScrollable: true,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 4,
            tabs: [
              Tab(text: 'DIETA', icon: Icon(Icons.restaurant_rounded, size: 20)),
              Tab(text: 'RUTINA', icon: Icon(Icons.fitness_center_rounded, size: 20)),
              Tab(text: 'LOGROS', icon: Icon(Icons.emoji_events_rounded, size: 20)),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _AlimentacionTab(),
            _EjercicioTab(),
            _LogrosTab(),
          ],
        ),
      ),
    );
  }
}

class _AlimentacionTab extends ConsumerWidget {
  const _AlimentacionTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planAsync = ref.watch(patientActivePlanProvider);

    return planAsync.when(
      data: (plan) {
        if (plan == null) return _NoPlanState();

        return ListView(
          padding: const EdgeInsets.all(24),
          children: const [
            Text('TU DIETA PARA HOY',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textFaint, letterSpacing: 1.2)),
            const SizedBox(height: 20),
            _MealCard(
              title: 'Desayuno Saludable',
              time: '08:00 AM', 
              items: ['2 Huevos cocidos', '1 Tajada de pan integral', 'Café sin azúcar'],
              icon: Icons.breakfast_dining,
              imageUrl: 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=400&auto=format&fit=crop',
              prot: '18g', carb: '25g', fat: '10g',
            ),
            _MealCard(
              title: 'Almuerzo Proteico',
              time: '01:30 PM', 
              items: ['Pechuga a la plancha (150g)', 'Ensalada fresca', '1/2 taza de Arroz'],
              icon: Icons.lunch_dining,
              imageUrl: 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?q=80&w=400&auto=format&fit=crop',
              prot: '35g', carb: '40g', fat: '12g',
            ),
            _MealCard(
              title: 'Cena Ligera',
              time: '08:00 PM', 
              items: ['Filete de pescado', 'Verduras al vapor'],
              icon: Icons.dinner_dining,
              imageUrl: 'https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?q=80&w=400&auto=format&fit=crop',
              prot: '28g', carb: '10g', fat: '8g',
            ),
            const SizedBox(height: 40),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error: $e')),
    );
  }
}

class _MealCard extends StatelessWidget {
  final String title, time, prot, carb, fat, imageUrl;
  final List<String> items;
  final IconData icon;

  const _MealCard({
    required this.title,
    required this.time,
    required this.items,
    required this.icon,
    required this.imageUrl,
    required this.prot,
    required this.carb,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 15, offset: const Offset(0, 8))],
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Column(
        children: [
          // Imagen de comida con Badge de tiempo
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
                child: Image.network(imageUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 12, right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(20)),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled_rounded, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(time, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary)),
                const SizedBox(height: 12),
                ...items.map((i) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(i, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w500)),
                  ]),
                )),
                const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider(height: 1, color: AppColors.borderLight)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NutriMiniBadge(label: 'PROT', value: prot, color: Colors.blue),
                    _NutriMiniBadge(label: 'CARB', value: carb, color: Colors.green),
                    _NutriMiniBadge(label: 'GRASA', value: fat, color: Colors.orange),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NutriMiniBadge extends StatelessWidget {
  final String label, value;
  final Color color;
  const _NutriMiniBadge({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(10)),
      child: Column(
        children: [
          Text(label, style: TextStyle(color: color, fontSize: 8, fontWeight: FontWeight.w900)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

class _NoPlanState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: AppColors.borderLight, width: 1.5),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.info_outline_rounded, size: 48, color: AppColors.primary),
              ),
              const SizedBox(height: 24),
              const Text('CONFIGURACIÓN PENDIENTE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.5)),
              const SizedBox(height: 12),
              const Text('Activa tu Plan', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 16),
              const Text(
                'Para ver tu dieta personalizada, rutinas y logros, primero debes elegir un plan en la sección de planes.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.5, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/patient/planes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('IR A PLANES', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogrosTab extends ConsumerWidget {
  const _LogrosTab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logrosAsync = ref.watch(patientAchievementsProvider);
    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(patientAchievementsProvider),
      child: logrosAsync.when(
        data: (logros) {
          if (logros.isEmpty) return ListView(children: const [SizedBox(height: 100), Center(child: Text('Aún no tienes logros registrados.'))]);
          return ListView.builder(
            padding: const EdgeInsets.all(24),
            itemCount: logros.length,
            itemBuilder: (context, index) {
              final logro = logros[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.borderLight)),
                child: Row(children: [
                  Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.1), shape: BoxShape.circle), child: const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 32)),
                  const SizedBox(width: 20),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(logro['nombre'] ?? 'Logro', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), Text(logro['descripcion'] ?? '¡Bien hecho!', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))])),
                ]),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Padding(padding: const EdgeInsets.all(20), child: Text('Error: $e'))),
      ),
    );
  }
}

class _EjercicioTab extends ConsumerStatefulWidget {
  const _EjercicioTab();
  @override
  ConsumerState<_EjercicioTab> createState() => _EjercicioTabState();
}

class _EjercicioTabState extends ConsumerState<_EjercicioTab> with AutomaticKeepAliveClientMixin {
  bool _isSaving = false;
  @override
  bool get wantKeepAlive => true;

  Future<void> _registerActivity(int routineId) async {
    final isCompleted = ref.read(exerciseCompletedTodayProvider);
    if (isCompleted) return;
    setState(() => _isSaving = true);
    try {
      await ref.read(patientRepositoryProvider).registrarActividad(routineId);
      ref.read(exerciseCompletedTodayProvider.notifier).state = true;
      ref.invalidate(patientAchievementsProvider);
      if (mounted) _showAchievementDialog();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showAchievementDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 80),
            const SizedBox(height: 16),
            const Text('¡LOGRO DESBLOQUEADO!', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
            const SizedBox(height: 8),
            const Text('Guerrero Constante', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Has completado tu rutina del día. ¡Sigue así!', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('¡GENIAL!'))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isCompleted = ref.watch(exerciseCompletedTodayProvider);
    final rutinasAsync = ref.watch(patientRutinasProvider);
    return rutinasAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, __) => Center(child: Text('Error al cargar rutinas: $e')),
      data: (rutinas) {
        if (rutinas.isEmpty) return const Center(child: Text('No tienes rutinas asignadas.'));
        final r = rutinas.first;
        return ListView(padding: const EdgeInsets.all(24), children: [
          const Text('TU RUTINA DE HOY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textFaint, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppColors.primaryDark, borderRadius: BorderRadius.circular(32)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.bolt, color: Colors.amber)),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(r.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)), Text('${r.durationMinutes} min • ${r.difficulty}', style: const TextStyle(color: Colors.white70, fontSize: 12))])),
              ]),
              const Divider(color: Colors.white10, height: 48),
              Text(r.description, style: const TextStyle(color: Colors.white, fontSize: 14)),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, height: 56, child: ElevatedButton(
                onPressed: (isCompleted || _isSaving) ? null : () => _registerActivity(r.id),
                style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.white24 : AppColors.accent, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: _isSaving ? const CircularProgressIndicator(color: Colors.white) : Text(isCompleted ? 'COMPLETADO ✓' : 'REGISTRAR ACTIVIDAD', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            ]),
          ),
        ]);
      },
    );
  }
}
