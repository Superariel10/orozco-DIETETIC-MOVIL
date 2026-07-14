// lib/domain/model/chat_message.dart

class ChatMessage {
  final int id;
  final int remitenteId;
  final int destinatarioId;
  final String contenido;
  final DateTime timestamp;
  final bool leido;

  ChatMessage({
    required this.id,
    required this.remitenteId,
    required this.destinatarioId,
    required this.contenido,
    required this.timestamp,
    required this.leido,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
    id: j['id'] as int,
    remitenteId: j['remitente_id'] as int,
    destinatarioId: j['destinatario_id'] as int,
    contenido: j['contenido'] as String,
    timestamp: DateTime.parse(j['timestamp'] as String),
    leido: j['leido'] as bool? ?? false,
  );
}
