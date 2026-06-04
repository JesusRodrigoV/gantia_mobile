import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'providers.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/ws_service.dart';
import 'services/bt_service.dart';
import 'services/theme_service.dart';
import 'services/smart_home_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final apiService = ApiService();
  final authService = await AuthService.init(apiService);
  final themeService = await ThemeService.init();
  final wsService = WsService(authService);
  final btService = BtService();
  final smartHomeService = SmartHomeService();

  runApp(
    ProviderScope(
      overrides: [
        apiServiceProvider.overrideWith((_) => apiService),
        authServiceProvider.overrideWith((_) => authService),
        themeServiceProvider.overrideWith((_) => themeService),
        wsServiceProvider.overrideWith((_) => wsService),
        btServiceProvider.overrideWith((_) => btService),
        smartHomeServiceProvider.overrideWith((_) => smartHomeService),
      ],
      child: const GantiaApp(),
    ),
  );
}
