// lib/presentation/providers/cart_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  CartNotifier() : super([]);

  void addToCart(Map<String, dynamic> plan) {
    if (!state.any((item) => item['id'] == plan['id'])) {
      state = [...state, plan];
    }
  }

  void removeFromCart(int planId) {
    state = state.where((item) => item['id'] != planId).toList();
  }

  void clearCart() {
    state = [];
  }

  double get total => state.fold(0, (sum, item) => sum + (double.tryParse(item['estimated_cost'].toString()) ?? 0));
}

final cartProvider = StateNotifierProvider<CartNotifier, List<Map<String, dynamic>>>((ref) {
  return CartNotifier();
});
