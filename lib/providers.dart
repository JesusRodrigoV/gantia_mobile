import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/ws_client.dart';
import 'services/glove_state.dart';
import 'services/action_log.dart';
import 'services/bt_service.dart';
import 'services/theme_service.dart';
import 'services/smart_home_service.dart';
import 'config.dart';

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: AppConfig.apiUrl);
});

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  throw UnimplementedError('Override in main — async init');
});

final themeServiceProvider = ChangeNotifierProvider<ThemeService>((ref) {
  throw UnimplementedError('Override in main — async init');
});

final wsClientProvider = Provider<WsClient>((ref) {
  final auth = ref.watch(authServiceProvider);
  final client = WsClient(auth, wsUrl: AppConfig.wsUrl);
  ref.onDispose(() => client.dispose());
  return client;
});

final gloveStateProvider = ChangeNotifierProvider<GloveState>((ref) {
  final client = ref.watch(wsClientProvider);
  return GloveState(client);
});

final actionLogProvider = ChangeNotifierProvider<ActionLog>((ref) {
  final client = ref.watch(wsClientProvider);
  return ActionLog(client);
});

final btServiceProvider = ChangeNotifierProvider<BtService>((ref) {
  return BtService();
});

final smartHomeServiceProvider = ChangeNotifierProvider<SmartHomeService>((ref) {
  return SmartHomeService();
});
