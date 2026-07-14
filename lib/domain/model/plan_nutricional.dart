// lib/domain/model/plan_nutricional.dart

class PlanNutricional {
  final int id;
  final String name;
  final String description;
  final String goal;
  final int targetCalories;
  final int durationWeeks;
  final double estimatedCost;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  PlanNutricional({
    required this.id,
    required this.name,
    required this.description,
    required this.goal,
    required this.targetCalories,
    required this.durationWeeks,
    required this.estimatedCost,
    required this.isActive,
    this.createdAt = '',
    this.updatedAt = '',
  });

  bool get hasDescription => description.isNotEmpty;
  double get costWithTax => estimatedCost * 1.15;

  factory PlanNutricional.fromJson(Map<String, dynamic> j) => PlanNutricional(
    id: j['id'] as int,
    name: j['name'] as String? ?? '',
    description: j['description'] as String? ?? '',
    goal: j['goal'] as String? ?? '',
    targetCalories: int.tryParse(j['target_calories']?.toString() ?? '0') ?? 0,
    durationWeeks: int.tryParse(j['duration_weeks']?.toString() ?? '0') ?? 0,
    estimatedCost: double.tryParse(j['estimated_cost']?.toString() ?? '0.0') ?? 0.0,
    isActive: j['is_active'] as bool? ?? true,
    createdAt: j['created_at'] as String? ?? '',
    updatedAt: j['updated_at'] as String? ?? '',
  );
}
