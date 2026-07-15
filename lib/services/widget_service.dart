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

  static const String _widgetName = 'GantiaWidget';

  Future<void> init() async {
    await HomeWidget.registerWidget(
      android: _widgetName,
      iOS: _widgetName,
    );
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
        name: _widgetName,
        androidName: _widgetName,
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
      await HomeWidget.saveWidgetData('status', status);
      await HomeWidget.saveWidgetData('isConnected', isConnected.toString());
      await HomeWidget.saveWidgetData('isFlowing', isFlowing.toString());
      await HomeWidget.saveWidgetData('lastAction', lastAction);
      await HomeWidget.saveWidgetData('lastGesture', lastGesture);
      await HomeWidget.saveWidgetData('flexIndex', flexIndex.toString());
      await HomeWidget.saveWidgetData('flexMiddle', flexMiddle.toString());
      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
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
