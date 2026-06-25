import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart';
import 'config.dart';
import 'providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();

  final apiService = ApiService(baseUrl: AppConfig.apiUrl);
  final authService = await AuthService.init(apiService);
  final themeService = await ThemeService.init();

  runApp(
    ProviderScope(
      overrides: [
        apiServiceProvider.overrideWith((_) => apiService),
        authServiceProvider.overrideWith((_) => authService),
        themeServiceProvider.overrideWith((_) => themeService),
      ],
      child: const GantiaApp(),
    ),
  );
}
