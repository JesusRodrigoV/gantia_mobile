import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/action_message.dart';
import 'glove_state.dart';
import 'action_log.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  StreamSubscription<GestureDetectedEvent?>? _gestureSub;
  StreamSubscription<ConnectionStatus>? _connectionSub;
  StreamSubscription<ActionEvent?>? _actionSub;
  bool _disposed = false;

  String? _initError;
  bool _initDone = false;

  String? get initError => _initError;
  bool get isOperational => _initDone && _initError == null;

  static const String _gestureChannelId = 'gantia_gestures';
  static const String _gestureChannelName = 'Gestos detectados';
  static const String _connectionChannelId = 'gantia_connection';
  static const String _connectionChannelName = 'Estado de conexión';
  static const String _actionsChannelId = 'gantia_actions';
  static const String _actionsChannelName = 'Acciones ejecutadas';

  static const _notificationIdGesture = 1000;
  static const _notificationIdConnection = 1001;
  static const _notificationIdAction = 1002;

  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    try {
      await _plugin.initialize(settings);
    } catch (e) {
      _initError = 'Error al inicializar notificaciones: $e';
      debugPrint('[NotificationService] init error: $e');
      return;
    }

    try {
      final androidChannels = [
        AndroidNotificationChannel(
          _gestureChannelId,
          _gestureChannelName,
          description: 'Notificaciones cuando se detecta un gesto',
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
        AndroidNotificationChannel(
          _connectionChannelId,
          _connectionChannelName,
          description: 'Notificaciones cuando cambia el estado de conexión del guante',
          importance: Importance.defaultImportance,
          playSound: true,
        ),
        AndroidNotificationChannel(
          _actionsChannelId,
          _actionsChannelName,
          description: 'Notificaciones de acciones ejecutadas importantes',
          importance: Importance.low,
        ),
      ];

      for (final channel in androidChannels) {
        await _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
      }

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _plugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
    } catch (e) {
      _initError = 'Error al configurar canales de notificación: $e';
      debugPrint('[NotificationService] channel setup error: $e');
    } finally {
      _initDone = true;
    }
  }

  void listenTo(
    GloveState gloveState,
    ActionLog actionLog, {
    bool notifyGestures = true,
    bool notifyConnections = true,
    bool notifyActions = false,
  }) {
    if (_disposed) return;
    try {
      _gestureSub?.cancel();
      _connectionSub?.cancel();
      _actionSub?.cancel();

      if (notifyGestures) {
        _gestureSub = gloveState.gestureDetectedStream.listen(_onGestureDetected);
      }
      if (notifyConnections) {
        _connectionSub = gloveState.connectionStatusStream.listen(_onConnectionChanged);
      }
      if (notifyActions) {
        _actionSub = actionLog.actionEventStream.listen(_onActionExecuted);
      }
    } catch (e) {
      debugPrint('[NotificationService] listenTo error: $e');
    }
  }

  void _onGestureDetected(GestureDetectedEvent? event) {
    if (_disposed || event == null) return;
    final actionLabel = getActionLabel(event.action);
    _showNotificationSafe(
      _notificationIdGesture,
      _gestureChannelId,
      'Gesto: ${event.gesture}',
      'Acción: $actionLabel',
    );
  }

  void _onConnectionChanged(ConnectionStatus status) {
    if (_disposed) return;
    switch (status) {
      case ConnectionStatus.disconnected:
        _showNotificationSafe(
          _notificationIdConnection,
          _connectionChannelId,
          'Guante desconectado',
          'Se perdió la conexión con el servidor',
        );
      case ConnectionStatus.connected:
        _showNotificationSafe(
          _notificationIdConnection,
          _connectionChannelId,
          'Guante conectado',
          'El guante está recibiendo datos',
        );
      case ConnectionStatus.reconnecting:
        _showNotificationSafe(
          _notificationIdConnection,
          _connectionChannelId,
          'Reconectando...',
          'Intentando restablecer la conexión',
        );
      default:
        break;
    }
  }

  void _onActionExecuted(ActionEvent? event) {
    if (_disposed || event == null) return;
    final actionLabel = getActionLabel(event.action);
    final value = event.actionValue?.toString() ?? '';
    final body = value.isNotEmpty ? '$actionLabel: $value' : actionLabel;
    _showNotificationSafe(
      _notificationIdAction,
      _actionsChannelId,
      'Acción ejecutada',
      body,
    );
  }

  void _showNotificationSafe(int id, String channelId, String title, String body) {
    if (_disposed) return;
    try {
      _plugin.show(
        id,
        title,
        body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            channelId == _gestureChannelId
                ? _gestureChannelName
                : channelId == _connectionChannelId
                    ? _connectionChannelName
                    : _actionsChannelName,
            channelDescription: null,
            importance: channelId == _gestureChannelId
                ? Importance.high
                : channelId == _connectionChannelId
                    ? Importance.defaultImportance
                    : Importance.low,
            priority: channelId == _gestureChannelId
                ? Priority.high
                : Priority.defaultPriority,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint('[NotificationService] show error: $e');
    }
  }

  void dispose() {
    _disposed = true;
    try {
      _gestureSub?.cancel();
    } catch (_) {}
    try {
      _connectionSub?.cancel();
    } catch (_) {}
    try {
      _actionSub?.cancel();
    } catch (_) {}
    try {
      _plugin.cancelAll();
    } catch (_) {}
  }
}
