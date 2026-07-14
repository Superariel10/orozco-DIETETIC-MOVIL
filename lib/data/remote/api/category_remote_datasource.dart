import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../dto/category_dto.dart';
import '../../../domain/model/category.dart';
import 'dio_client.dart';
import 'paginated_result.dart';

class CategoryRemoteDatasource {
  final Dio _dio;
  CategoryRemoteDatasource(this._dio);

  Future<List<Category>> getCategories() async {
    final res = await _dio.get('categorias-alimentos/');
    final list = _extractList(res.data);
    return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Category> getCategory(int id) async {
    final res = await _dio.get('categorias-alimentos/$id/');
    return Category.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Category> createCategory(Map<String, dynamic> payload) async {
    final res = await _dio.post('categorias-alimentos/', data: payload);
    return Category.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Category> updateCategory(int id, Map<String, dynamic> payload) async {
    final res = await _dio.patch('categorias-alimentos/$id/', data: payload);
    return Category.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteCategory(int id) async {
    await _dio.delete('categorias-alimentos/$id/');
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _dio.get('categorias-alimentos/stats/');
    return Map<String, dynamic>.from(res.data as Map<String, dynamic>);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List;
    }
    return [];
  }
}

final categoryDatasourceProvider = Provider<CategoryRemoteDatasource>((ref) {
  return CategoryRemoteDatasource(ref.watch(dioProvider));
});
