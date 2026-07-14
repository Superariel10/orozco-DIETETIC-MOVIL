// lib/data/remote/dto/plan_nutricional_dto.dart

class PlanNutricionalDto {
  final int id;
  final String name;
  final String description;
  final String goal;
  final int targetCalories;
  final int durationWeeks;
  final double estimatedCost;
  final bool isActive;

  PlanNutricionalDto({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.targetCalories,
    required this.durationWeeks,
    required this.estimatedCost,
    required this.isActive,
  });

  factory PlanNutricionalDto.fromJson(Map<String, dynamic> json) {
    return PlanNutricionalDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      goal: json['goal'] as String? ?? '',
      targetCalories: int.tryParse(json['target_calories']?.toString() ?? '0') ?? 0,
      durationWeeks: int.tryParse(json['duration_weeks']?.toString() ?? '0') ?? 0,
      estimatedCost: double.tryParse(json['estimated_cost']?.toString() ?? '0.0') ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'goal': goal,
      'target_calories': targetCalories,
      'duration_weeks': durationWeeks,
      'estimated_cost': estimatedCost,
      'is_active': isActive,
    };
  }
}
