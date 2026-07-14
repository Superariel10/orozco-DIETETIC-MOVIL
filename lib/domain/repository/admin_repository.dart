// lib/domain/repository/admin_repository.dart

import '../model/user.dart';
import '../model/product.dart';
import '../model/category.dart';
import '../model/order.dart';
import '../model/nutricionista.dart';
import '../model/plan_nutricional.dart';

abstract class AdminRepository {
  // Usuarios
  Future<List<User>> getAllUsers();
  Future<User> updateUser(int id, Map<String, dynamic> data); // NUEVO

  // Pacientes (Productos)
  Future<List<Product>> getAllProducts();
  Future<Product> createProduct(Map<String, dynamic> data);
  Future<Product> updateProduct(int id, Map<String, dynamic> data);
  Future<void> deleteProduct(int id);

  // Categorías
  Future<List<Category>> getAllCategories();
  Future<Category> createCategory(Map<String, dynamic> data);
  Future<Category> updateCategory(int id, Map<String, dynamic> data);
  Future<void> deleteCategory(int id);

  // Consultas
  Future<List<Order>> getAllOrders();
  Future<Order> updateOrderStatus(int id, String status);

  // Nutricionistas
  Future<List<Nutricionista>> getAllNutricionistas();
  Future<Nutricionista> createNutricionista(Map<String, dynamic> data);
  Future<Nutricionista> updateNutricionista(int id, Map<String, dynamic> data);
  Future<void> deleteNutricionista(int id);

  // Planes
  Future<List<PlanNutricional>> getAllPlanes();
  Future<PlanNutricional> createPlan(Map<String, dynamic> data);
  Future<PlanNutricional> updatePlan(int id, Map<String, dynamic> data);
  Future<void> deletePlan(int id);

  // Alimentos
  Future<void> createAlimento(Map<String, dynamic> data);
  Future<void> updateAlimento(int id, Map<String, dynamic> data);
  Future<void> deleteAlimento(int id);

  // Genérico
  Future<List<dynamic>> getTableData(String endpoint);
  Future<void> deleteFromTable(String endpoint, int id);
}
