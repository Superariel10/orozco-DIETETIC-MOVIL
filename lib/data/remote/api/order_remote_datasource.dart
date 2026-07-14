import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/order.dart';
import 'dio_client.dart';
import 'paginated_result.dart';

class OrderRemoteDatasource {
  final Dio _dio;
  OrderRemoteDatasource(this._dio);

  Future<PaginatedResult<Order>> getOrders({
    int page = 1,
    String? status,
  }) async {
    final res = await _dio.get('consultas/', queryParameters: {
      'page': page,
      if (status != null && status.isNotEmpty) 'status': status,
    });
    final data = res.data;
    final list = _extractList(data);
    final results = list.map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();

    return PaginatedResult<Order>(
      results: results,
      count: _extractCount(data),
      next: _extractNext(data),
      previous: _extractPrevious(data),
    );
  }

  Future<Order> getOrder(int id) async {
    final res = await _dio.get('consultas/$id/');
    return Order.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Order> updateStatus(int id, String status) async {
    final res = await _dio.patch('consultas/$id/', data: {'status': status});
    return Order.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Order> createOrder({Map<String, dynamic>? data}) async {
    final res = await _dio.post('consultas/', data: data ?? {});
    return Order.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> addItem(int orderId, int productId, int quantity) async {
    await _dio.post('consultas/$orderId/add-item/', data: {
      'product_id': productId,
      'quantity': quantity,
    });
  }

  Future<Order> confirmOrder(int orderId) async {
    final res = await _dio.patch('consultas/$orderId/', data: {'status': 'confirmed'});
    return Order.fromJson(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _dio.get('consultas/stats/');
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

final orderDatasourceProvider = Provider<OrderRemoteDatasource>((ref) {
  return OrderRemoteDatasource(ref.watch(dioProvider));
});
