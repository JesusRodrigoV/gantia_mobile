import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/ws_service.dart';
import 'services/bt_service.dart';
import 'services/theme_service.dart';
import 'services/smart_home_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  throw UnimplementedError('Override in main');
});

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  throw UnimplementedError('Override in main');
});

final wsServiceProvider = ChangeNotifierProvider<WsService>((ref) {
  throw UnimplementedError('Override in main');
});

final btServiceProvider = ChangeNotifierProvider<BtService>((ref) {
  throw UnimplementedError('Override in main');
});

final themeServiceProvider = ChangeNotifierProvider<ThemeService>((ref) {
  throw UnimplementedError('Override in main');
});

final smartHomeServiceProvider = ChangeNotifierProvider<SmartHomeService>((ref) {
  throw UnimplementedError('Override in main');
});
