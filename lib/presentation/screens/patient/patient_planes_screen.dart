// lib/presentation/screens/patient/patient_planes_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/patient_provider.dart';
import '../../providers/cart_provider.dart';
import '../../../data/repository/patient_repository_impl.dart';

class PatientPlanesScreen extends ConsumerWidget {
  const PatientPlanesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final planesAsync = ref.watch(patientAllPlanesProvider);

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: const Text('Planes Disponibles', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(patientAllPlanesProvider);
          ref.invalidate(patientActivePlanProvider);
        },
        child: planesAsync.when(
          data: (planes) {
            if (planes.isEmpty) {
              return const Center(child: Text('No hay planes disponibles en este momento.'));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              itemCount: planes.length,
              itemBuilder: (context, index) {
                final plan = planes[index];
                return _PlanCard(plan: plan);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, __) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}

class _PlanCard extends ConsumerStatefulWidget {
  final Map<String, dynamic> plan;
  const _PlanCard({required this.plan});

  @override
  ConsumerState<_PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<_PlanCard> {
  bool _isAcquiring = false;

  Future<void> _acquirePlan() async {
    setState(() => _isAcquiring = true);
    try {
      await ref.read(patientRepositoryProvider).adquirirPlan(widget.plan['id']);
      ref.invalidate(patientActivePlanProvider);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('COMPLETADO'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
        
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.go('/patient/plan');
        });
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('COMPLETADO'), backgroundColor: AppColors.primary),
        );
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) context.go('/patient/plan');
        });
      }
    } finally {
      if (mounted) setState(() => _isAcquiring = false);
    }
  }

  void _showDetails() {
    final activePlanAsync = ref.watch(patientActivePlanProvider);
    final activePlanId = activePlanAsync.maybeWhen(
      data: (p) => p?['id'],
      orElse: () => null,
    );
    final bool isThisActive = activePlanId == widget.plan['id'];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(widget.plan['name'] ?? 'Detalle del Plan', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(widget.plan['goal']?.toString().toUpperCase() ?? '', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(height: 48),
            const Text('¿QUÉ OFRECE ESTE PLAN?', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.textFaint, letterSpacing: 1.2)),
            const SizedBox(height: 16),
            Text(widget.plan['description'] ?? 'Sin descripción.', style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.textPrimary)),
            const SizedBox(height: 24),
            _OfferItem(icon: Icons.check_circle_outline, text: 'Seguimiento calórico diario'),
            _OfferItem(icon: Icons.check_circle_outline, text: 'Guía de comidas detallada'),
            _OfferItem(icon: Icons.check_circle_outline, text: 'Rutinas de ejercicio adaptadas'),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (isThisActive || _isAcquiring) ? null : () async {
                  Navigator.pop(context);
                  await _acquirePlan();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isAcquiring 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(isThisActive ? 'YA ACTIVADO' : 'ACTIVAR PLAN', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePlanAsync = ref.watch(patientActivePlanProvider);
    final activePlanId = activePlanAsync.maybeWhen(
      data: (p) => p?['id'],
      orElse: () => null,
    );

    final bool isThisActive = activePlanId == widget.plan['id'];
    final bool hasAnotherPlan = activePlanId != null && !isThisActive;

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: isThisActive ? AppColors.primary : AppColors.borderLight,
          width: isThisActive ? 2 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: isThisActive ? AppColors.primary.withOpacity(0.05) : Colors.black.withOpacity(0.02),
            blurRadius: 15,
            offset: const Offset(0, 8)
          )
        ],
      ),
      child: InkWell(
        onTap: _showDetails,
        borderRadius: BorderRadius.circular(32),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12)
                      ),
                      child: Text(
                        widget.plan['goal']?.toString().toUpperCase() ?? 'NUTRICIÓN',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5
                        )
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (isThisActive)
                    const Text('ACTIVO',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primary))
                  else
                    const Text('GRATIS',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.success)),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                widget.plan['name'] ?? 'Plan Nutricional',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: -0.5)
              ),
              const SizedBox(height: 8),
              Text(
                widget.plan['description'] ?? 'Guía alimenticia personalizada diseñada para tus objetivos de salud.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.4)
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _FeatureIcon(icon: Icons.timer_outlined, label: '${widget.plan['duration_weeks'] ?? 4} Semanas'),
                  const SizedBox(width: 24),
                  _FeatureIcon(icon: Icons.local_fire_department_outlined, label: '${widget.plan['target_calories'] ?? 2000} kcal'),
                ],
              ),
              const Divider(height: 48),
              if (isThisActive)
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _isAcquiring ? null : () {
                      // Cancelación manual permitida por StateNotifier
                      setState(() => _isAcquiring = true);
                      Future.delayed(const Duration(seconds: 1), () {
                        ref.read(patientActivePlanProvider.notifier).clearPlan();
                        if (mounted) {
                          setState(() => _isAcquiring = false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Plan cancelado correctamente'), backgroundColor: AppColors.error)
                          );
                        }
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.error, width: 1.5),
                      foregroundColor: AppColors.error,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isAcquiring
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                      : const Text('CANCELAR PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14)),
                  ),
                )
              else
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isAcquiring ? null : _acquirePlan,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isAcquiring
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('ACTIVAR PLAN', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OfferItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _OfferItem({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textFaint),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
      ],
    );
  }
}
