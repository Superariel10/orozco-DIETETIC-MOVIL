// lib/domain/repository/order_repository.dart

import '../model/order.dart';

abstract class OrderRepository {
  Future<List<Order>> getMyOrders();
  Future<Order> getOrderDetail(int id);
  Future<Order> createOrder(Map<String, dynamic> data);
}
