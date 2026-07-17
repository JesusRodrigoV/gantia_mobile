import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../services/ws_client.dart';
import '../services/server_config_service.dart';
import '../config.dart';

final serverConfigProvider = Provider<ServerConfigService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: AppConfig.apiUrl);
});

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthService(api);
});

final wsClientProvider = Provider<WsClient>((ref) {
  final auth = ref.watch(authServiceProvider);
  final config = ref.watch(serverConfigProvider);
  final client = WsClient(auth, wsUrl: config.wsUrl);
  ref.onDispose(() => client.dispose());
  return client;
});
