import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  AppConfig._();

  static String get backendHost =>
      dotenv.env['BACKEND_HOST'] ?? '192.168.1.100';
  static int get backendPort =>
      int.tryParse(dotenv.env['BACKEND_PORT'] ?? '') ?? 8000;

  static String get apiUrl => 'http://$backendHost:$backendPort';
  static String get wsUrl => 'ws://$backendHost:$backendPort';
}
