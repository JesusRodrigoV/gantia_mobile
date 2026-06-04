import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
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
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider.value(value: wsService),
        ChangeNotifierProvider.value(value: btService),
        ChangeNotifierProvider.value(value: smartHomeService),
      ],
      child: const GantiaApp(),
    ),
  );
}
