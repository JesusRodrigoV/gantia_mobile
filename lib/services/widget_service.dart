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

  static const String _widgetProviderName = 'GantiaWidgetProvider';

  Future<void> init() async {
    // Initialize for Android widget. Android does not need an app group ID.
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Set an app group ID for iOS if needed for widget data sharing
    }
  }

  void listenTo(GloveState gloveState, ActionLog actionLog) {
    _gestureSub = gloveState.gestureDetectedStream.listen(_updateWidget);
    _connectionSub = gloveState.connectionStatusStream.listen(_updateWidget);
    _actionSub = actionLog.actionEventStream.listen(_updateWidget);
    _updateFromState(gloveState, actionLog);
  }

  Future<void> _updateWidget([_]) async {
    try {
      await HomeWidget.updateWidget(
        name: _widgetProviderName,
        androidName: _widgetProviderName,
      );
    } catch (e) {
      debugPrint('[WidgetService] update error: $e');
    }
  }

  Future<void> _updateFromState(GloveState gloveState, ActionLog actionLog) async {
    final status = _statusLabel(gloveState);
    final isConnected = gloveState.connectionStatus == ConnectionStatus.connected;
    final isFlowing = gloveState.dataFlowing;
    final lastAction = actionLog.recentActions.isNotEmpty
        ? getActionLabel(actionLog.recentActions.first.action)
        : '—';
    final lastGesture = gloveState.gestureDetected?.gesture ?? '';
    final flexIndex = gloveState.telemetry?.flexIndex ?? 0;
    final flexMiddle = gloveState.telemetry?.flexMiddle ?? 0;

    try {
      await HomeWidget.saveWidgetData<String>('status', status);
      await HomeWidget.saveWidgetData<String>('isConnected', isConnected.toString());
      await HomeWidget.saveWidgetData<String>('isFlowing', isFlowing.toString());
      await HomeWidget.saveWidgetData<String>('lastAction', lastAction);
      await HomeWidget.saveWidgetData<String>('lastGesture', lastGesture);
      await HomeWidget.saveWidgetData<String>('flexIndex', flexIndex.toString());
      await HomeWidget.saveWidgetData<String>('flexMiddle', flexMiddle.toString());
      await HomeWidget.updateWidget(
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
    _gestureSub?.cancel();
    _connectionSub?.cancel();
    _actionSub?.cancel();
  }
}
