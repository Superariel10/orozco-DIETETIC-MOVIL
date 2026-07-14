// lib/data/local/secure_storage.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  // Eliminamos encryptedSharedPreferences para mayor compatibilidad en emuladores
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: false),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  static const _keyAccess     = 'dietetic_app:access';
  static const _keyRefresh    = 'dietetic_app:refresh';
  static const _keyUserId     = 'dietetic_app:user_id';
  static const _keyUsername   = 'dietetic_app:username';
  static const _keyEmail      = 'dietetic_app:email';
  static const _keyIsStaff    = 'dietetic_app:is_staff';
  static const _keyRole       = 'dietetic_app:role';
  static const _keyIsVerified = 'dietetic_app:is_verified';

  Future<String?> getAccess()  => _storage.read(key: _keyAccess);
  Future<String?> getRefresh() => _storage.read(key: _keyRefresh);

  Future<void> saveTokens(String access, String refresh) async {
    await _storage.write(key: _keyAccess,  value: access);
    await _storage.write(key: _keyRefresh, value: refresh);
  }

  Future<void> saveAccessToken(String access) =>
      _storage.write(key: _keyAccess, value: access);

  Future<void> saveUser({
    required int    id,
    required String username,
    required String email,
    required bool   isStaff,
    required String role,
    bool   isVerified = false,
  }) async {
    await _storage.write(key: _keyUserId,     value: id.toString());
    await _storage.write(key: _keyUsername,   value: username);
    await _storage.write(key: _keyEmail,      value: email);
    await _storage.write(key: _keyIsStaff,    value: isStaff.toString());
    await _storage.write(key: _keyRole,       value: role);
    await _storage.write(key: _keyIsVerified, value: isVerified.toString());
  }

  Future<Map<String, String>?> getUser() async {
    final id = await _storage.read(key: _keyUserId);
    if (id == null) return null;
    return {
      'id':          id,
      'username':    await _storage.read(key: _keyUsername) ?? '',
      'email':       await _storage.read(key: _keyEmail) ?? '',
      'is_staff':    await _storage.read(key: _keyIsStaff) ?? 'false',
      'role':        await _storage.read(key: _keyRole) ?? 'paciente',
      'is_verified': await _storage.read(key: _keyIsVerified) ?? 'false',
    };
  }

  Future<bool> isLoggedIn() async {
    final access = await getAccess();
    return access != null && access.isNotEmpty;
  }

  Future<void> clearSession() => _storage.deleteAll();
}

final secureStorageProvider = Provider<SecureStorage>((_) => SecureStorage());
