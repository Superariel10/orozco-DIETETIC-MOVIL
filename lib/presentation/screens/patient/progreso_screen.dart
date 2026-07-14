// lib/presentation/screens/patient/progreso_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../providers/patient_provider.dart';
import '../../../data/repository/patient_repository_impl.dart';
import '../../../data/repository/patient_repository_impl.dart';

class ProgresoScreen extends ConsumerStatefulWidget {
  final int? userId;
  final String? patientName;

  const ProgresoScreen({super.key, this.userId, this.patientName});

  @override
  ConsumerState<ProgresoScreen> createState() => _ProgresoScreenState();
}

class _ProgresoScreenState extends ConsumerState<ProgresoScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      await ref.read(patientRepositoryProvider).uploadProgresoFoto(image.path, "Registro de progreso");
      ref.invalidate(patientProgresosProvider);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('¡Foto guardada localmente!'), backgroundColor: AppColors.primary),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final evalsAsync = ref.watch(patientEvaluacionesProvider(widget.userId));
    final photosAsync = ref.watch(patientProgresosProvider);
    
    final user = ref.watch(authProvider).user;
    final isNutri = user?.isNutricionista ?? false;

    if (isNutri) {
      return Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        appBar: AppBar(
          title: Text(widget.patientName != null ? 'Métricas de ${widget.patientName}' : 'Métricas del Paciente', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0.5,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async => ref.invalidate(patientEvaluacionesProvider(widget.userId)),
          child: evalsAsync.when(
            data: (evals) => evals.isEmpty ? _buildEmpty('No hay métricas registradas.') : _buildProgressList(evals),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, __) => Center(child: Text('Error: $e')),
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        appBar: AppBar(
          title: const Text('Mi Seguimiento', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0.5,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                // REGRESO INTELIGENTE SEGÚN EL ROL REAL
                final userAuth = ref.read(authProvider).user;
                if (userAuth?.isAdmin == true) {
                  context.go('/admin');
                } else if (userAuth?.isNutricionista == true) {
                  context.go('/nutri');
                } else {
                  context.go('/patient');
                }
              }
            },
          ),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'Métricas', icon: Icon(Icons.analytics_rounded, size: 20)),
              Tab(text: 'Fotos', icon: Icon(Icons.camera_alt_rounded, size: 20)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // TAB 1: MÉTRICAS
            RefreshIndicator(
              onRefresh: () async => ref.invalidate(patientEvaluacionesProvider),
              child: evalsAsync.when(
                data: (evals) => evals.isEmpty ? _buildEmpty('No hay métricas aún.') : _buildProgressList(evals),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, __) => Center(child: Text('Error: $e')),
              ),
            ),
            // TAB 2: FOTOS
            RefreshIndicator(
              onRefresh: () async => ref.invalidate(patientProgresosProvider),
              child: photosAsync.when(
                data: (photos) => photos.isEmpty ? _buildEmpty('No hay fotos registradas.') : _buildPhotoGrid(photos),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, __) => Center(child: Text('Error: $e')),
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _takePhoto,
          backgroundColor: AppColors.primary,
          child: const Icon(Icons.add_a_photo_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildEmpty(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_rounded, size: 64, color: AppColors.textFaint),
          const SizedBox(height: 16),
          Text(message, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  Widget _buildProgressList(List<dynamic> evals) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: evals.length,
      itemBuilder: (context, index) {
        final ev = evals[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(ev['fecha'] ?? 'Fecha', style: const TextStyle(fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20),
                ],
              ),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _Stat(label: 'Peso', value: '${ev['peso']} kg'),
                  _Stat(label: 'Grasa', value: '${ev['grasa_corporal_porcentaje']}%'),
                  _Stat(label: 'Músculo', value: '${ev['masa_muscular_kg']} kg'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPhotoGrid(List<dynamic> photos) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final photo = photos[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(File(photo.localPath), fit: BoxFit.cover),
                Positioned(
                  bottom: 0, left: 0, right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter, end: Alignment.topCenter,
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                      ),
                    ),
                    child: Text(
                      photo.date,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value;
  const _Stat({required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
      ],
    );
  }
}
