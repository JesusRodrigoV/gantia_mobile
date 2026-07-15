import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final serverConfig = await ServerConfigService.load();
  final apiService = ApiService(baseUrl: serverConfig.apiUrl);
  final authService = await AuthService.init(apiService);
  final themeService = await ThemeService.init();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.init();

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
