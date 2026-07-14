// lib/presentation/widgets/shared/custom_app_bar.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../core/config/app_config.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showDrawer;

  const CustomAppBar({super.key, required this.title, this.showDrawer = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final profileAsync = ref.watch(profileProvider);

    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_rounded, color: AppColors.primary, size: 22),
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.health_and_safety_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w900,
                fontSize: 18,
                letterSpacing: -0.8
              ),
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textSecondary, size: 26),
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const _NotificationsBottomSheet(),
                );
              },
            ),
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w900)
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 4),

        // Avatar circular que abre perfil
        GestureDetector(
          onTap: () => context.push('/profile'),
          child: Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary.withOpacity(0.2), width: 2),
              ),
              child: profileAsync.when(
                data: (p) {
                  String? url = p.avatarUrl;
                  if (url != null && !url.startsWith('http')) {
                    final base = Uri.parse(AppConfig.baseUrl);
                    url = '${base.scheme}://${base.host}$url';
                  }
                  return CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    backgroundImage: (url != null && url.isNotEmpty)
                      ? NetworkImage('$url?t=${DateTime.now().millisecondsSinceEpoch}')
                      : null,
                    child: (url == null || url.isEmpty)
                      ? Text(
                          user?.username[0].toUpperCase() ?? 'U',
                          style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 14),
                        )
                      : null,
                  );
                },
                loading: () => const CircleAvatar(radius: 16, child: SizedBox(width: 10, height: 10, child: CircularProgressIndicator(strokeWidth: 2))),
                error: (_, __) => CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(user?.username[0].toUpperCase() ?? 'U', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _NotificationsBottomSheet extends StatelessWidget {
  const _NotificationsBottomSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: AppColors.secondaryBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Notificaciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 3,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final notifications = [
                  {
                    'title': '¡Hora de beber agua!',
                    'desc': 'No olvides mantenerte hidratado. Tu meta de hoy es 2.5L.',
                    'time': '5 min',
                    'icon': Icons.water_drop_rounded,
                    'color': Colors.blue,
                  },
                  {
                    'title': 'Nuevo Plan Asignado',
                    'desc': 'La Dra. Maria Cosio ha actualizado tu plan nutricional.',
                    'time': '2 h',
                    'icon': Icons.restaurant_menu_rounded,
                    'color': AppColors.primary,
                  },
                  {
                    'title': 'Recordatorio de Cita',
                    'desc': 'Mañana tienes una cita a las 10:00 AM.',
                    'time': '5 h',
                    'icon': Icons.event_available_rounded,
                    'color': Colors.orange,
                  },
                ];

                final item = notifications[index];

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderLight, width: 1.5),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: (item['color'] as Color).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(item['icon'] as IconData, color: item['color'] as Color, size: 22),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          item['time'] as String,
                          style: const TextStyle(fontSize: 10, color: AppColors.textFaint, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        item['desc'] as String,
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.3),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
