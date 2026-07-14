// lib/data/repository/auth_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/auth_models.dart';
import '../../domain/repository/auth_repository.dart';
import '../local/secure_storage.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/auth_dto.dart';

class AuthRepositoryImpl implements AuthRepository {
  final Dio _dio;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._dio, this._storage);

  @override
  Future<LoggedUser> login(String username, String password) async {
    try {
      final res = await _dio.post(
        'auth/login/',
        data: {
          'username': username.trim(),
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final dto = LoginResponseDto.fromJson(res.data);
      
      await _storage.saveTokens(dto.access, dto.refresh);
      await _storage.saveUser(
        id: dto.userId,
        username: dto.username,
        email: dto.email,
        isStaff: dto.isStaff,
        role: dto.role,
        isVerified: dto.isVerified,
      );
      
      return LoggedUser(
        id: dto.userId,
        username: dto.username,
        email: dto.email,
        isStaff: dto.isStaff,
        role: dto.role,
        isVerified: dto.isVerified,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<LoggedUser> register(
    String username,
    String email,
    String password,
    String password2,
  ) async {
    try {
      final res = await _dio.post(
        'auth/register/',
        data: {
          'username': username.trim(),
          'email': email.trim(),
          'password': password,
          'password2': password2,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      final dto = LoginResponseDto.fromJson(res.data);
      
      await _storage.saveTokens(dto.access, dto.refresh);
      await _storage.saveUser(
        id: dto.userId,
        username: dto.username,
        email: dto.email,
        isStaff: dto.isStaff,
        role: dto.role,
        isVerified: dto.isVerified,
      );
      
      return LoggedUser(
        id: dto.userId,
        username: dto.username,
        email: dto.email,
        isStaff: dto.isStaff,
        role: dto.role,
        isVerified: dto.isVerified,
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> verifyEmail(String code) async {
    try {
      await _dio.post('auth/verify-email/', data: {'code': code});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      final refresh = await _storage.getRefresh();
      if (refresh != null && refresh.isNotEmpty) {
        await _dio.post('auth/logout/', data: {'refresh': refresh});
      }
    } catch (_) {
    } finally {
      await _storage.clearSession();
    }
  }

  @override
  Future<void> requestPasswordReset(String email) async {
    try {
      await _dio.post('auth/password-reset/request/', data: {'email': email});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
    required String newPassword2,
  }) async {
    try {
      await _dio.post(
        'auth/password-reset/confirm/',
        data: {
          'uidb64': uid,
          'token': token,
          'new_password': newPassword,
          'new_password_confirm': newPassword2,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    ref.watch(dioProvider),
    ref.watch(secureStorageProvider),
  );
});
