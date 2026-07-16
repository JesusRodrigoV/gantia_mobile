import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    debugPrint('[GLOBAL] FlutterError: ${details.exception}');
    debugPrint('[GLOBAL] Stack: ${details.stack}');
  };

  ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint('[GLOBAL] PlatformDispatcher error: $error');
    debugPrint('[GLOBAL] Stack: $stack');
    return true;
  };

  await dotenv.load();

  final serverConfig = await ServerConfigService.load();
  final apiService = ApiService(baseUrl: serverConfig.apiUrl);
  final authService = await AuthService.init(apiService);
  final themeService = await ThemeService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();
  if (notificationService.initError != null) {
    debugPrint('[MAIN] Notificaciones no disponibles: ${notificationService.initError}');
  }

  // Initialize home widget service
  final widgetService = WidgetService();
  await widgetService.init();

  runApp(
    ProviderScope(
      overrides: [
        serverConfigProvider.overrideWith((_) => serverConfig),
        apiServiceProvider.overrideWith((_) => apiService),
        authServiceProvider.overrideWith((_) => authService),
        themeServiceProvider.overrideWith((_) => themeService),
        notificationServiceProvider.overrideWith((_) => notificationService),
        widgetServiceProvider.overrideWith((_) => widgetService),
      ],
      child: const GantiaApp(),
    ),
  );
}
