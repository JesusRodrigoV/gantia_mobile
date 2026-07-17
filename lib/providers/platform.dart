import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/bt_service.dart';
import '../services/theme_service.dart';
import '../services/notification_service.dart';
import '../services/widget_service.dart';

final btServiceProvider = ChangeNotifierProvider<BtService>((ref) {
  final service = BtService();
  ref.onDispose(() => service.dispose());
  return service;
});

final themeServiceProvider = ChangeNotifierProvider<ThemeService>((ref) {
  return ThemeService();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});

final widgetServiceProvider = Provider<WidgetService>((ref) {
  throw UnimplementedError('Must be overridden in main.dart');
});
