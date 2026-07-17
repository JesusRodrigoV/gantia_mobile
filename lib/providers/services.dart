import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/smart_home_service.dart';
import '../services/gesture_config_service.dart';
import '../services/calibration_service.dart';
import '../services/sensitivity_service.dart';
import '../services/mouse_config_service.dart';
import '../services/learning_service.dart';
import '../services/history_service.dart';
import '../services/target_service.dart';
import '../services/recording_service.dart';
import 'auth.dart';
import 'glove.dart';

final smartHomeServiceProvider = ChangeNotifierProvider.autoDispose<SmartHomeService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return SmartHomeService(api);
});

final gestureConfigServiceProvider = ChangeNotifierProvider.autoDispose<GestureConfigService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return GestureConfigService(api);
});

final calibrationServiceProvider = ChangeNotifierProvider.autoDispose<CalibrationService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return CalibrationService(api);
});

final sensitivityServiceProvider = ChangeNotifierProvider.autoDispose<SensitivityService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return SensitivityService(api);
});

final mouseConfigServiceProvider = ChangeNotifierProvider.autoDispose<MouseConfigService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return MouseConfigService(api);
});

final learningServiceProvider = ChangeNotifierProvider.autoDispose<LearningService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return LearningService(api);
});

final historyServiceProvider = ChangeNotifierProvider.autoDispose<HistoryService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return HistoryService(api);
});

final targetServiceProvider = ChangeNotifierProvider.autoDispose<TargetService>((ref) {
  final api = ref.watch(apiServiceProvider);
  return TargetService(api);
});

final recordingServiceProvider = ChangeNotifierProvider.autoDispose<RecordingService>((ref) {
  final client = ref.watch(wsClientProvider);
  return RecordingService(client);
});
