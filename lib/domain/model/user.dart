// lib/domain/model/user.dart

class User {
  final int id;
  final String username;
  final String email;
  final bool isStaff;
  final String role;
  final String firstName;
  final String lastName;
  final bool isActive;

  const User({
    required this.id,
    required this.username,
    required this.email,
    required this.isStaff,
    required this.role,
    this.firstName = '',
    this.lastName = '',
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as int? ?? 0,
    username: j['username'] as String? ?? '',
    email: j['email'] as String? ?? '',
    isStaff: j['is_staff'] as bool? ?? false,
    role: j['role'] as String? ?? 'paciente',
    firstName: j['first_name'] as String? ?? '',
    lastName: j['last_name'] as String? ?? '',
    isActive: j['is_active'] as bool? ?? true,
  );

  bool get isAdmin => role == 'admin';
  bool get isNutricionista => role == 'nutricionista';

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'is_staff': isStaff,
    'role': role,
    'first_name': firstName,
    'last_name': lastName,
    'is_active': isActive,
  };

  User copyWith({
    int? id,
    String? username,
    String? email,
    bool? isStaff,
    String? role,
    String? firstName,
    String? lastName,
    bool? isActive,
  }) => User(
    id: id ?? this.id,
    username: username ?? this.username,
    email: email ?? this.email,
    isStaff: isStaff ?? this.isStaff,
    role: role ?? this.role,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    isActive: isActive ?? this.isActive,
  );
}
