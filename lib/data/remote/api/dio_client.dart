// lib/data/remote/api/dio_client.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../local/secure_storage.dart';
import '../interceptor/auth_interceptor.dart';
import '../../../core/config/app_config.dart';

Dio createDioClient(SecureStorage storage) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.baseUrl, // Ya garantizado con barra al final
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.addAll([
    AuthInterceptor(storage, dio),
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (o) => debugPrint(o.toString()),
    ),
  ]);

  return dio;
}

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return createDioClient(storage);
});
