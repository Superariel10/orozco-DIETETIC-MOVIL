// lib/domain/model/order.dart

enum OrderStatus {
  programada,
  en_curso,
  completada,
  retrasada,
  cancelada;

  String get value => name;
  String get label => switch (this) {
    OrderStatus.programada => 'Programada',
    OrderStatus.en_curso   => 'En curso',
    OrderStatus.completada => 'Completada',
    OrderStatus.retrasada  => 'Retrasada',
    OrderStatus.cancelada  => 'Cancelada',
  };

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status.toLowerCase(),
      orElse: () => OrderStatus.programada,
    );
  }
}

class Order {
  final int id;
  final String status;
  final String sessionNotes;
  final String scheduledTime;
  final String estimatedEnd;
  final int planNutricionalId;
  final int pacienteId;
  final int? pacienteUserId; // ID del usuario Django del paciente
  final int nutricionistaId;
  final String? pacienteName;
  final String? nutricionistaName;

  const Order({
    required this.id,
    required this.status,
    required this.sessionNotes,
    required this.scheduledTime,
    required this.estimatedEnd,
    required this.planNutricionalId,
    required this.pacienteId,
    this.pacienteUserId,
    required this.nutricionistaId,
    this.pacienteName,
    this.nutricionistaName,
  });

  factory Order.fromJson(Map<String, dynamic> j) {
    final pacienteData = j['paciente'];
    final int? pId = pacienteData is Map ? pacienteData['id'] : int.tryParse(j['paciente']?.toString() ?? '0');
    final int? pUserId = pacienteData is Map ? pacienteData['user_id'] : null;
    final String? pName = pacienteData is Map ? pacienteData['full_name'] : j['paciente_name'];

    return Order(
      id: int.tryParse(j['id']?.toString() ?? '0') ?? 0,
      status: j['status'] as String? ?? 'programada',
      sessionNotes: j['session_notes'] as String? ?? '',
      scheduledTime: j['scheduled_time'] as String? ?? '',
      estimatedEnd: j['estimated_end'] as String? ?? '',
      planNutricionalId: j['plan_nutricional'] is Map ? (j['plan_nutricional']['id'] ?? 0) : int.tryParse(j['plan_nutricional']?.toString() ?? '0') ?? 0,
      pacienteId: pId ?? 0,
      pacienteUserId: pUserId,
      nutricionistaId: j['nutricionista'] is Map ? (j['nutricionista']['id'] ?? 0) : int.tryParse(j['nutricionista']?.toString() ?? '0') ?? 0,
      pacienteName: pName,
      nutricionistaName: j['nutricionista'] is Map ? j['nutricionista']['full_name'] : j['nutricionista_name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'session_notes': sessionNotes,
    'scheduled_time': scheduledTime,
    'estimated_end': estimatedEnd,
    'plan_nutricional': planNutricionalId,
    'paciente': pacienteId,
    'nutricionista': nutricionistaId,
  };

  Order copyWith({
    int? id,
    dynamic status,
    String? sessionNotes,
    String? scheduledTime,
  }) => Order(
    id: id ?? this.id,
    status: status is OrderStatus ? status.value : (status as String? ?? this.status),
    sessionNotes: sessionNotes ?? this.sessionNotes,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    estimatedEnd: estimatedEnd,
    planNutricionalId: planNutricionalId,
    pacienteId: pacienteId,
    pacienteUserId: pacienteUserId,
    nutricionistaId: nutricionistaId,
    pacienteName: pacienteName,
    nutricionistaName: nutricionistaName,
  );
}
