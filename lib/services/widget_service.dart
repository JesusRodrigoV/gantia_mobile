import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/action_message.dart';
import 'glove_state.dart';
import 'action_log.dart';

class WidgetService {
  StreamSubscription<GestureDetectedEvent?>? _gestureSub;
  StreamSubscription<ConnectionStatus>? _connectionSub;
  StreamSubscription<ActionEvent?>? _actionSub;
  bool _disposed = false;

  static const String _widgetProviderName = 'GantiaWidgetProvider';

  Future<void> init() async {
    // Android does not need an app group ID
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Set an app group ID for iOS if needed for widget data sharing
    }
  }

  void listenTo(GloveState gloveState, ActionLog actionLog) {
    if (_disposed) return;
    try {
      _gestureSub?.cancel();
      _connectionSub?.cancel();
      _actionSub?.cancel();

      _gestureSub = gloveState.gestureDetectedStream.listen(_onEvent, onError: (e) => debugPrint('[WidgetService] gesture stream error: $e'));
      _connectionSub = gloveState.connectionStatusStream.listen(_onEvent, onError: (e) => debugPrint('[WidgetService] connection stream error: $e'));
      _actionSub = actionLog.actionEventStream.listen(_onEvent, onError: (e) => debugPrint('[WidgetService] action stream error: $e'));
      _updateFromState(gloveState, actionLog);
    } catch (e) {
      debugPrint('[WidgetService] listenTo error: $e');
    }
  }

  void _onEvent([_]) {
    if (_disposed) return;
    try {
      HomeWidget.updateWidget(
        name: _widgetProviderName,
        androidName: _widgetProviderName,
      );
    } catch (e) {
      debugPrint('[WidgetService] update error: $e');
    }
  }

  void _updateFromState(GloveState gloveState, ActionLog actionLog) {
    if (_disposed) return;
    try {
      final status = _statusLabel(gloveState);
      final isConnected = gloveState.connectionStatus == ConnectionStatus.connected;
      final isFlowing = gloveState.dataFlowing;
      final lastAction = actionLog.recentActions.isNotEmpty
          ? getActionLabel(actionLog.recentActions.first.action)
          : '—';
      final lastGesture = gloveState.gestureDetected?.gesture ?? '';
      final flexIndex = gloveState.telemetry?.flexIndex ?? 0;
      final flexMiddle = gloveState.telemetry?.flexMiddle ?? 0;

      HomeWidget.saveWidgetData<String>('status', status);
      HomeWidget.saveWidgetData<String>('isConnected', isConnected.toString());
      HomeWidget.saveWidgetData<String>('isFlowing', isFlowing.toString());
      HomeWidget.saveWidgetData<String>('lastAction', lastAction);
      HomeWidget.saveWidgetData<String>('lastGesture', lastGesture);
      HomeWidget.saveWidgetData<String>('flexIndex', flexIndex.toString());
      HomeWidget.saveWidgetData<String>('flexMiddle', flexMiddle.toString());
      HomeWidget.updateWidget(
        name: _widgetProviderName,
        androidName: _widgetProviderName,
      );
    } catch (e) {
      debugPrint('[WidgetService] save/update error: $e');
    }
  }

  String _statusLabel(GloveState gloveState) {
    switch (gloveState.connectionStatus) {
      case ConnectionStatus.connected:
        if (gloveState.dataFlowing) return 'Activo';
        if (gloveState.waitingForDevice) return 'Esperando guante';
        return 'Conectado';
      case ConnectionStatus.connecting:
        return 'Conectando...';
      case ConnectionStatus.reconnecting:
        return 'Reconectando...';
      case ConnectionStatus.disconnected:
        return 'Sin conexión';
      case ConnectionStatus.error:
        return 'Error';
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
  }
}
