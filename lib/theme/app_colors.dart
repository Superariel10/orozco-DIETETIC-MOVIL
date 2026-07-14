// lib/theme/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- PALETA OFICIAL DIETETIC ---
  static const Color primary      = Color(0xFF4CAF50); // Verde #4CAF50
  static const Color primaryDark  = Color(0xFF2E7D32); // Verde oscuro #2E7D32
  static const Color accent       = Color(0xFF2196F3); // Azul para botones #2196F3
  static const Color success      = Color(0xFF43A047); // Verde éxito #43A047
  static const Color warning      = Color(0xFFFF9800); // Naranja advertencia #FF9800
  static const Color error        = Color(0xFFE53935); // Rojo error #E53935
  static const Color info         = Color(0xFF2196F3); // Azul info
  
  static const Color background   = Color(0xFFFFFFFF); // Fondo Blanco
  static const Color surface2     = Color(0xFFF8FAFC); // Fondo secundario #F8FAFC
  static const Color secondaryBackground = Color(0xFFF8FAFC); // Alias
  
  static const Color textPrimary   = Color(0xFF212121); // Texto principal #212121
  static const Color textSecondary = Color(0xFF757575); // Texto secundario #757575
  static const Color textFaint     = Color(0xFFBDBDBD);

  static const Color surface      = Colors.white;
  static const Color border       = Color(0xFFE2E8F0);
  static const Color borderLight  = Color(0xFFF1F5F9);

  // Alias para compatibilidad
  static const Color onAccent     = Colors.white;
  static const Color secondary    = Color(0xFF2E7D32);
  
  static const Color patientPrimary    = Color(0xFF4CAF50);
  static const Color patientPrimaryDark = Color(0xFF2E7D32);
  static const Color patientAccent     = Color(0xFF2196F3);
  static const Color patientBackground = Color(0xFFF8FAFC);

  static const Color adminPrimary   = Color(0xFF2E7D32); 
  static const Color adminAppBar    = Color(0xFF4CAF50); 
  static const Color adminAlert     = Color(0xFFFF9800);

  static const Color nutriPrimary      = Color(0xFF2E7D32);
  static const Color nutriBackground   = Color(0xFFF8FAFC);
  static const Color nutriDetail       = Color(0xFF2196F3);

  AppColors._();
}
