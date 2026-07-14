// lib/data/repository/catalog_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/catalog_repository.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/category_dto.dart';
import '../remote/dto/product_dto.dart';

class CatalogRepositoryImpl implements CatalogRepository {
  final Dio _dio;
  CatalogRepositoryImpl(this._dio);

  List<dynamic> _extractData(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List;
    }
    return [];
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      final res = await _dio.get('categorias-alimentos/');
      final list = _extractData(res.data);
      return list.map((e) {
        final dto = CategoryDto.fromJson(e as Map<String, dynamic>);
        return Category(
          id: dto.id,
          name: dto.name,
          description: dto.description,
          isActive: true,
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<Product>> getProducts() async {
    try {
      final res = await _dio.get('pacientes/');
      final list = _extractData(res.data);
      return list.map((e) {
        final dto = ProductDto.fromJson(e as Map<String, dynamic>);
        return Product.fromJson(dto.toJson()..['id'] = dto.id);
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Product> getProductDetail(int id) async {
    try {
      final res = await _dio.get('pacientes/$id/');
      final dto = ProductDto.fromJson(res.data);
      return Product.fromJson(dto.toJson()..['id'] = dto.id);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepositoryImpl(ref.watch(dioProvider));
});
