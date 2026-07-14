// lib/domain/repository/chat_repository.dart

import '../model/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> getMessages();
  Future<void> sendMessage(int destinatarioId, String contenido);
}
