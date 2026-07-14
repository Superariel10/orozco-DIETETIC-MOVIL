// lib/core/config/app_config.dart

import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get baseUrl {
    // Garantizamos que la URL base SIEMPRE termine en / para que Dio funcione correctamente
    String url = dotenv.env['API_BASE_URL'] ?? 'https://paz-dietetica.uaeftt-ute.site/api';
    if (!url.endsWith('/')) {
      url = '$url/';
    }
    return url;
  }

  static const String appName = 'Dietética App';
  static const double taxRate = 0.15;
}
