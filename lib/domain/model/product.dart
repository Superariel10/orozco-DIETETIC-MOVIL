// lib/domain/model/product.dart

class Product {
  final int id;
  final int? userId;
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
  final String createdAt;
  final String updatedAt;
  
  // Compatibilidad con Shop UI
  final String name; 
  final int stock;
  final bool isActive;

  const Product({
    required this.id,
    this.userId,
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
    required this.createdAt,
    required this.updatedAt,
    this.name = '',
    this.stock = 0,
    this.isActive = true,
  });

  String get fullName => name.isNotEmpty ? name : '$firstName $lastName'.trim();
  
  double get bmi {
    final heightM = heightCm / 100;
    if (heightM <= 0) return 0;
    return double.parse((currentWeight / (heightM * heightM)).toStringAsFixed(2));
  }

  factory Product.fromJson(Map<String, dynamic> j) {
    final fName = j['first_name'] as String? ?? '';
    final lName = j['last_name'] as String? ?? '';
    
    return Product(
      id: j['id'] as int? ?? 0,
      userId: j['user'] as int?,
      patientCode: j['patient_code'] as String? ?? '',
      firstName: fName,
      lastName: lName,
      age: int.tryParse(j['age']?.toString() ?? '0') ?? 0,
      goal: j['goal'] as String? ?? '',
      dietaryRestrictions: j['dietary_restrictions'] as String? ?? '',
      currentWeight: double.tryParse(j['current_weight']?.toString() ?? '0.0') ?? 0.0,
      heightCm: double.tryParse(j['height_cm']?.toString() ?? '0.0') ?? 0.0,
      status: j['status'] as String? ?? 'activo',
      medicalNotes: j['medical_notes'] as String? ?? '',
      createdAt: j['created_at'] as String? ?? '',
      updatedAt: j['updated_at'] as String? ?? '',
      name: j['name'] as String? ?? (fName.isNotEmpty ? '$fName $lName' : ''),
      stock: j['stock'] as int? ?? 0,
      isActive: j['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
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
    'name': name,
    'stock': stock,
    'is_active': isActive,
  };

  Product copyWith({
    int? id,
    String? patientCode,
    String? firstName,
    String? lastName,
    int? age,
    String? goal,
    double? currentWeight,
    double? heightCm,
    String? status,
    String? name,
    int? stock,
    bool? isActive,
  }) => Product(
    id: id ?? this.id,
    userId: userId,
    patientCode: patientCode ?? this.patientCode,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    age: age ?? this.age,
    goal: goal ?? this.goal,
    dietaryRestrictions: dietaryRestrictions,
    currentWeight: currentWeight ?? this.currentWeight,
    heightCm: heightCm ?? this.heightCm,
    status: status ?? this.status,
    medicalNotes: medicalNotes,
    createdAt: createdAt,
    updatedAt: updatedAt,
    name: name ?? this.name,
    stock: stock ?? this.stock,
    isActive: isActive ?? this.isActive,
  );
}
