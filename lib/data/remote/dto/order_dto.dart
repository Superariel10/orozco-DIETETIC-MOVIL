// lib/data/remote/dto/order_dto.dart

class OrderDto {
  final int id;
  final String status;
  final String sessionNotes;
  final String scheduledTime;
  final String estimatedEnd;
  final int planNutricional;
  final int paciente;
  final int nutricionista;

  OrderDto({
    required this.id,
    required this.status,
    required this.sessionNotes,
    required this.scheduledTime,
    required this.estimatedEnd,
    required this.planNutricional,
    required this.paciente,
    required this.nutricionista,
  });

  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as int,
      status: json['status'] as String,
      sessionNotes: json['session_notes'] as String? ?? '',
      scheduledTime: json['scheduled_time'] as String,
      estimatedEnd: json['estimated_end'] as String,
      planNutricional: json['plan_nutricional'] as int,
      paciente: json['paciente'] as int,
      nutricionista: json['nutricionista'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'session_notes': sessionNotes,
      'scheduled_time': scheduledTime,
      'estimated_end': estimatedEnd,
      'plan_nutricional': planNutricional,
      'paciente': paciente,
      'nutricionista': nutricionista,
    };
  }
}
