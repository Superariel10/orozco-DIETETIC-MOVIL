/// lib/presentation/providers/admin_provider.dart
///
/// GESTIÓN DE ESTADO - ROL: ADMINISTRADOR
/// 
/// Este archivo centraliza la lógica de negocio para la Vista de Administrador,
/// siguiendo un enfoque Mobile-First y garantizando la separación de roles.
/// 
/// DISEÑO VISUAL (VISTA ADMINISTRADOR):
/// - Paleta: Predominio de Azul Marino (#2C3E50) y alertas en Coral (#E67E22).
/// - Estructura: Bottom Navigation con acceso a Dashboard, Personal y Catálogo.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repository/admin_repository.dart';
import '../../data/repository/admin_repository_impl.dart';
import '../../domain/model/product.dart';
import '../../domain/model/category.dart';
import '../../domain/model/order.dart';
import '../../domain/model/user.dart';
import '../../domain/model/nutricionista.dart';
import '../../domain/model/plan_nutricional.dart';
import '../../domain/model/alimento.dart';

// --- SECCIÓN: FACTURAS (CASH FLOW) ---
final adminFacturasProvider = FutureProvider<List<dynamic>>((ref) async {
  return ref.watch(adminRepositoryProvider).getTableData('facturas-pago');
});

// --- SECCIÓN: ALIMENTOS MAESTROS ---
/// [Pantalla 3: Catálogo Maestro]
/// Gestiona la lista de alimentos disponibles en el sistema.
/// Tablas relacionadas: alimento_programado.py
final adminAlimentosProvider = StateNotifierProvider<AdminAlimentosNotifier, AsyncValue<List<Alimento>>>((ref) {
  return AdminAlimentosNotifier(ref.watch(adminRepositoryProvider));
});

class AdminAlimentosNotifier extends StateNotifier<AsyncValue<List<Alimento>>> {
  final AdminRepository _repository;
  AdminAlimentosNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadAlimentos();
  }

  Future<void> loadAlimentos() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _repository.getTableData('alimentos');
      return data.map((e) => Alimento.fromJson(e as Map<String, dynamic>)).toList();
    });
  }

  Future<void> createAlimento(Map<String, dynamic> data) async {
    try {
      await _repository.createAlimento(data);
      await loadAlimentos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateAlimento(int id, Map<String, dynamic> data) async {
    try {
      await _repository.updateAlimento(id, data);
      await loadAlimentos();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAlimento(int id) async {
    try {
      await _repository.deleteAlimento(id);
      await loadAlimentos();
    } catch (e) {
      rethrow;
    }
  }
}

// --- SECCIÓN: PACIENTES ---
/// Gestiona la lista de pacientes (mapeados desde el modelo Product).
/// Se utiliza para supervisar la base de datos de usuarios finales.
/// Tablas relacionadas: paciente.py, user.py
final adminProductsProvider = StateNotifierProvider<AdminProductsNotifier, AsyncValue<List<Product>>>((ref) {
  return AdminProductsNotifier(ref.watch(adminRepositoryProvider));
});

class AdminProductsNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final AdminRepository _repository;
  AdminProductsNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadProducts();
  }

  Future<void> loadProducts() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllProducts());
  }

  Future<void> createProduct(Map<String, dynamic> data) async {
    await _repository.createProduct(data);
    await loadProducts();
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await _repository.updateProduct(id, data);
    await loadProducts();
  }

  Future<void> deleteProduct(int id) async {
    await _repository.deleteProduct(id);
    await loadProducts();
  }
}

// --- SECCIÓN: CATEGORÍAS (CATÁLOGO MAESTRO) ---
/// [Pantalla 3: Catálogo Maestro]
/// Permite la validación y edición de las categorías de alimentos.
/// Tablas relacionadas: categoria_alimento.py
final adminCategoriesProvider = StateNotifierProvider<AdminCategoriesNotifier, AsyncValue<List<Category>>>((ref) {
  return AdminCategoriesNotifier(ref.watch(adminRepositoryProvider));
});

class AdminCategoriesNotifier extends StateNotifier<AsyncValue<List<Category>>> {
  final AdminRepository _repository;
  AdminCategoriesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadCategories();
  }

  Future<void> loadCategories() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllCategories());
  }

  Future<void> createCategory(Map<String, dynamic> data) async {
    await _repository.createCategory(data);
    await loadCategories();
  }

  Future<void> updateCategory(int id, Map<String, dynamic> data) async {
    await _repository.updateCategory(id, data);
    await loadCategories();
  }

  Future<void> deleteCategory(int id) async {
    await _repository.deleteCategory(id);
    await loadCategories();
  }
}

// --- SECCIÓN: CONSULTAS (DASHBOARD) ---
/// [Pantalla 1: Dashboard de Control]
/// Visualización de métricas globales de citas y estado de servicios.
/// Tablas relacionadas: consulta_dietetica.py
final adminOrdersProvider = StateNotifierProvider<AdminOrdersNotifier, AsyncValue<List<Order>>>((ref) {
  return AdminOrdersNotifier(ref.watch(adminRepositoryProvider));
});

class AdminOrdersNotifier extends StateNotifier<AsyncValue<List<Order>>> {
  final AdminRepository _repository;
  AdminOrdersNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllOrders());
  }

  Future<void> updateStatus(int id, String status) async {
    await _repository.updateOrderStatus(id, status);
    await loadOrders();
  }
}

// --- SECCIÓN: NUTRICIONISTAS (GESTIÓN DE PERSONAL) ---
/// [Pantalla 2: Gestión de Personal]
/// Lista para activar/desactivar cuentas y gestionar el staff clínico.
/// Tablas relacionadas: nutricionista.py, auth.py
final adminNutricionistasProvider = StateNotifierProvider<AdminNutricionistasNotifier, AsyncValue<List<Nutricionista>>>((ref) {
  return AdminNutricionistasNotifier(ref.watch(adminRepositoryProvider));
});

class AdminNutricionistasNotifier extends StateNotifier<AsyncValue<List<Nutricionista>>> {
  final AdminRepository _repository;
  AdminNutricionistasNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadNutricionistas();
  }

  Future<void> loadNutricionistas() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllNutricionistas());
  }

  Future<void> createNutricionista(Map<String, dynamic> data) async {
    await _repository.createNutricionista(data);
    await loadNutricionistas();
  }

  Future<void> updateNutricionista(int id, Map<String, dynamic> data) async {
    await _repository.updateNutricionista(id, data);
    await loadNutricionistas();
  }

  Future<void> deleteNutricionista(int id) async {
    await _repository.deleteNutricionista(id);
    await loadNutricionistas();
  }
}

// --- SECCIÓN: PLANES NUTRICIONALES ---
/// Supervisión de los planes generados por los nutricionistas.
/// Tablas relacionadas: plan_nutricional.py
final adminPlanesProvider = StateNotifierProvider<AdminPlanesNotifier, AsyncValue<List<PlanNutricional>>>((ref) {
  return AdminPlanesNotifier(ref.watch(adminRepositoryProvider));
});

class AdminPlanesNotifier extends StateNotifier<AsyncValue<List<PlanNutricional>>> {
  final AdminRepository _repository;
  AdminPlanesNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadPlanes();
  }

  Future<void> loadPlanes() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getAllPlanes());
  }

  Future<void> createPlan(Map<String, dynamic> data) async {
    await _repository.createPlan(data);
    await loadPlanes();
  }

  Future<void> updatePlan(int id, Map<String, dynamic> data) async {
    await _repository.updatePlan(id, data);
    await loadPlanes();
  }

  Future<void> deletePlan(int id) async {
    await _repository.deletePlan(id);
    await loadPlanes();
  }
}

// --- SECCIÓN: USUARIOS (AUTH) ---
/// [Pantalla 2: Gestión de Personal]
/// Acceso directo a la tabla de usuarios para gestión de credenciales.
/// Tablas relacionadas: user.py, auth.py
final adminUsersProvider = FutureProvider<List<User>>((ref) async {
  return ref.watch(adminRepositoryProvider).getAllUsers();
});

// NUEVO: Estado para el término de búsqueda en usuarios
final userSearchQueryProvider = StateProvider<String>((ref) => '');
