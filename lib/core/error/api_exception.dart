// lib/core/error/api_exception.dart

import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int?   statusCode;
  final Map<String, dynamic>? fieldErrors;

  const ApiException(this.message, {this.statusCode, this.fieldErrors});

  factory ApiException.fromDioError(DioException error) {
    final response = error.response;
    final code     = response?.statusCode;

    if (code == 502) {
      return ApiException('Error 502: El servidor de aplicaciones no responde (Bad Gateway). Por favor, intenta más tarde.', statusCode: code);
    }
    if (code == 500) {
      return ApiException('Error 500: Error interno en el servidor.', statusCode: code);
    }
    if (code == 504) {
      return ApiException('Error 504: Tiempo de espera agotado (Gateway Timeout).', statusCode: code);
    }

    if (response?.data == null || response?.data is String) {
      final String rawData = response?.data?.toString() ?? '';
      String errorMsg = 'Error del servidor (Código: $code)';
      
      // Si el código es 400 y recibimos HTML, es probable que la ruta sea incorrecta 
      // o el servidor esté rechazando la petición antes de llegar a la API.
      if (code == 400) {
        if (rawData.contains('DisallowedHost')) {
          errorMsg = 'Error de Seguridad (Django): El dominio "paz-dietetica.uaeftt-ute.site" no está autorizado en ALLOWED_HOSTS del servidor.';
        } else if (rawData.contains('<html>')) {
          errorMsg = 'Error del servidor: Petición incorrecta o error de configuración.';
        } else if (rawData.isNotEmpty) {
          errorMsg = 'Error 400: $rawData';
        }
      }

      return ApiException(
        code != null ? errorMsg : (error.message ?? 'Error de conexión'),
        statusCode: code,
      );
    }

    final data = response!.data;

    // --- Traductor de mensajes comunes del Backend ---
    String translate(String raw) {
      final msg = raw.toLowerCase();
      if (msg.contains('already registered') || msg.contains('already exists')) {
        if (msg.contains('email')) return 'Este correo electrónico ya está registrado.';
        if (msg.contains('user')) return 'Este nombre de usuario ya está en uso.';
        return 'El registro ya existe.';
      }
      if (msg.contains('required')) return 'Este campo es obligatorio.';
      if (msg.contains('invalid') && msg.contains('password')) return 'Usuario o contraseña incorrectos.';
      if (msg.contains('valid email')) return 'Ingresa un correo electrónico válido.';
      if (msg.contains('not match')) return 'Las contraseñas no coinciden.';
      if (msg.contains('too short')) return 'La contraseña es demasiado corta.';
      if (msg.contains('no active account') || msg.contains('cuenta activa')) return 'La combinación de credenciales no es válida o la cuenta no está activa.';

      return raw; // Si no hay traducción, devolver original
    }

    // Mapa de errores de campo Django
    if (data is Map<String, dynamic>) {
      if (data.containsKey('detail')) {
        return ApiException(translate(data['detail'].toString()), statusCode: code);
      }
      if (data.containsKey('error')) {
        return ApiException(translate(data['error'].toString()), statusCode: code);
      }
      if (data.containsKey('non_field_errors')) {
        final errors = data['non_field_errors'];
        final msg    = errors is List ? errors.first.toString() : errors.toString();
        return ApiException(translate(msg), statusCode: code);
      }
      // Errores por campo
      final fieldErrors = <String, dynamic>{};
      String? firstMessage;
      data.forEach((key, value) {
        final msg = value is List ? value.first.toString() : value.toString();
        final translatedMsg = translate(msg);
        fieldErrors[key] = translatedMsg;
        firstMessage ??= translatedMsg; // Ya no incluimos la clave para que sea más limpio
      });
      return ApiException(
        firstMessage ?? 'Error de validación',
        statusCode:  code,
        fieldErrors: fieldErrors,
      );
    }

    return ApiException('Error inesperado en el servidor.', statusCode: code);
  }

  String? fieldError(String field) => fieldErrors?[field]?.toString();

  @override
  String toString() => message;
}
