// lib/presentation/providers/profile_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_shop_app/presentation/domain/model/user_profile.dart';

import '../../core/error/api_exception.dart';
import '../../data/remote/api/dio_client.dart';

final profileProvider = FutureProvider.autoDispose<UserProfile>((ref) async {
  final dio = ref.watch(dioProvider);
  try {
    final res = await dio.get('/users/profile/');
    return UserProfile.fromJson(res.data as Map<String, dynamic>);
  } on DioException catch (e) {
    throw ApiException.fromDioError(e);
  }
});