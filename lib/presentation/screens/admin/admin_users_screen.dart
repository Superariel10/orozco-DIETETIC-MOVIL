// lib/presentation/screens/admin/admin_users_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../../domain/model/user.dart';
import '../../../data/repository/admin_repository_impl.dart';
import '../../../theme/app_colors.dart';
import '../../widgets/shared/search_filter_bar.dart';
import '../../widgets/shared/empty_state.dart';
import 'admin_chat_screen.dart';

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usersAsync = ref.watch(adminUsersProvider);
    final searchQuery = ref.watch(userSearchQueryProvider); // Escuchamos el buscador

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final isAdmin = user?.isAdmin ?? false;
    final isNutri = user?.isNutricionista ?? false;

    final String currentRoute = GoRouterState.of(context).matchedLocation;
    final bool isPatientTab = currentRoute.contains('pacientes');

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      appBar: AppBar(
        title: Text(isPatientTab ? 'PACIENTES' : 'USUARIOS',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: () async {
          ref.invalidate(adminUsersProvider);
          if (isNutri) ref.invalidate(adminOrdersProvider);
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: SearchFilterBar(
                hintText: isPatientTab ? 'Buscar pacientes...' : 'Buscar usuario o email...',
                onSearch: (value) {
                  // Actualizamos el estado de búsqueda en tiempo real
                  ref.read(userSearchQueryProvider.notifier).state = value;
                },
              ),
            ),
            Expanded(
              child: usersAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => _buildEmptyState(isPatientTab, 'Error al conectar con el servidor'),
                data: (allUsers) {
                  // 1. FILTRADO POR ROL (Paciente vs Usuarios)
                  List<User> filteredList;
                  if (isPatientTab) {
                    filteredList = allUsers.where((u) => u.role == 'paciente').toList();
                  } else if (isNutri) {
                    final consultas = ref.watch(adminOrdersProvider).value ?? [];
                    final myPatientUserIds = consultas.map((c) => c.pacienteUserId).toSet();
                    filteredList = allUsers.where((u) =>
                      u.role == 'paciente' && myPatientUserIds.contains(u.id)
                    ).toList();
                  } else {
                    filteredList = allUsers;
                  }

                  // 2. FILTRADO POR BUSCADOR (Nombre o Email)
                  if (searchQuery.isNotEmpty) {
                    final query = searchQuery.toLowerCase();
                    filteredList = filteredList.where((u) =>
                      u.username.toLowerCase().contains(query) ||
                      u.email.toLowerCase().contains(query)
                    ).toList();
                  }

                  if (filteredList.isEmpty) {
                    return _buildEmptyState(isPatientTab, searchQuery.isNotEmpty ? 'No se encontraron resultados para "$searchQuery"' : 'No hay registros aún.');
                  }

                  return _buildUserList(filteredList, context, ref);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin ? FloatingActionButton(
        onPressed: () => _showUserDialog(context, ref),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ) : null,
    );
  }

  Widget _buildEmptyState(bool forPatients, String subtitle) {
     return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: EmptyState(
        icon: Icons.person_off_rounded,
        title: forPatients ? 'Sin pacientes' : 'Sin usuarios',
        subtitle: subtitle,
      ),
    );
  }

  Widget _buildUserList(List<User> users, BuildContext context, WidgetRef ref) {
    final userAuth = ref.read(authProvider).user;
    final isUserAdmin = userAuth?.isAdmin ?? false;
    final isUserNutri = userAuth?.isNutricionista ?? false;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: users.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final user = users[index];
        final roleColor = user.role == 'admin' ? Colors.red : user.role == 'nutricionista' ? Colors.blue : Colors.green;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 8))],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: roleColor.withOpacity(0.1),
                    child: Text(user.username[0].toUpperCase(), style: TextStyle(color: roleColor, fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.username, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: AppColors.textPrimary)),
                        Text(user.email, style: const TextStyle(color: AppColors.textSecondary, fontSize: 11), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: roleColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: Text(user.role.toUpperCase(), style: TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: roleColor)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (user.role == 'paciente')
                    Expanded(child: _SmallActionBtn(icon: Icons.chat_rounded, label: 'Chat', color: AppColors.accent, onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => AdminChatScreen(patientName: user.username, patientId: user.id))))),
                  if (user.role == 'paciente') const SizedBox(width: 8),
                  if (user.role == 'paciente')
                    Expanded(child: _SmallActionBtn(
                      icon: Icons.analytics_rounded, 
                      label: 'Progreso', 
                      color: Colors.orange, 
                      onTap: () => context.push('/nutri/seguimiento', extra: {'userId': user.id, 'patientName': user.username})
                    )),
                  if (isUserAdmin) const SizedBox(width: 8),
                  if (isUserAdmin)
                    Expanded(child: _SmallActionBtn(icon: Icons.edit_rounded, label: 'Editar', color: AppColors.primary, onTap: () => _showUserDialog(context, ref, user))),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showUserDialog(BuildContext context, WidgetRef ref, [User? user]) {
    final nameCtrl = TextEditingController(text: user?.username);
    final emailCtrl = TextEditingController(text: user?.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: Text(user == null ? 'Nuevo Usuario' : 'Editar Usuario', style: const TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Usuario', filled: true, fillColor: AppColors.surface2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
             const SizedBox(height: 16),
             TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Email', filled: true, fillColor: AppColors.surface2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        actions: [
          if (user != null)
            TextButton.icon(
              onPressed: () {
                Navigator.pop(ctx);
                _confirmDeleteUser(context, ref, user);
              },
              icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
              label: const Text('ELIMINAR', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            ),
          const Spacer(),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR', style: TextStyle(fontWeight: FontWeight.bold))),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (user != null) {
                try {
                  await ref.read(adminRepositoryProvider).updateUser(user.id, {
                    'username': nameCtrl.text,
                    'email': emailCtrl.text,
                  });
                  ref.invalidate(adminUsersProvider);
                  final currentUser = ref.read(authProvider).user;
                  if (currentUser?.id == user.id) {
                    ref.read(authProvider.notifier).updateLocalUser(nameCtrl.text, emailCtrl.text);
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuario actualizado'), backgroundColor: AppColors.primary));
                  }
                } catch (e) {
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              }
            },
            child: const Text('GUARDAR')
          ),
        ],
      ),
    );
  }

  void _confirmDeleteUser(BuildContext context, WidgetRef ref, User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Eliminar Usuario', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Text('¿Deseas eliminar a "${user.username}" permanentemente?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ref.read(adminRepositoryProvider).deleteFromTable('users', user.id);
                ref.invalidate(adminUsersProvider);
                ref.invalidate(adminProductsProvider);
                ref.invalidate(adminNutricionistasProvider);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Eliminado correctamente'), backgroundColor: AppColors.error));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  List<User> _getMockUsers() => [];
}

class _SmallActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _SmallActionBtn({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 14),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w900)),
            ],
          ),
        ),
      ),
    );
  }
}
