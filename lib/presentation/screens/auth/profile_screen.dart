// lib/presentation/screens/auth/profile_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../../../core/config/app_config.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../providers/patient_provider.dart';
import '../../../data/remote/api/image_upload_service.dart';
import '../../../data/repository/admin_repository_impl.dart';
import '../../../data/repository/patient_repository_impl.dart';
import '../../../data/repository/patient_repository_impl.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _showImagePickerOptions(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Cambiar foto de perfil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _PickerOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Cámara',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(source: ImageSource.camera);
                    if (image != null) {
                      await _uploadAvatar(image.path, ref, context);
                    }
                  },
                ),
                _PickerOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Galería',
                  onTap: () async {
                    Navigator.pop(context);
                    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                    if (image != null) {
                      await _uploadAvatar(image.path, ref, context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadAvatar(String path, WidgetRef ref, BuildContext context) async {
    try {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Actualizando imagen...'), duration: Duration(seconds: 1)),
        );
      }

      final service = ImageUploadService();
      await service.uploadAvatar(file: File(path));
      
      // RECARGA GLOBAL DE IMAGENES
      ref.invalidate(profileProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto actualizada!'), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error));
      }
    }
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final user = ref.read(authProvider).user;
    final nameCtrl = TextEditingController(text: user?.username);
    final emailCtrl = TextEditingController(text: user?.email);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.w900)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: InputDecoration(labelText: 'Nuevo Usuario', filled: true, fillColor: AppColors.surface2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
            const SizedBox(height: 16),
            TextField(controller: emailCtrl, decoration: InputDecoration(labelText: 'Nuevo Email', filled: true, fillColor: AppColors.surface2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('CANCELAR')),
          ElevatedButton(
            onPressed: () async {
              final newName = nameCtrl.text.trim();
              final newEmail = emailCtrl.text.trim();
              if (newName.isEmpty) return;

              // 1. CERRAR DIALOGO
              Navigator.pop(ctx);

              try {
                // 2. GUARDAR EN EL SERVIDOR (Usando el repositorio de admin que ya tiene updateUser)
                await ref.read(adminRepositoryProvider).updateUser(user!.id, {
                  'username': newName,
                  'email': newEmail,
                });

                // 3. ACTUALIZACIÓN GLOBAL E INSTANTÁNEA
                ref.read(authProvider.notifier).updateLocalUser(newName, newEmail);
                ref.invalidate(profileProvider); // Refrescar datos de perfil

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado correctamente'), backgroundColor: AppColors.primary));
                }
              } catch (e) {
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
              }
            },
            child: const Text('GUARDAR'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final profileAsync = ref.watch(profileProvider);

    final primaryColor = user?.isAdmin == true 
      ? AppColors.adminPrimary 
      : user?.isNutricionista == true 
        ? AppColors.nutriPrimary 
        : AppColors.patientPrimary;

    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              height: 320,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, primaryColor.withOpacity(0.8)],
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    top: 60, left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Stack(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                            child: profileAsync.when(
                              data: (p) {
                                String? url = p.avatarUrl;
                                if (url != null && !url.startsWith('http')) {
                                  final base = Uri.parse(AppConfig.baseUrl);
                                  url = '${base.scheme}://${base.host}$url';
                                }
                                return CircleAvatar(
                                  radius: 60,
                                  backgroundColor: Colors.white,
                                  backgroundImage: (url != null && url.isNotEmpty)
                                      ? NetworkImage('$url?t=${DateTime.now().millisecondsSinceEpoch}')
                                      : null,
                                  child: (url == null || url.isEmpty)
                                      ? Text(user?.username[0].toUpperCase() ?? 'U', style: TextStyle(fontSize: 44, fontWeight: FontWeight.bold, color: primaryColor))
                                      : null,
                                );
                              },
                              loading: () => const CircleAvatar(radius: 60, child: CircularProgressIndicator()),
                              error: (_, __) => CircleAvatar(radius: 60, child: Text(user?.username[0].toUpperCase() ?? 'U', style: TextStyle(color: primaryColor, fontSize: 32, fontWeight: FontWeight.bold))),
                            ),
                          ),
                          Positioned(
                            bottom: 4, right: 4,
                            child: InkWell(
                              onTap: () => _showImagePickerOptions(context, ref),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                                child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(user?.username ?? 'Usuario', style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                      Text(user?.email ?? '', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _InfoSection(
                  title: 'DETALLES DE LA CUENTA',
                  primaryColor: primaryColor,
                  onEdit: () => _showEditDialog(context, ref), // BOTÓN PARA EDITAR
                  items: [
                    _InfoItem(label: 'Nombre de Usuario', value: user?.username ?? '—', icon: Icons.person_outline_rounded),
                    _InfoItem(label: 'Correo Electrónico', value: user?.email ?? '—', icon: Icons.email_outlined),
                  ],
                ),
                const SizedBox(height: 40),
                OutlinedButton.icon(
                  onPressed: () => _showLogoutDialog(context, ref),
                  icon: const Icon(Icons.logout_rounded, color: AppColors.error),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w900)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.error.withOpacity(0.5), width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
                const SizedBox(height: 60),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cerrar Sesión?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Tendrás que ingresar tus credenciales nuevamente.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCELAR')),
          TextButton(onPressed: () async {
            await ref.read(authProvider.notifier).logout();
            if (context.mounted) context.go('/login');
          }, child: const Text('CERRAR SESIÓN', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<_InfoItem> items;
  final Color primaryColor;
  final VoidCallback onEdit;

  const _InfoSection({required this.title, required this.items, required this.primaryColor, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.textFaint, fontSize: 11, letterSpacing: 1.2)),
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit_rounded, color: AppColors.accent, size: 18)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28), border: Border.all(color: AppColors.borderLight, width: 1.5)),
          child: Column(
            children: items.asMap().entries.map((e) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: primaryColor.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Icon(e.value.icon, color: primaryColor, size: 20)),
                        const SizedBox(width: 16),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.value.label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600)), Text(e.value.value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15))])),
                      ],
                    ),
                  ),
                  if (e.key < items.length - 1) Divider(height: 1, indent: 68, color: AppColors.borderLight.withOpacity(0.5)),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _InfoItem {
  final String label, value;
  final IconData icon;
  const _InfoItem({required this.label, required this.value, required this.icon});
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickerOption({required this.icon, required this.label, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(padding: const EdgeInsets.all(20), width: 130, decoration: BoxDecoration(color: AppColors.secondaryBackground, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight)), child: Column(children: [Icon(icon, size: 36, color: AppColors.primary), const SizedBox(height: 12), Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14))])),
    );
  }
}
