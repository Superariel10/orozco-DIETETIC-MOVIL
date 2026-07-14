// lib/data/remote/dto/product_dto.dart

class ProductDto {
  final int id;
  final String patientCode;
  final String firstName;
  final String lastName;
  final int age;
  final String goal;
  final String dietaryRestrictions;
  final double currentWeight;
  final double heightCm;
  final String status;
  final String medicalNotes;

  ProductDto({
    required this.id,
    required this.patientCode,
    required this.firstName,
    required this.lastName,
    required this.age,
    required this.goal,
    required this.dietaryRestrictions,
    required this.currentWeight,
    required this.heightCm,
    required this.status,
    required this.medicalNotes,
  });

  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as int,
      patientCode: json['patient_code'] as String,
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      goal: json['goal'] as String? ?? '',
      dietaryRestrictions: json['dietary_restrictions'] as String? ?? '',
      currentWeight: (json['current_weight'] as num?)?.toDouble() ?? 0.0,
      heightCm: (json['height_cm'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'activo',
      medicalNotes: json['medical_notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'patient_code': patientCode,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'goal': goal,
      'dietary_restrictions': dietaryRestrictions,
      'current_weight': currentWeight,
      'height_cm': heightCm,
      'status': status,
      'medical_notes': medicalNotes,
    };
  }
}
