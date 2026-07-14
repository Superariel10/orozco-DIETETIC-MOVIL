// lib/domain/model/category.dart

class Category {
  final int id;
  final String name;
  final String description;
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.isActive = true,
  });

  factory Category.fromJson(Map<String, dynamic> j) => Category(
    id: j['id'] as int? ?? 0,
    name: j['name'] as String? ?? '',
    description: j['description'] as String? ?? '',
    isActive: j['is_active'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'is_active': isActive,
  };

  Category copyWith({
    int? id,
    String? name,
    String? description,
    bool? isActive,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    isActive: isActive ?? this.isActive,
  );
}
