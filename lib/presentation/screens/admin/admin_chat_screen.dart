// lib/presentation/screens/admin/admin_chat_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/chat_state.dart';
import '../../providers/auth_provider.dart';

class AdminChatScreen extends ConsumerStatefulWidget {
  final String patientName;
  final int patientId;
  const AdminChatScreen({super.key, required this.patientName, required this.patientId});

  @override
  ConsumerState<AdminChatScreen> createState() => _AdminChatScreenState();
}

class _AdminChatScreenState extends ConsumerState<AdminChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final messagesAsync = ref.watch(globalChatProvider);
    final currentUser = ref.watch(authProvider).user;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.adminPrimary.withValues(alpha: 0.1),
              child: const Icon(Icons.person, size: 20, color: AppColors.adminPrimary),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.patientName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const Text('Paciente Activo', style: TextStyle(fontSize: 10, color: AppColors.success)),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                // Filtramos mensajes entre este nutri/admin y este paciente
                final filteredMessages = messages.where((m) => 
                  (m.remitenteId == currentUser?.id && m.destinatarioId == widget.patientId) ||
                  (m.remitenteId == widget.patientId && m.destinatarioId == currentUser?.id)
                ).toList();

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(20),
                  itemCount: filteredMessages.length,
                  itemBuilder: (context, index) {
                    final msg = filteredMessages[index];
                    final isMe = msg.remitenteId == currentUser?.id;

                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? AppColors.adminPrimary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 2))],
                        ),
                        child: Text(
                          msg.contenido,
                          style: TextStyle(color: isMe ? Colors.white : AppColors.textPrimary, fontSize: 14),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, __) => Center(child: Text('Error: $e')),
            ),
          ),
          
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.borderLight))),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Responder al paciente...',
                      filled: true,
                      fillColor: AppColors.surface2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _send,
                  icon: const Icon(Icons.send_rounded, color: AppColors.adminPrimary),
                  style: IconButton.styleFrom(backgroundColor: AppColors.adminPrimary.withValues(alpha: 0.1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send() {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(globalChatProvider.notifier).sendMessage(widget.patientId, _messageController.text);
    _messageController.clear();
    _scrollToBottom();
  }
}
