import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/action_message.dart';
import 'glove_state.dart';
import 'action_log.dart';

typedef _ChannelConfig = ({String name, Importance importance, Priority priority});

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin;
  StreamSubscription<ActionEvent?>? _actionSub;
  GloveState? _gloveState;
  bool _disposed = false;

  ConnectionStatus? _lastConnection;
  GestureDetectedEvent? _lastGesture;

  String? _initError;
  bool _initDone = false;

  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  String? get initError => _initError;
  bool get isOperational => _initDone && _initError == null;

  static const String _gestureChannelId = 'gantia_gestures';
  static const String _connectionChannelId = 'gantia_connection';
  static const String _actionsChannelId = 'gantia_actions';

  static const String _gestureChannelName = 'Gestos detectados';
  static const String _connectionChannelName = 'Estado de conexión';
  static const String _actionsChannelName = 'Acciones ejecutadas';

  static const _notificationIdGesture = 1000;
  static const _notificationIdConnection = 1001;
  static const _notificationIdAction = 1002;

  static final Map<String, _ChannelConfig> _channels = {
    _gestureChannelId: (
      name: _gestureChannelName,
      importance: Importance.high,
      priority: Priority.high,
    ),
    _connectionChannelId: (
      name: _connectionChannelName,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    ),
    _actionsChannelId: (
      name: _actionsChannelName,
      importance: Importance.low,
      priority: Priority.low,
    ),
  };

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
    _actionSub?.cancel();
    _gloveState?.removeListener(_onGloveStateChanged);

    _gloveState = gloveState;
    _lastConnection = gloveState.connectionStatus;
    _lastGesture = gloveState.gestureDetected;

    if (notifyGestures || notifyConnections) {
      gloveState.addListener(_onGloveStateChanged);
    }
    if (notifyActions) {
      _actionSub = actionLog.actionEventStream.listen(_onActionExecuted);
    }
  }

  void stopListening() {
    _gloveState?.removeListener(_onGloveStateChanged);
    _gloveState = null;
    _actionSub?.cancel();
    _actionSub = null;
  }

  void _onGloveStateChanged() {
    if (_disposed || _gloveState == null) return;

    if (_gloveState!.connectionStatus != _lastConnection) {
      _lastConnection = _gloveState!.connectionStatus;
      _onConnectionChanged(_lastConnection!);
    }

    if (_gloveState!.gestureDetected != _lastGesture) {
      _lastGesture = _gloveState!.gestureDetected;
      _onGestureDetected(_lastGesture);
    }
  }

  void _onGestureDetected(GestureDetectedEvent? event) {
    if (_disposed || event == null) return;
    final actionLabel = getActionLabel(event.action);
    showNotificationSafe(
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
        showNotificationSafe(
          _notificationIdConnection,
          _connectionChannelId,
          'Guante desconectado',
          'Se perdió la conexión con el servidor',
        );
        break;
      case ConnectionStatus.connected:
        showNotificationSafe(
          _notificationIdConnection,
          _connectionChannelId,
          'Guante conectado',
          'El guante está recibiendo datos',
        );
        break;
      case ConnectionStatus.reconnecting:
        showNotificationSafe(
          _notificationIdConnection,
          _connectionChannelId,
          'Reconectando...',
          'Intentando restablecer la conexión',
        );
        break;
      default:
        break;
    }
  }

  void _onActionExecuted(ActionEvent? event) {
    if (_disposed || event == null) return;
    final actionLabel = getActionLabel(event.action);
    final value = event.actionValue?.toString() ?? '';
    final body = value.isNotEmpty ? '$actionLabel: $value' : actionLabel;
    showNotificationSafe(
      _notificationIdAction,
      _actionsChannelId,
      'Acción ejecutada',
      body,
    );
  }

  void showNotificationSafe(int id, String channelId, String title, String body) {
    if (_disposed) return;
    final cfg = _channels[channelId] ?? _channels[_actionsChannelId]!;
    try {
      _plugin
          .show(
            id,
            title,
            body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channelId,
                cfg.name,
                channelDescription: null,
                importance: cfg.importance,
                priority: cfg.priority,
              ),
              iOS: const DarwinNotificationDetails(
                presentAlert: true,
                presentBadge: true,
                presentSound: true,
              ),
            ),
          )
          .catchError((Object e) {
            debugPrint('[NotificationService] show error: $e');
          });
    } catch (e) {
      debugPrint('[NotificationService] show error: $e');
    }
  }

  void dispose() {
    _disposed = true;
    stopListening();
    try {
      _plugin.cancelAll().catchError((Object e) {
        debugPrint('[NotificationService] cancelAll error: $e');
      });
    } catch (_) {}
  }
}
