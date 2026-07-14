// lib/presentation/screens/catalog/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../widgets/shared/kpi_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final aguaAsync = ref.watch(patientAguaProvider);
    final exerciseAsync = ref.watch(patientRegistrosEjercicioProvider);
    
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(patientEvaluacionesProvider(null));
          ref.invalidate(patientAguaProvider);
          ref.invalidate(patientRegistrosEjercicioProvider);
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            // 1. BIENVENIDA MEJORADA
            Row(
              children: [
                GestureDetector(
                  onTap: () => context.push('/patient/profile'),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 8, offset: const Offset(0, 4))
                      ],
                    ),
                    child: const CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person_rounded, color: AppColors.primary, size: 34),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido de vuelta,',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600
                        )
                      ),
                      Text(
                        authState.user?.username ?? 'Paciente', 
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 26,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.8
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: IconButton(
                    onPressed: () => context.push('/patient/profile'),
                    icon: const Icon(Icons.settings_rounded, color: AppColors.textSecondary, size: 22),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            const _Header(title: 'MI RESUMEN DIARIO'),
            const SizedBox(height: 16),
            
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: KpiCard(
                      title: 'Agua Hoy',
                      value: aguaAsync.maybeWhen(
                        data: (list) => '${list.fold(0.0, (sum, item) => sum + item.amountLiters).toStringAsFixed(1)}L',
                        orElse: () => '0.0L'
                      ),
                      icon: Icons.water_drop_rounded,
                      color: Colors.blue
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: KpiCard(
                      title: 'Ejercicio',
                      value: exerciseAsync.maybeWhen(
                        data: (list) => list.any((e) => e['completado'] == true) ? 'Completado' : 'Pendiente',
                        orElse: () => '0 min'
                      ),
                      icon: Icons.fitness_center_rounded,
                      color: Colors.orange
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const _Header(title: 'PROGRESO FÍSICO'),
            const SizedBox(height: 16),
            const _PhysicalProgressCard(),

            const SizedBox(height: 32),
            const _Header(title: 'SIGUIENTE COMIDA'),
            const SizedBox(height: 16),
            const _MealCard(
              meal: 'Almuerzo: Pechuga a la plancha',
              time: '13:30 PM',
              icon: Icons.restaurant_rounded,
            ),

            const SizedBox(height: 32),
            const _Header(title: 'PRÓXIMA CONSULTA'),
            const SizedBox(height: 16),
            const _AppointmentCard(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  const _Header({required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: AppColors.textFaint,
        letterSpacing: 1.2
      )
    );
  }
}

class _PhysicalProgressCard extends ConsumerWidget {
  const _PhysicalProgressCard();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evals = ref.watch(patientEvaluacionesProvider(null));

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: evals.when(
        data: (list) {
          final last = list.isNotEmpty ? list.last : _getMockEval();
          return _buildProgressContent(last);
        },
        loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
        error: (e, __) => _buildProgressContent(_getMockEval()),
      ),
    );
  }

  Widget _buildProgressContent(Map<String, dynamic> data) {
    final progress = double.tryParse(data['porcentaje_progreso']?.toString() ?? '0.0') ?? 0.65;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _Stat(label: 'Actual', value: '${data['peso'] ?? '78.5'}', unit: 'kg'),
            Container(width: 1, height: 30, color: AppColors.borderLight),
            _Stat(label: 'Meta', value: '${data['peso_meta'] ?? '72.0'}', unit: 'kg'),
            Container(width: 1, height: 30, color: AppColors.borderLight),
            _Stat(label: 'IMC', value: '${data['imc'] ?? '24.2'}', unit: ''),
          ],
        ),
        const SizedBox(height: 28),
        Stack(
          children: [
            Container(
              height: 12,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 12,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2)
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Progreso al objetivo',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary)
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(fontSize: 14, color: AppColors.primary, fontWeight: FontWeight.w900)
            ),
          ],
        ),
      ],
    );
  }

  Map<String, dynamic> _getMockEval() {
    return {
      'peso': '78.5',
      'peso_meta': '72.0',
      'imc': '24.2',
      'porcentaje_progreso': '0.65',
    };
  }
}

class _Stat extends StatelessWidget {
  final String label, value, unit;
  const _Stat({required this.label, required this.value, required this.unit});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.textPrimary, letterSpacing: -0.5)
            ),
            const SizedBox(width: 2),
            Text(unit, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  final String meal, time;
  final IconData icon;
  const _MealCard({required this.meal, required this.time, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(18)
            ),
            child: Icon(icon, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  meal,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time_filled_rounded, color: AppColors.primary, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      time,
                      style: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w800)
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.textFaint),
        ],
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withBlue(100)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10)
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.event_available_rounded, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 20),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lunes, 24 de Julio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 19,
                    letterSpacing: -0.5
                  )
                ),
                SizedBox(height: 4),
                Text(
                  '10:00 AM - Dra. Maria Cosio',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600
                  )
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
