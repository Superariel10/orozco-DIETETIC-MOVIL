// lib/data/repository/admin_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../../domain/model/order.dart';
import '../../domain/model/user.dart';
import '../../domain/model/nutricionista.dart';
import '../../domain/model/plan_nutricional.dart';
import '../../domain/repository/admin_repository.dart';
import '../remote/api/dio_client.dart';

class AdminRepositoryImpl implements AdminRepository {
  final Dio _dio;
  AdminRepositoryImpl(this._dio);

  List<dynamic> _extractData(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List;
    }
    return [];
  }

  @override
  Future<List<User>> getAllUsers() async {
    try {
      final res = await _dio.get('users/', queryParameters: {'page_size': 100});
      final list = _extractData(res.data);
      return list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('users/$id/', data: data);
      return User.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<Product>> getAllProducts() async {
    try {
      final res = await _dio.get('pacientes/', queryParameters: {'page_size': 100});
      final list = _extractData(res.data);
      return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Product> createProduct(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('pacientes/', data: data);
      return Product.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Product> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('pacientes/$id/', data: data);
      return Product.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await _dio.delete('pacientes/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<Category>> getAllCategories() async {
    try {
      final res = await _dio.get('categorias-alimentos/');
      final list = _extractData(res.data);
      return list.map((e) => Category.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> createCategory(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('categorias-alimentos/', data: data);
      return Category.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Category> updateCategory(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('categorias-alimentos/$id/', data: data);
      return Category.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(int id) async {
    try {
      await _dio.delete('categorias-alimentos/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<Order>> getAllOrders() async {
    try {
      final res = await _dio.get('consultas/');
      final list = _extractData(res.data);
      return list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> updateOrderStatus(int id, String status) async {
    try {
      final res = await _dio.patch('consultas/$id/', data: {'status': status});
      return Order.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<Nutricionista>> getAllNutricionistas() async {
    try {
      final res = await _dio.get('nutricionistas/', queryParameters: {'page_size': 100});
      final list = _extractData(res.data);
      return list.map((e) => Nutricionista.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Nutricionista> createNutricionista(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('nutricionistas/', data: data);
      return Nutricionista.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Nutricionista> updateNutricionista(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('nutricionistas/$id/', data: data);
      return Nutricionista.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteNutricionista(int id) async {
    try {
      await _dio.delete('nutricionistas/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<PlanNutricional>> getAllPlanes() async {
    try {
      final res = await _dio.get('planes/');
      final list = _extractData(res.data);
      return list.map((e) => PlanNutricional.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PlanNutricional> createPlan(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('planes/', data: data);
      return PlanNutricional.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<PlanNutricional> updatePlan(int id, Map<String, dynamic> data) async {
    try {
      final res = await _dio.patch('planes/$id/', data: data);
      return PlanNutricional.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deletePlan(int id) async {
    try {
      await _dio.delete('planes/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> createAlimento(Map<String, dynamic> data) async {
    try {
      await _dio.post('alimentos/', data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> updateAlimento(int id, Map<String, dynamic> data) async {
    try {
      await _dio.patch('alimentos/$id/', data: data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteAlimento(int id) async {
    try {
      await _dio.delete('alimentos/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<List<dynamic>> getTableData(String endpoint) async {
    try {
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      final res = await _dio.get('$cleanEndpoint/');
      return _extractData(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> deleteFromTable(String endpoint, int id) async {
    try {
      final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
      await _dio.delete('$cleanEndpoint/$id/');
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepositoryImpl(ref.watch(dioProvider));
});
