// lib/domain/model/patient_features.dart

class RutinaEjercicio {
  final int id;
  final String name;
  final String description;
  final String difficulty;
  final int durationMinutes;

  RutinaEjercicio({
    required this.id,
    required this.name,
    required this.description,
    required this.difficulty,
    required this.durationMinutes,
  });

  factory RutinaEjercicio.fromJson(Map<String, dynamic> json) {
    return RutinaEjercicio(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'media',
      durationMinutes: json['duration_minutes'] as int? ?? 30,
    );
  }
}

class ProgresoFoto {
  final int id;
  final String date;
  final String? imageUrl;
  final String? localPath; // Ruta local para privacidad
  final String notes;

  ProgresoFoto({
    required this.id,
    required this.date,
    this.imageUrl,
    this.localPath,
    required this.notes,
  });

  factory ProgresoFoto.fromJson(Map<String, dynamic> json) {
    return ProgresoFoto(
      id: json['id'] as int? ?? 0,
      date: json['fecha_subida'] as String? ?? json['date'] as String? ?? '',
      imageUrl: json['foto'] as String? ?? json['imageUrl'] as String?,
      localPath: json['localPath'] as String?,
      notes: json['descripcion'] as String? ?? json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date,
    'imageUrl': imageUrl,
    'localPath': localPath,
    'notes': notes,
  };
}

class RegistroAgua {
  final int id;
  final String date;
  final double amountLiters;

  RegistroAgua({
    required this.id,
    required this.date,
    required this.amountLiters,
  });

  factory RegistroAgua.fromJson(Map<String, dynamic> json) {
    return RegistroAgua(
      id: json['id'] as int,
      date: json['date'] as String? ?? '',
      amountLiters: double.tryParse(json['amount_liters']?.toString() ?? '0.0') ?? 0.0,
    );
  }
}

class SintomaDiario {
  final int id;
  final String date;
  final String description;
  final int intensity; // 1-10

  SintomaDiario({
    required this.id,
    required this.date,
    required this.description,
    required this.intensity,
  });

  factory SintomaDiario.fromJson(Map<String, dynamic> json) {
    return SintomaDiario(
      id: json['id'] as int,
      date: json['date'] as String? ?? '',
      description: json['description'] as String? ?? '',
      intensity: json['intensity'] as int? ?? 1,
    );
  }
}
