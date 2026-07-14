// lib/presentation/providers/patient_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/patient_features.dart';
import '../../data/repository/patient_repository_impl.dart';

// --- RUTINAS (Tabla 20) ---
final patientRutinasProvider = FutureProvider<List<RutinaEjercicio>>((ref) async {
  return ref.watch(patientRepositoryProvider).getRutinas();
});

// --- PROGRESO VISUAL (Tabla 19 - Metadatos + Local) ---
final patientProgresosProvider = FutureProvider<List<ProgresoFoto>>((ref) async {
  return ref.watch(patientRepositoryProvider).getProgresos();
});

// --- REGISTRO DE AGUA (Tabla 17) ---
final patientAguaProvider = FutureProvider<List<RegistroAgua>>((ref) async {
  return ref.watch(patientRepositoryProvider).getRegistrosAgua();
});

// --- SÍNTOMAS DIARIOS (Tabla 22) ---
final patientSintomasProvider = FutureProvider<List<SintomaDiario>>((ref) async {
  return ref.watch(patientRepositoryProvider).getSintomas();
});

// --- EVALUACIONES ANTROPOMÉTRICAS (Tabla 7) ---
final patientEvaluacionesProvider = FutureProvider.family<List<dynamic>, int?>((ref, userId) async {
  return ref.watch(patientRepositoryProvider).getEvaluaciones(userId: userId);
});

// --- ESTADÍSTICAS DINÁMICAS (Resumen de evaluaciones) ---
final patientStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final data = await ref.watch(patientRepositoryProvider).getEvaluaciones(userId: null);
  if (data.isEmpty) return {'peso': 0.0, 'meta': 0.0, 'imc': 0.0};
  return data.last as Map<String, dynamic>;
});

// --- OBJETIVOS Y LOGROS (Tablas 15 y 16) ---
final patientGoalsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(patientRepositoryProvider).getObjetivos();
});

final patientAchievementsProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(patientRepositoryProvider).getLogros();
});

// --- PLAN ACTIVO (Tabla 6) - Mejorado para permitir actualización manual ---
final patientActivePlanProvider = StateNotifierProvider<PatientActivePlanNotifier, AsyncValue<Map<String, dynamic>?>>((ref) {
  return PatientActivePlanNotifier(ref.watch(patientRepositoryProvider));
});

class PatientActivePlanNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final _repository;
  PatientActivePlanNotifier(this._repository) : super(const AsyncValue.loading()) {
    refreshPlan();
  }

  Future<void> refreshPlan() async {
    state = const AsyncValue.loading();
    try {
      final plan = await _repository.getActivePlan();
      state = AsyncValue.data(plan);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void clearPlan() {
    state = const AsyncValue.data(null);
  }
}

// --- CATÁLOGO DE PLANES ---
final patientAllPlanesProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(patientRepositoryProvider).getAllPlanes();
});

// --- REGISTROS DE EJERCICIO (Tabla 21) ---
final patientRegistrosEjercicioProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(patientRepositoryProvider).getRegistrosEjercicio();
});

// Para persistencia inmediata en la sesión actual
final exerciseCompletedTodayProvider = StateProvider<bool>((ref) => false);
