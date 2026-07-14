import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/product.dart';
import 'dio_client.dart';
import 'paginated_result.dart';

class ProductRemoteDatasource {
  final Dio _dio;
  ProductRemoteDatasource(this._dio);

  Future<PaginatedResult<Product>> getProducts({
    int page = 1,
    int pageSize = 20,
    String? search,
    bool? isActive,
    String? ordering,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (isActive != null) params['is_active'] = isActive;
    if (ordering != null && ordering.isNotEmpty) params['ordering'] = ordering;

    final res = await _dio.get('pacientes/', queryParameters: params);
    final data = res.data;
    final list = _extractList(data);
    final results = list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();

    return PaginatedResult<Product>(
      results: results,
      count: _extractCount(data),
      next: _extractNext(data),
      previous: _extractPrevious(data),
    );
  }

  Future<Product> createProduct(Map<String, dynamic> payload) async {
    final res = await _dio.post('pacientes/', data: payload);
    return Product.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Product> updateProduct(int id, Map<String, dynamic> payload) async {
    final res = await _dio.patch('pacientes/$id/', data: payload);
    return Product.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> restock(int id, int quantity) async {
    final res = await _dio.post('pacientes/$id/restock/', data: {'quantity': quantity});
    return Map<String, dynamic>.from(res.data as Map<String, dynamic>);
  }

  Future<void> deleteProduct(int id) async {
    await _dio.delete('pacientes/$id/');
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _dio.get('pacientes/stats/');
    return Map<String, dynamic>.from(res.data as Map<String, dynamic>);
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List;
    }
    return [];
  }

  int _extractCount(dynamic data) {
    if (data is Map && data.containsKey('count')) {
      return (data['count'] as num).toInt();
    }
    return _extractList(data).length;
  }

  String? _extractNext(dynamic data) {
    if (data is Map && data.containsKey('next')) {
      return data['next'] as String?;
    }
    return null;
  }

  String? _extractPrevious(dynamic data) {
    if (data is Map && data.containsKey('previous')) {
      return data['previous'] as String?;
    }
    return null;
  }
}

final productDatasourceProvider = Provider<ProductRemoteDatasource>((ref) {
  return ProductRemoteDatasource(ref.watch(dioProvider));
});
