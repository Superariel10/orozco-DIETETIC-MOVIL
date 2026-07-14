// lib/presentation/screens/patient/chat_logros_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_colors.dart';
import '../../providers/admin_provider.dart';
import '../../../domain/model/nutricionista.dart';
import '../../providers/chat_state.dart';
import '../../providers/auth_provider.dart';

class ChatLogrosScreen extends ConsumerStatefulWidget {
  const ChatLogrosScreen({super.key});
  @override
  ConsumerState<ChatLogrosScreen> createState() => _ChatLogrosScreenState();
}

class _ChatLogrosScreenState extends ConsumerState<ChatLogrosScreen> {
  dynamic _selectedPerson; // Puede ser Nutricionista o Paciente

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isNutri = user?.isNutricionista ?? false;

    if (_selectedPerson != null) {
      return _ChatWindow(
        person: _selectedPerson, 
        isNutriView: isNutri,
        onBack: () => setState(() => _selectedPerson = null)
      );
    }

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(isNutri ? 'Mis Mensajes' : 'Mi Especialista', style: const TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: isNutri ? _buildNutriInbox() : _buildPatientDirectory(),
    );
  }

  Widget _buildNutriInbox() {
    // 1. VISTA PARA NUTRICIONISTA: Bandeja de entrada de SUS pacientes
    // Consume: mensaje_chats (Tabla #14) y pacientes (Tabla #1)
    final messagesAsync = ref.watch(globalChatProvider);
    final currentUser = ref.read(authProvider).user;

    return messagesAsync.when(
      data: (messages) {
        // Obtenemos IDs únicos de pacientes que han escrito a este Nutri
        final patientIds = messages
            .where((m) => m.destinatarioId == currentUser?.id)
            .map((m) => m.remitenteId)
            .toSet()
            .toList();

        if (patientIds.isEmpty) {
          return const Center(child: Text('No tienes mensajes de pacientes aún.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(24),
          itemCount: patientIds.length,
          itemBuilder: (context, index) {
            final pId = patientIds[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text('Paciente #$pId'), // Aquí se cargaría el nombre de la tabla pacientes
                subtitle: const Text('Toca para responder'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => setState(() => _selectedPerson = {'id': pId, 'name': 'Paciente #$pId'}),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) {
        final errorMsg = e.toString();
        if (errorMsg.contains('autenticación') || errorMsg.contains('401')) {
          return const _ChatAuthErrorState();
        }
        return Center(child: Text('Error: $e'));
      },
    );
  }

  Widget _buildPatientDirectory() {
    // 2. VISTA PARA PACIENTE: Directorio de especialistas para contactar
    final nutriAsync = ref.watch(adminNutricionistasProvider);

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(adminNutricionistasProvider),
      child: nutriAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, __) => Center(child: Text('Error: $e')),
        data: (nutris) {
          return ListView(
            padding: const EdgeInsets.all(24),
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              const Text('DIRECTORIO DE ESPECIALISTAS', 
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textFaint, letterSpacing: 1.2)),
              const SizedBox(height: 20),
              ...nutris.map((nutri) => Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    radius: 28,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person_rounded, color: AppColors.primary, size: 30),
                  ),
                  title: Text('Dra. ${nutri.fullName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(nutri.specialty, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.chat_bubble_rounded, color: Colors.white, size: 20),
                    onPressed: () => setState(() => _selectedPerson = nutri),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.primary, 
                      padding: const EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              )),
            ],
          );
        },
      ),
    );
  }
}

class _ChatWindow extends ConsumerStatefulWidget {
  final dynamic person;
  final bool isNutriView;
  final VoidCallback onBack;
  const _ChatWindow({required this.person, required this.isNutriView, required this.onBack});

  @override
  ConsumerState<_ChatWindow> createState() => _ChatWindowState();
}

class _ChatWindowState extends ConsumerState<_ChatWindow> {
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
    
    // Obtener ID del destinatario dinámicamente
    final int targetId = widget.isNutriView 
        ? widget.person['id'] 
        : (widget.person as Nutricionista).userId ?? 0;
    
    final String targetName = widget.isNutriView 
        ? widget.person['name'] 
        : (widget.person as Nutricionista).fullName;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18), onPressed: widget.onBack),
        title: Text(targetName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0.5,
      ),
      body: Column(
        children: [
          Expanded(
            child: messagesAsync.when(
              data: (messages) {
                final filteredMessages = messages.where((m) => 
                  (m.remitenteId == currentUser?.id && m.destinatarioId == targetId) ||
                  (m.remitenteId == targetId && m.destinatarioId == currentUser?.id)
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
                          color: isMe ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(16),
                            topRight: const Radius.circular(16),
                            bottomLeft: Radius.circular(isMe ? 16 : 0),
                            bottomRight: Radius.circular(isMe ? 0 : 16),
                          ),
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
                      hintText: 'Escribe un mensaje...',
                      filled: true,
                      fillColor: AppColors.surface2,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                    ),
                    onSubmitted: (_) => _send(targetId),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => _send(targetId),
                  icon: const Icon(Icons.send_rounded, color: AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send(int targetId) {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(globalChatProvider.notifier).sendMessage(targetId, _messageController.text);
    _messageController.clear();
    _scrollToBottom();
  }
}

class _ChatAuthErrorState extends StatelessWidget {
  const _ChatAuthErrorState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_rounded, color: AppColors.error, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Modo de Prueba Activo',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'El chat requiere una conexión segura con el servidor. Para usarlo, por favor crea una cuenta real en el Registro.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
