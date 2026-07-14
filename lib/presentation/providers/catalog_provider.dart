// lib/presentation/providers/catalog_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/category.dart';
import '../../domain/model/product.dart';
import '../../domain/repository/catalog_repository.dart';
import '../../data/repository/catalog_repository_impl.dart';

final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  return ref.watch(catalogRepositoryProvider).getCategories();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  return ref.watch(catalogRepositoryProvider).getProducts();
});

final productDetailProvider = FutureProvider.family<Product, int>((ref, id) async {
  return ref.watch(catalogRepositoryProvider).getProductDetail(id);
});
