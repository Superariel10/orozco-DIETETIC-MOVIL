// lib/data/repository/order_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/order.dart';
import '../../domain/repository/order_repository.dart';
import '../remote/api/dio_client.dart';
import '../remote/dto/order_dto.dart';

class OrderRepositoryImpl implements OrderRepository {
  final Dio _dio;
  OrderRepositoryImpl(this._dio);

  @override
  Future<List<Order>> getMyOrders() async {
    try {
      final res = await _dio.get('consultas/');
      final list = (res.data as List)
          .map((e) => OrderDto.fromJson(e as Map<String, dynamic>))
          .toList();
      return list.map((dto) => Order.fromJson(dto.toJson()..['id'] = dto.id)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> getOrderDetail(int id) async {
    try {
      final res = await _dio.get('consultas/$id/');
      final dto = OrderDto.fromJson(res.data);
      return Order.fromJson(dto.toJson()..['id'] = dto.id);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<Order> createOrder(Map<String, dynamic> data) async {
    try {
      final res = await _dio.post('consultas/', data: data);
      final dto = OrderDto.fromJson(res.data);
      return Order.fromJson(dto.toJson()..['id'] = dto.id);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  return OrderRepositoryImpl(ref.watch(dioProvider));
});
