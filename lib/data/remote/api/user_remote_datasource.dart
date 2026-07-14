import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/user.dart';
import 'dio_client.dart';
import 'paginated_result.dart';

class UserRemoteDatasource {
  final Dio _dio;
  UserRemoteDatasource(this._dio);

  Future<PaginatedResult<User>> getUsers({
    int page = 1,
    String? search,
    String? role,
  }) async {
    final res = await _dio.get('users/', queryParameters: {
      'page': page,
      if (search != null) 'search': search,
      if (role != null) 'role': role,
    });
    final data = res.data;
    final list = _extractList(data);
    final results = list.map((e) => User.fromJson(e as Map<String, dynamic>)).toList();

    return PaginatedResult<User>(
      results: results,
      count: _extractCount(data),
      next: _extractNext(data),
      previous: _extractPrevious(data),
    );
  }

  Future<User> getUser(int id) async {
    final res = await _dio.get('users/$id/');
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<User> createUser(Map<String, dynamic> data) async {
    final res = await _dio.post('users/', data: data);
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<User> updateUser(int id, Map<String, dynamic> data) async {
    final res = await _dio.patch('users/$id/', data: data);
    return User.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> deleteUser(int id) async {
    await _dio.delete('users/$id/');
  }

  Future<bool> toggleActive(int id) async {
    final res = await _dio.post('users/$id/toggle-active/');
    return res.data['is_active'] as bool;
  }

  Future<Map<String, dynamic>> sendNotification({
    required String subject,
    required String message,
    int? userId,
  }) async {
    final res = await _dio.post('notificaciones-push/', data: {
      'subject': subject,
      'message': message,
      if (userId != null) 'user_id': userId,
    });
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getStats() async {
    final res = await _dio.get('users/stats/');
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

final userDatasourceProvider = Provider<UserRemoteDatasource>((ref) {
  return UserRemoteDatasource(ref.watch(dioProvider));
});
