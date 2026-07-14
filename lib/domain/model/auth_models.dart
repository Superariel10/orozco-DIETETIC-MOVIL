// lib/domain/model/auth_models.dart

enum UserRole {
  ADMINISTRADOR,
  NUTRICIONISTA,
  PACIENTE;

  String get value {
    switch (this) {
      case UserRole.ADMINISTRADOR: return 'admin';
      case UserRole.NUTRICIONISTA: return 'nutricionista';
      case UserRole.PACIENTE:      return 'paciente';
    }
  }

  static UserRole fromString(String role) {
    if (role == 'admin') return UserRole.ADMINISTRADOR;
    if (role == 'nutricionista') return UserRole.NUTRICIONISTA;
    return UserRole.PACIENTE;
  }
}

class AuthTokens {
  final String access;
  final String refresh;
  const AuthTokens({required this.access, required this.refresh});
}

class LoggedUser {
  final int    id;
  final String username;
  final String email;
  final bool   isStaff;
  final String role;
  final bool   isVerified;

  const LoggedUser({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.role,
    this.isVerified = false,
  });

  bool get isAdmin => role == 'admin';
  bool get isNutricionista => role == 'nutricionista';
  bool get isPaciente => role == 'paciente';

  UserRole get userRole => UserRole.fromString(role);

  factory LoggedUser.fromMap(Map<String, dynamic> map) => LoggedUser(
    id:       int.parse(map['id']?.toString() ?? map['user_id']?.toString() ?? '0'),
    username: map['username'] as String? ?? '',
    email:    map['email']    as String? ?? '',
    isStaff:  map['is_staff']?.toString() == 'true',
    role:     map['role']     as String? ?? 'paciente',
    isVerified: map['is_verified']?.toString() == 'true',
  );
}
