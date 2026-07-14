// lib/data/remote/interceptor/auth_interceptor.dart

import 'package:dio/dio.dart';
import '../../local/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;

  AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // REGLA DE ORO DIO: Si el path empieza con /, ignora el baseUrl.
    // Para que use baseUrl (.../api/), el path DEBE ser relativo (sin / inicial).
    if (options.path.startsWith('/') && !options.path.startsWith('http')) {
      options.path = options.path.substring(1);
    }

    final token = await _storage.getAccess();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;

    if (response?.statusCode != 401) {
      handler.next(err);
      return;
    }
    
    if (err.requestOptions.path.contains('/auth/token/refresh/')) {
      await _storage.clearSession();
      handler.next(err);
      return;
    }
    
    if (err.requestOptions.extra['_retry'] == true) {
      await _storage.clearSession();
      handler.next(err);
      return;
    }

    final refresh = await _storage.getRefresh();
    if (refresh == null || refresh.isEmpty) {
      await _storage.clearSession();
      handler.next(err);
      return;
    }

    try {
      final refreshResponse = await _dio.post(
        'auth/token/refresh/', // Ruta relativa
        data: {'refresh': refresh},
        options: Options(extra: {'_retry': true}),
      );

      final newAccess = refreshResponse.data['access'] as String;
      final newRefresh = refreshResponse.data['refresh'] as String?;

      await _storage.saveAccessToken(newAccess);
      if (newRefresh != null) {
        await _storage.saveTokens(newAccess, newRefresh);
      }

      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';
      retryOptions.extra['_retry'] = true;

      final retryResponse = await _dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } on DioException {
      await _storage.clearSession();
      handler.next(err);
    }
  }
}
