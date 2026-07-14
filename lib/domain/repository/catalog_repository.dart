// lib/domain/repository/catalog_repository.dart

import '../model/category.dart';
import '../model/product.dart';

abstract class CatalogRepository {
  Future<List<Category>> getCategories();
  Future<List<Product>> getProducts();
  Future<Product> getProductDetail(int id);
}
