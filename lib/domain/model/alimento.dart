// lib/domain/model/alimento.dart

class Alimento {
  final int id;
  final String name;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final int categoryId;

  const Alimento({
    required this.id,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.categoryId,
  });

  factory Alimento.fromJson(Map<String, dynamic> j) => Alimento(
    id: j['id'] as int,
    name: j['name'] as String? ?? '',
    calories: double.tryParse(j['calories']?.toString() ?? '0.0') ?? 0.0,
    protein: double.tryParse(j['protein']?.toString() ?? '0.0') ?? 0.0,
    carbs: double.tryParse(j['carbs']?.toString() ?? '0.0') ?? 0.0,
    fat: double.tryParse(j['fat']?.toString() ?? '0.0') ?? 0.0,
    categoryId: j['category'] is int ? j['category'] : (j['category']?['id'] as int? ?? 0),
  );
}
