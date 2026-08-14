import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:home_widget/home_widget.dart';
import '../models/action_message.dart';
import 'glove_state.dart';
import 'action_log.dart';

class WidgetService {
  StreamSubscription<ActionEvent?>? _actionSub;
  GloveState? _gloveState;
  bool _disposed = false;

  static const String _widgetProviderName = 'GantiaWidgetProvider';

  Future<void> init() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
    }
  }

  void listenTo(GloveState gloveState, ActionLog actionLog) {
    if (_disposed) return;
    _actionSub?.cancel();
    _gloveState?.removeListener(_onGloveStateChanged);

    _gloveState = gloveState;
    gloveState.addListener(_onGloveStateChanged);

    _actionSub = actionLog.actionEventStream
        .listen((_) { _updateWidget(); }, onError: (Object e) => debugPrint('[WidgetService] action stream error: $e'));
    _updateFromState(gloveState, actionLog);
  }

  void stopListening() {
    _gloveState?.removeListener(_onGloveStateChanged);
    _gloveState = null;
    _actionSub?.cancel();
    _actionSub = null;
  }

  void _onGloveStateChanged() {
    if (_disposed) return;
    _updateWidget();
  }

  void _updateWidget() {
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

  String _statusLabel(GloveState gloveState) => statusLabelFor(
        gloveState.connectionStatus,
        dataFlowing: gloveState.dataFlowing,
        waitingForDevice: gloveState.waitingForDevice,
      );

  @visibleForTesting
  static String statusLabelFor(
    ConnectionStatus status, {
    required bool dataFlowing,
    required bool waitingForDevice,
  }) {
    switch (status) {
      case ConnectionStatus.connected:
        if (dataFlowing) return 'Activo';
        if (waitingForDevice) return 'Esperando guante';
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
    stopListening();
  }
}
