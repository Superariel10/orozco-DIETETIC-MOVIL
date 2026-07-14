// lib/data/repository/chat_repository_impl.dart

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/error/api_exception.dart';
import '../../domain/model/chat_message.dart';
import '../../domain/repository/chat_repository.dart';
import '../remote/api/dio_client.dart';

class ChatRepositoryImpl implements ChatRepository {
  final Dio _dio;
  ChatRepositoryImpl(this._dio);

  List<dynamic> _extractData(dynamic data) {
    if (data is List) return data;
    if (data is Map && data.containsKey('results')) {
      return data['results'] as List;
    }
    return [];
  }

  @override
  Future<List<ChatMessage>> getMessages() async {
    try {
      final res = await _dio.get('mensajes-chat/');
      final list = _extractData(res.data);
      return list.map((e) => ChatMessage.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  @override
  Future<void> sendMessage(int destinatarioId, String contenido) async {
    try {
      await _dio.post('mensajes-chat/', data: {
        'destinatario': destinatarioId,
        'contenido': contenido,
      });
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }
}

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepositoryImpl(ref.watch(dioProvider));
});
