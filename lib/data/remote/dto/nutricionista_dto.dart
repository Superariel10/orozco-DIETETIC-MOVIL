// lib/data/remote/dto/nutricionista_dto.dart

class NutricionistaDto {
  final int id;
  final String firstName;
  final String lastName;
  final String professionalId;
  final String specialty;
  final double consultationFee;
  final int consultationsCompleted;
  final bool isActive;
  final String? fullName;

  NutricionistaDto({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.professionalId,
    required this.specialty,
    required this.consultationFee,
    required this.consultationsCompleted,
    required this.isActive,
    this.fullName,
  });

  factory NutricionistaDto.fromJson(Map<String, dynamic> json) {
    return NutricionistaDto(
      id: json['id'] as int,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      professionalId: json['professional_id'] as String? ?? '',
      specialty: json['specialty'] as String? ?? '',
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      consultationsCompleted: json['consultations_completed'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      fullName: json['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'professional_id': professionalId,
      'specialty': specialty,
      'consultation_fee': consultationFee,
      'consultations_completed': consultationsCompleted,
      'is_active': isActive,
    };
  }
}
