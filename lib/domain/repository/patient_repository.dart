// lib/domain/repository/patient_repository.dart

import '../model/patient_features.dart';

abstract class PatientRepository {
  Future<List<RutinaEjercicio>> getRutinas();
  Future<List<ProgresoFoto>> getProgresos();
  Future<List<RegistroAgua>> getRegistrosAgua();
  Future<void> addRegistroAgua(double amount);
  Future<List<SintomaDiario>> getSintomas();
  Future<void> addSintoma(String description);
  Future<List<dynamic>> getEvaluaciones({int? userId});
  Future<List<dynamic>> getObjetivos();
  Future<List<dynamic>> getLogros();
  Future<void> registrarActividad(int rutinaId);
  Future<List<dynamic>> getRegistrosEjercicio();
  Future<Map<String, dynamic>?> getActivePlan();
  Future<List<dynamic>> getAllPlanes(); // Nuevo
  Future<void> adquirirPlan(int planId);
  Future<void> uploadProgresoFoto(String imagePath, String description);
  Future<void> updateEvaluacion(Map<String, dynamic> data);
}
