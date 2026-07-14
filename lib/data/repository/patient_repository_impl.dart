// lib/data/repository/patient_repository_impl.dart

import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/patient_features.dart';
import '../../domain/repository/patient_repository.dart';
import '../remote/api/dio_client.dart';

class PatientRepositoryImpl implements PatientRepository {
  final Dio _dio;
  PatientRepositoryImpl(this._dio);

  static const String _localPhotosKey = 'local_progreso_photos';

  List<dynamic> _extractData(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List;
    }
    return [];
  }

  @override
  Future<List<RutinaEjercicio>> getRutinas() async {
    try {
      final res = await _dio.get('rutinas-ejercicio/');
      final list = _extractData(res.data);
      return list.map((e) => RutinaEjercicio.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<ProgresoFoto>> getProgresos() async {
    // LEER LOCALMENTE PARA PRIVACIDAD
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_localPhotosKey) ?? [];
    
    return jsonList.map((s) => ProgresoFoto.fromJson(jsonDecode(s))).toList();
  }

  @override
  Future<List<RegistroAgua>> getRegistrosAgua() async {
    try {
      final res = await _dio.get('registros-agua/');
      final list = _extractData(res.data);
      return list.map((e) => RegistroAgua.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> uploadProgresoFoto(String imagePath, String description) async {
    // GUARDAR LOCALMENTE EN VEZ DE SUBIR AL SERVIDOR (Para privacidad)
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName = 'progreso_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String localPath = '${directory.path}/$fileName';

      // Copiar archivo a almacenamiento privado de la app
      await File(imagePath).copy(localPath);

      final newPhoto = ProgresoFoto(
        id: DateTime.now().millisecondsSinceEpoch,
        date: DateTime.now().toIso8601String().split('T')[0],
        localPath: localPath,
        notes: description,
      );

      final prefs = await SharedPreferences.getInstance();
      final currentList = prefs.getStringList(_localPhotosKey) ?? [];
      currentList.add(jsonEncode(newPhoto.toJson()));
      await prefs.setStringList(_localPhotosKey, currentList);

    } catch (e) {
      throw ApiException('Error al guardar foto localmente: $e');
    }
  }

  @override
  Future<void> addRegistroAgua(double amount) async {
    try {
      // Sincronización exacta con Tabla #17
      await _dio.post('registros-agua/', data: {
        'cantidad_ml': (amount * 1000).toInt(),
        'fecha': DateTime.now().toIso8601String().split('T')[0],
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<SintomaDiario>> getSintomas() async {
    try {
      final res = await _dio.get('sintomas-diarios/');
      final list = _extractData(res.data);
      return list.map((e) => SintomaDiario.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> addSintoma(String description) async {
    final String sintomaKey;
    switch (description) {
      case 'Excelente':     sintomaKey = 'EXCELENTE'; break;
      case 'Cansado':       sintomaKey = 'CANSANCIO'; break;
      case 'Con Energía':   sintomaKey = 'BUENA_ENERGIA'; break;
      case 'Problemas Digestivos': sintomaKey = 'DIGESTION'; break;
      default: sintomaKey = 'BUENA_ENERGIA';
    }

    try {
      await _dio.post('sintomas-diarios/', data: {
        'sintoma': sintomaKey,
        'fecha': DateTime.now().toIso8601String().split('T')[0],
        'notas': 'Registrado desde la app móvil',
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getEvaluaciones({int? userId}) async {
    try {
      final params = <String, dynamic>{};
      if (userId != null) params['user_id'] = userId;
      
      final res = await _dio.get('evaluaciones-antropometricas/', queryParameters: params);
      return _extractData(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getObjetivos() async {
    try {
      final res = await _dio.get('objetivos-paciente/');
      return _extractData(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getLogros() async {
    try {
      final res = await _dio.get('logros-paciente/');
      return _extractData(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> registrarActividad(int rutinaId) async {
    try {
      await _dio.post('registros-ejercicio/', data: {
        'rutina_ejercicio': rutinaId,
        'fecha': DateTime.now().toIso8601String().split('T')[0],
        'completado': true,
        'notas': 'Completado desde la app móvil',
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getRegistrosEjercicio() async {
    try {
      final res = await _dio.get('registros-ejercicio/');
      return _extractData(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Map<String, dynamic>?> getActivePlan() async {
    try {
      // USAMOS TU TABLA #4: Consulta dietéticas para encontrar el plan
      final res = await _dio.get('consultas/', queryParameters: {'status': 'programada'});
      final list = _extractData(res.data);
      
      if (list.isEmpty) return null;
      
      final ultimaConsulta = list.first;
      return ultimaConsulta['plan_nutricional'] as Map<String, dynamic>?;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getAllPlanes() async {
    try {
      // USAMOS TU TABLA #18: Plan nutricionals
      final res = await _dio.get('planes/', queryParameters: {'is_active': true});
      return _extractData(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> adquirirPlan(int planId) async {
    try {
      // Usamos la ruta relativa exacta que el router de Django espera
      final String cleanPath = 'planes/$planId/adquirir/';
      
      print('CONEXIÓN: Enviando activación de plan a -> $cleanPath');
      await _dio.post(cleanPath);
      
    } on DioException catch (e) {
      print('ERROR SERVIDOR: ${e.response?.statusCode} - ${e.response?.data}');
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateEvaluacion(Map<String, dynamic> data) async {
    try {
      // 1. Normalizar altura (de 1.75 a 175)
      final Map<String, dynamic> payload = Map.from(data);
      if (payload['altura'] != null && payload['altura'] < 3.0) {
        payload['altura'] = (payload['altura'] * 100).toInt();
      }

      await _dio.post('evaluaciones-antropometricas/', data: payload);
      print('DEBUG: Evaluación enviada con éxito');
    } on DioException catch (e) {
      print('DEBUG ERROR: ${e.response?.statusCode} - ${e.response?.data}');
      throw ApiException.fromDioError(e);
    }
  }
}

final patientRepositoryProvider = Provider<PatientRepository>((ref) {
  return PatientRepositoryImpl(ref.watch(dioProvider));
});
