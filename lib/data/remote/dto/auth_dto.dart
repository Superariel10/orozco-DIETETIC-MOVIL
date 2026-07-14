// lib/data/remote/dto/auth_dto.dart

class LoginResponseDto {
  final String access;
  final String refresh;
  final int userId;
  final String username;
  final String email;
  final bool isStaff;
  final String role;
  final bool isVerified;

  LoginResponseDto({
    required this.access,
    required this.refresh,
    required this.userId,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.role,
    this.isVerified = false,
  });

  factory LoginResponseDto.fromJson(Map<String, dynamic> json) {
    return LoginResponseDto(
      access: json['access'] as String,
      refresh: json['refresh'] as String,
      userId: json['user_id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      isStaff: json['is_staff'] as bool,
      role: json['role'] as String? ?? 'paciente',
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}

class RegisterRequestDto {
  final String username;
  final String email;
  final String password;
  final String password2;

  RegisterRequestDto({
    required this.username,
    required this.email,
    required this.password,
    required this.password2,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      'password2': password2,
    };
  }
}
