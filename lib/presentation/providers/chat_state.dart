// lib/presentation/providers/chat_state.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/model/chat_message.dart';
import '../../data/repository/chat_repository_impl.dart';

// SERVICIO DE CHAT CONECTADO AL BACKEND
final globalChatProvider = StateNotifierProvider<GlobalChatNotifier, AsyncValue<List<ChatMessage>>>((ref) {
  return GlobalChatNotifier(ref.watch(chatRepositoryProvider));
});

class GlobalChatNotifier extends StateNotifier<AsyncValue<List<ChatMessage>>> {
  final dynamic _repository;
  GlobalChatNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadMessages();
  }

  Future<void> loadMessages() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.getMessages());
  }

  Future<void> sendMessage(int destinatarioId, String contenido) async {
    try {
      await _repository.sendMessage(destinatarioId, contenido);
      await loadMessages();
    } catch (e) {
      // Error manejado
    }
  }
}
