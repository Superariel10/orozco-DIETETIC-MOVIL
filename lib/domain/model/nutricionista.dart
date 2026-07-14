// lib/domain/model/nutricionista.dart

class Nutricionista {
  final int id;
  final int? userId;
  final String firstName;
  final String lastName;
  final String professionalId;
  final String specialty;
  final double consultationFee;
  final int consultationsCompleted;
  final bool isActive;

  const Nutricionista({
    required this.id,
    this.userId,
    required this.firstName,
    required this.lastName,
    required this.professionalId,
    required this.specialty,
    required this.consultationFee,
    required this.consultationsCompleted,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Nutricionista.fromJson(Map<String, dynamic> j) => Nutricionista(
    id: j['id'] as int,
    userId: j['user_id'] as int?,
    firstName: j['first_name'] as String? ?? '',
    lastName: j['last_name'] as String? ?? '',
    professionalId: j['professional_id'] as String? ?? '',
    specialty: j['specialty'] as String? ?? '',
    consultationFee: double.tryParse(j['consultation_fee']?.toString() ?? '0.0') ?? 0.0,
    consultationsCompleted: int.tryParse(j['consultations_completed']?.toString() ?? '0') ?? 0,
    isActive: j['is_active'] as bool? ?? true,
  );
}
