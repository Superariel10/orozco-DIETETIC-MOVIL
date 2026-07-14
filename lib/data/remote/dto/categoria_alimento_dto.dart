// lib/data/remote/dto/categoria_alimento_dto.dart

class CategoriaAlimentoDto {
  final int id;
  final String name;
  final String description;

  CategoriaAlimentoDto({
    required this.id,
    required this.name,
    required this.description,
  });

  factory CategoriaAlimentoDto.fromJson(Map<String, dynamic> json) {
    return CategoriaAlimentoDto(
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
