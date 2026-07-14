// lib/data/remote/dto/category_dto.dart

class CategoryDto {
  final int id;
  final String name;
  final String description;

  CategoryDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
