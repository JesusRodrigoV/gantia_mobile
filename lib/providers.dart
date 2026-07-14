import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/ws_client.dart';
import 'services/server_config_service.dart';
import 'services/glove_state.dart';
import 'services/action_log.dart';
import 'services/bt_service.dart';
import 'services/theme_service.dart';
import 'services/smart_home_service.dart';
import 'services/gesture_config_service.dart';
import 'services/calibration_service.dart';
import 'services/sensitivity_service.dart';
import 'services/mouse_config_service.dart';
import 'services/learning_service.dart';
import 'services/history_service.dart';
import 'services/target_service.dart';
import 'services/recording_service.dart';
import 'config.dart';

export 'services/api_service.dart';
export 'services/auth_service.dart';
export 'services/ws_client.dart';
export 'services/glove_state.dart';
export 'services/action_log.dart';
export 'services/bt_service.dart';
export 'services/theme_service.dart';
export 'services/smart_home_service.dart';
export 'services/gesture_config_service.dart';
export 'services/calibration_service.dart';
export 'services/sensitivity_service.dart';
export 'services/mouse_config_service.dart';
export 'services/learning_service.dart';
export 'services/history_service.dart';
export 'services/target_service.dart';
export 'services/recording_service.dart';

final serverConfigProvider = ChangeNotifierProvider<ServerConfigService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(baseUrl: AppConfig.apiUrl);
});

final authServiceProvider = ChangeNotifierProvider<AuthService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return AuthService(api);
});

final themeServiceProvider = ChangeNotifierProvider<ThemeService>((ref) {
  return ThemeService();
});

final wsClientProvider = Provider<WsClient>((ref) {
  final auth = ref.watch(authServiceProvider);
  final config = ref.watch(serverConfigProvider);
  final client = WsClient(auth, wsUrl: config.wsUrl);
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

final gestureConfigServiceProvider = ChangeNotifierProvider<GestureConfigService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return GestureConfigService(api);
});

final calibrationServiceProvider = ChangeNotifierProvider<CalibrationService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return CalibrationService(api);
});

final sensitivityServiceProvider = ChangeNotifierProvider<SensitivityService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return SensitivityService(api);
});

final mouseConfigServiceProvider = ChangeNotifierProvider<MouseConfigService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return MouseConfigService(api);
});

final learningServiceProvider = ChangeNotifierProvider<LearningService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return LearningService(api);
});

final historyServiceProvider = ChangeNotifierProvider<HistoryService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return HistoryService(api);
});

final targetServiceProvider = ChangeNotifierProvider<TargetService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return TargetService(api);
});

final recordingServiceProvider = ChangeNotifierProvider<RecordingService>((ref) {
  final client = ref.watch(wsClientProvider);
  return RecordingService(client);
});

// ── Navigation ──

final showRegisterProvider = StateProvider<bool>((ref) => false);

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);
